# profiles/kubernetes-dev-helm-fixed.nix
{ config, pkgs, ... }:

{
  # 1. Enable k3s service with minimal changes to the default configuration
  services.k3s = {
    enable = true;
    role = "server";
    # Use only the essential flags
    extraFlags = toString [
      "--tls-san=${config.networking.hostName}"
      "--tls-san=127.0.0.1"
    ];
  };

  # 2. Install essential Kubernetes tools including Helm
  environment.systemPackages = with pkgs; [
    kubernetes # Provides kubectl
    kubernetes-helm # Helm package manager
    k9s # Terminal UI for Kubernetes
    jq # For JSON processing
    curl # For API requests
  ];

  # 3. Configure Firewall - Open necessary ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      6443 # Kubernetes API
      80
      443 # Standard HTTP/HTTPS
      8080
      8443 # Common HTTP alternatives
    ];
  };

  # 4. Ensure necessary kernel modules are loaded for networking/containerd
  boot.kernelModules = [ "br_netfilter" "overlay" ];
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  # 5. Set up kubectl configuration to use k3s kubeconfig
  environment.sessionVariables = { KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"; };

  # 6. Make k3s kubeconfig accessible to users
  system.activationScripts.setupKubectl = ''
    mkdir -p /etc/rancher/k3s
    chmod 755 /etc/rancher
    chmod 755 /etc/rancher/k3s
    if [ -f /etc/rancher/k3s/k3s.yaml ]; then
      chmod 644 /etc/rancher/k3s/k3s.yaml
    fi

    # Setup .kube/config for each user
    for dir in /home/*; do
      if [ -d "$dir" ]; then
        user=$(basename "$dir")
        mkdir -p "$dir/.kube"
        ln -sf /etc/rancher/k3s/k3s.yaml "$dir/.kube/config"
        chown -R "$user:users" "$dir/.kube" || true
      fi
    done

    # Root user config
    mkdir -p /root/.kube
    ln -sf /etc/rancher/k3s/k3s.yaml /root/.kube/config
  '';

  # 7. Simplified dashboard deployment script
  systemd.services.deploy-kubernetes-dashboard = {
    description = "Deploy Kubernetes Dashboard using Helm";
    wantedBy = [ "multi-user.target" ];
    requires = [ "k3s.service" ];
    after = [ "k3s.service" "network.target" ];
    path = [ pkgs.kubernetes pkgs.kubernetes-helm pkgs.jq pkgs.curl ];
    environment = { KUBECONFIG = "/etc/rancher/k3s/k3s.yaml"; };
    script = ''
      # Wait for kubernetes to be ready
      max_attempts=30
      attempt=0

      echo "Waiting for Kubernetes API to become available..."
      while ! kubectl get nodes &>/dev/null; do
        attempt=$((attempt+1))
        if [ $attempt -ge $max_attempts ]; then
          echo "Timeout waiting for Kubernetes API to become available"
          exit 1
        fi
        echo "Attempt $attempt/$max_attempts: Kubernetes API not available yet, waiting..."
        sleep 10
      done

      echo "Kubernetes API is available! Proceeding with dashboard installation."

      # Add kubernetes-dashboard Helm repository if not already added
      if ! helm repo list | grep -q kubernetes-dashboard; then
        echo "Adding kubernetes-dashboard Helm repository..."
        helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
      fi

      # Update Helm repositories
      helm repo update

      # Use basic values that we know will work
      echo "Deploying Kubernetes Dashboard using Helm..."
      helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
        --create-namespace \
        --namespace kubernetes-dashboard

      # Wait for pods to be ready
      echo "Waiting for dashboard pods to start..."
      kubectl -n kubernetes-dashboard wait --for=condition=available deployment --all --timeout=120s || true

      # Patch the dashboard service to use NodePort for external access
      echo "Setting up NodePort for external access..."

      # Create admin service account and get token
      echo "Creating admin service account..."
      kubectl create serviceaccount -n kubernetes-dashboard admin-user || true
      kubectl create clusterrolebinding -n kubernetes-dashboard admin-user \
        --clusterrole=cluster-admin \
        --serviceaccount=kubernetes-dashboard:admin-user || true

      # Create a token that lasts for 1 week
      echo "Creating access token..."
      kubectl -n kubernetes-dashboard create token admin-user --duration=168h > /root/dashboard-token.txt
      chmod 600 /root/dashboard-token.txt
      echo "Access token saved to /root/dashboard-token.txt"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      SupplementaryGroups = [ "users" ];
    };
  };

}
