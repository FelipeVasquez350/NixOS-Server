# nixos-server-config

My *in-progress* personal NixOS server configuration

## Features

- [x] Btrfs filesystem instead of ext4 for better snapshots and rollbacks (plus nixos )
- [x] SSH access via public key authentication
- [x] Firewall configuration
- [x] Fail2ban to block brute force attacks
- [x] ZSH shell with custom p10k config and utility packages
- [x] Docker installation and swarm initialization
- [x] `dops` (Better `docker ps`)
- [x] Dokploy installation

### TODO
- [ ] Monitoring with Prometheus and Grafana (and maybe Loki for logs)
- [ ] VPN with Wireguard

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
