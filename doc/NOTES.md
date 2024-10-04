# Notes on Infra

## Current Infra

* All In Bits / Gno
  * Nomad

* Dev-X
  * GKE (Google Cloud managed Kube)

### Cloud services

* Latitude
  * Bare metal
  * Testnet 1, 2, 3
  * Portal Loop

* Digital Ocean
  * Staging

## Core Service

### Validator

> Based on Gno binary

* `Classic`, holding:
  * publicly available
  * secrets
  * config (based on config.toml file)
  * genesis

* `Sentry Node`: a node acting as proxy for a validator not exposed on the public internet

* `RPC Node`: node exposing RPC interface

#### Sentry Vs Classic validator node

The Sentry Node Architecture (referred to as SNA in this document) is an infrastructure example for DDoS mitigation on Gaia / Cosmos Hub network validator nodes.

* [Sentry node architecture](https://forum.cosmos.network/t/sentry-node-architecture-overview/454)

#### Relevant portion of config files

| Validator Node (behing sentry node) |||
|---|---|---|
| pex | false | node doesn’t try to gossip |
| persistent_peers | list of sentry nodes | The validator node will only communicate with the sentry nodes. |
| private_peer_ids | omitted | as pex=false the setting can be omitted |
| addr_book_strict | false | the validator is on a private network and it will connect to the sentry nodes also on a private network |

| Sentry Node |||
|---|---|---|
| pex | true | the node should be able to talk to nodes on the Internet and they should benefit from the peer exchange reactor |
| persistent_peers | validator node, optionally other sentry nodes | the sentry node must absolutely not gossip the validator node id and IP address, hence the private_peer_ids should contain the validator node’s ID |
| private_peer_ids | validator node id | the validator node is expected to be up and running and since it’s not gossip-ed, the only way to connect to it is to add it to this list |
| addr_book_strict | false | specify that the validator is on a private network |

## Handy Services

### Public

* `Gno`: Validator / RPC / Sentry node

* `Tx-indexer`: exposes RPC-JSON and GraphQL interface for navigating
  * load balanced
  * secured

* `Gnofaucet`: Provide initial tokens
  * secured

### Handy services

* `Gnoweb`: web UI for Gno
  * served at a public domain, gno.land
  * load balanced
  * secured

* `GnoBro`: Interactive Playground of Gno

* `Portal Loop`: Testing validator node able to backup and restore its own chain
* `Supernova`: Load testing application, it is able to create load generating trasactions against a target cluster of validators

### Other Apps

* `Gnochess` (LEGACY): Demo App showing Gno Gno chess service

* ~~`Gnoscan`: Web UI to show data from an RPC node endpoint~~

* `Tx-archive` (LEGACY): periodically backed up onto GH repo

### Monitoring Infra

* `Grafana / Metrics`
  * internal use

* `Log collection`
  * internal use

## Onboard new team member

* Tailscale
* Nomad Dashboard
  * Traefik Dashboard

* Bare Metal Providers
  * Latitude
  * Hetzner

* Cloud Providers
  * GCP
  * Digital Ocean

* Monitoring
  * Better Stack
  * Grafana Dashboard
  * Loki

* Metrics / Traces
  * Open Telemetry
  * Prometheus
  * Jaeger ?

* DNS
  * CLoudflare
  * Google Domains
  * Squarespace
