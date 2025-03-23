# nixos-server-config

My *in-progress* personal NixOS server configuration

## Features

### Generic host configuration

- [x] Btrfs filesystem instead of ext4 for better snapshots and rollbacks (plus nixos )
- [x] SSH access via public key authentication
- [x] Firewall configuration
- [x] Fail2ban to block brute force attacks
- [x] ZSH shell with custom p10k config and utility packages
- [x] Docker installation and swarm initialization
- [x] `dops` (Better `docker ps`)
- [x] Dokploy installation
- [x] Secrets management with SOPS

### Zimablade

- [x] Lightweight OS with under 3GB of disk usage
- [x] SSH access via public key authentication
- [x] Firewall configuration
- [x] Fail2ban to block brute force attacks
- [x] ZSH shell with custom p10k config and utility packages
- [x] Podman installation
- [x] Rathole server for tunneling traffic from another server (proxy)
- [x] Wireguard VPN
- [x] Secrets management with SOPS


### TODO
- [ ] Monitoring with Prometheus and Grafana (and maybe Loki for logs)

## Provisioning

```bash
nixos-anywhere --flake .#provisioning root@<server-ip>
```

## Updating configuration

```bash
nixos-rebuild  switch --target-host "root@<server-ip>" \
  --build-host "root@<server-ip>" \
  --flake .#server \
  --use-remote-sudo
```

### List previous configurations

```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

### Rollback to previous configuration

```bash
sudo nix-env --rollback --profile /nix/var/nix/profiles/system --switch-generation 1
```

## Secrets

### Adding a new server

Get the server's public key:
```bash
ssh-keyscan -t ed25519 <server-ip> 2>/dev/null | grep -v '^#' | awk '{print $2 " " $3}' | ssh-to-age
```

Add the public key to the `secrets/secrets.yaml` file. FOr example
```yaml
keys:
  - &<host-name> ssh-ed25519...
creation_rules:
  - path_regex: hosts/.*/secrets\.yaml$
    key_groups:
      - age:
          - *<host-name>
```


**Encrypt a new file:**
```bash
sops --encrypt --in-place secrets/secrets.yaml
```

**Edit an existing encrypted file:**
```bash
sops secrets/secrets.yaml
```

## Re encrypting secrets

```bash
sops updatekeys hosts/zimablade/secrets.yaml
```
