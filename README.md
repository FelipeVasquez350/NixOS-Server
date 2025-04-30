# NixOS-Server

My *in-progress* personal NixOS server configurations

## Features

## Terraform :D

This repo uses `terraform` alongisde `diskio` in order to spin up a preconfigured libvirt vm with UEFI support (altho on a nixos host is kinda broken funnily enough).
This lets you easily spin up a vm for testing your config in order to avoid breaking production machines, to read more on how it works check out [the readme](terraform/README.md)

Ps: to connect to the same ip but with the VMs changing time and time again (especially when testing the image build process) i reccomend connecting to it by bypassing the host checks to avoid editing the known_hosts file over and over (don't do this in a prod enviroment please)
```bash
ssh -o StrictHostKeyChecking=false admin@<server-ip>
```

### Images

To build an image to then use in a vm or cloud provider run the following with your fav flake defined in the packages settings, for example:

```bash
nix build .#genericImage && sudo ./result
```

### Hosts configs

#### Generic (or VMs)

- [x] Btrfs filesystem instead of ext4 for better snapshots and rollbacks (plus nixos )
- [x] SSH access via public key authentication
- [x] Firewall configuration
- [x] Fail2ban to block brute force attacks
- [x] ZSH shell with custom p10k config and utility packages

#### Zimablade

- [x] Lightweight OS with under 3GB of disk usage
- [x] SSH access via public key authentication
- [x] Firewall configuration
- [x] Fail2ban to block brute force attacks
- [x] ZSH shell with custom p10k config and utility packages


### Profiles

#### Dokploy
- [x] Docker installation and swarm initialization
- [x] `dops` (Better `docker ps`)
- [x] Dokploy installation
- [x] Secrets management with SOPS

#### Kubernetes (Development enviroment)
- [x] k3s my beloathed
- [x] kubernetes-dashboard (proxy not on by default)

#### Zima (default profile for my zimablade)
- [x] Podman installation
- [x] Rathole server for tunneling traffic from another server (proxy)
- [x] Wireguard VPN
- [x] Secrets management with SOPS


### TODO
- [ ] Monitoring with Prometheus and Grafana (and maybe Loki for logs)

## (WIP) Provisioning
This is currently not an option and still working on a alternative solution that works well with disko with the default profile (yes i know it would just be a if statement but i'm lazy af)
```bash
nixos-anywhere --flake .#provisioning admin@<server-ip>
```

## Updating configuration

```bash
nixos-rebuild  switch --target-host "admin@<server-ip>" \
  --flake .#server \
  --use-remote-sudo
```

You can add `--build-host "admin@<server-ip>" \` i you want

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
