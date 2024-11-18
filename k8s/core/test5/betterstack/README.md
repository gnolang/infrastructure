# Betterstack Monitor Setup

This folder contains the script to setup the Betterstack monitors for test5.

In particular Betterstack APIs are used to create:

- a monitor group
- all the relevant monitors for services
- a status page section
- all the relevant status page entries

## Usage

```bash
USAGE
  betterapi [flags]

Step by step caller of Betterstack Api to generate Monitors and Status Page entries in Betterstack website

FLAGS
  -extra-path ...       path for importing addinial services
  -fqdn test5.gno.land  fully qualied domain name to be applied to default monitors
  -group test5          name of group of monitors to be created
  -prefix Test 5        prefix name applied to monitors
  -token ...            [REQUIRED] auth token for calling Betterstack APIs
```
