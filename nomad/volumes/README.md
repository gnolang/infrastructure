# Nomad CSI

## How to start

This folder contains nomad CSI volumes.

This volumes is on digital oceans, and can be only setup on servers running the job [css-digitalocean.nomad](../jobs/csi-digitalocean.nomad).

To setup the volume, you can execute the command:

``` sh
nomad volumes create ./csi_volume.hcl
```

## Docs

- [CSI in Digital Ocean](https://github.com/hashicorp/nomad/tree/main/demo/csi/digitalocean)
