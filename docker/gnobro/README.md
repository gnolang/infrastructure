# Gnobro deployment

Currently GnoBro is deployed on 2 micro instances in AWS EC2 listening on port 22 (SSH have been moved to port 2222),
and pointing different chains:

- test4
- portal-loop

## Limitations

### Reverse proxying

Since Gnobro basically works at TCP level there is not a direct method to distinguish between multiple instances of it behind a reverse proxy.
All the methods you can use at HTTP level are not present at TCP level (hostname, headers, cookies) so it is not possible by design.

Basically to have multiple instances there are 3 options:

- same host different ports (e.g. 22, 23...)
- different hosts same port
- using some other tcp tunneling tools like `https://github.com/moul/sshportal`, that are able to do some sort of packet inspection and to route the packets.

## Gotchas

- [Effectively changing SSH port on Ubuntu Server](https://serverfault.com/a/1159600)
