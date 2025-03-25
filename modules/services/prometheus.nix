{ config, ... }:

{  services.prometheus = {
    port = 4000;
    enable = true;

    exporters = {
      node = {
        port = 4500;
        enabledCollectors = [ "systemd" ];
        enable = true;
      };
    };

    scrapeConfigs = [
      {
        job_name = "nodes";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
    ];
  };
}
