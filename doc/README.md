# Gno Infra Doc

## Monitoring & Observability

- [Status Page](https://gno.betteruptime.com/)
- Slack Alerts Channels
  - #better-stack-monitoring: incidents alerted by BetterStack’s monitors
  - #infra-alerts: (random) alerts coming from existing Prometheus service fro Gno (?! not clear where they come from)
  - #gnoland-observability: discussions related to observability issues

## Typical Services in a Testnet

| Name | DNS Prefix | Proxied Port [Behind HTTP(s)] | Healthcheck Endpoint | Other Published Ports |
| --- | --- | --- | --- | --- |
| RPC Node | rpc.testX.gno.land | 26657 | / | 26656 (tcp) |
| Gno Web | testX.gno.land | 8888 (http) | /status.json | |
| Faucet | faucet-api.testX.gno.land | 5000 | /health | |
| Tx Indexer | indexer.testX.gno.land | 8546 (test4 uses 7879) | /health | |

## Service Description

- Service Name
- Service Type
  - Core Service (GNO)
  - Optional Service (Tx-Indexer)
  - Handy Service (Gno Web)
- Public implemntations
  - Dev / Test /Staging
  - Prod
- Ports Exposed (if any)
- Specific CMD
- Special Needs
  - HW resuources
