# Q/A

## Performance

* Node performance accoring to HW resource
* Memory consumption of binary
* Optimization of docker images footprint

## Requirments

* Network
* Storage

## Docker Image

* Base Image -> Go Official + Scratch
* Optimize binary compilation

* Base image is ALPINE. Why not Scratch+Binary?
(Supernova start from SCRATCH base image)
* Build is made by Makefile (gno.land/Makefile)
  * Makefiles in tm2 ?
  * Goreleaser ??

---

### Service

* Service Name
* Service Type
  * Core Service (GNO)
  * Optional Service (Tx-Indexer)
  * Handy Service (Gno Web)
* Public implemntations
  * Dev / Test /Staging
  * Prod
* Ports Exposed (if any)
* Specific CMD
* Special Needs
  * HW resuources
