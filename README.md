# NixOS-Server
 My NixOS server config

## Description



## How to use


### For provisioning a new server
```bash
nixos-anywhere --flake .#provisioning --generate-hardware-config nixos-generate-config ./hardware_configuration.nix admin@server-ip
```

### For updating the server
```bash
nixos-rebuild switch --target-host "admin@192.168.178.200" \
  --build-host "admin@192.168.178.200" \
  --flake .#server \
  --use-remote-sudo
```

## How to check if a port is open

```bash
nmap -p <port> localhost
```
