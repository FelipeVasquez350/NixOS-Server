{ ... }: {
  imports = [
    ./services/loki.nix
    ./services/promtail.nix
    ./services/prometheus.nix
    ./services/grafana.nix
  ];
}
