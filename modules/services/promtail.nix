{ config, ... }:

{
  systemd.services.promtail-setup = {
    description = "Setup directories for Promtail";
    before = [ "promtail.service" ];
    requiredBy = [ "promtail.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Create promtail directory with proper permissions
      mkdir -p /var/lib/promtail
      chown promtail:promtail /var/lib/promtail
      chmod 755 /var/lib/promtail
    '';
  };

  services.promtail = {
    enable = true;

    configuration = {
      server = {
        http_listen_port = 6500;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };
      clients = [
        {
          url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        # Regular system logs
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "${toString config.networking.hostName}";
              log_source = "journal";
            };
          };
          relabel_configs = [
            {
              source_labels = ["__journal__systemd_unit"];
              target_label = "unit";
            }
            {
              source_labels = ["__journal__systemd_unit"];
              regex = "podman-.+\\.service";
              target_label = "container_log";
              replacement = "true";
            }
          ];
        }
      ];
    };
  };
}
