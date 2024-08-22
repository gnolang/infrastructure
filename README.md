# Gno Infra Doc

## Monitoring & Observability

- [Status Page](https://gno.betteruptime.com/)
- Slack Alerts Channels
  - #better-stack-monitoring: incidents alerted by BetterStack’s monitors
  - #infra-alerts: (random) alerts coming from existing Prometheus service fro Gno (?! not clear where they come from)
  - #gnoland-observability: discussions related to observability issues

## Typical Nodes in a Testnet

| Name | DNS Prefix | Proxied Port [Behind to HTTP(s)] | Other Published Ports |
| --- | --- | --- | --- |
| RPC Node | rpc.testX.gno.land | 26657 | 26656 (tcp) |
| Gno Web | testX.gno.land | 8888 (http) |  |
| Faucet | faucet-api.test4.gno.land | 5000 |  |
| Tx Indexer | indexer.test4.gno.land | 8546 (test4 uses 7879) |  |
