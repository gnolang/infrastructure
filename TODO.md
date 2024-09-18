# Spin up a cluster on PR merge

Feasible Tools:

* [Garden - The DevOps automation tool for K8s](https://garden.io/ "Garden - The DevOps automation tool for K8s")
* [Spinnaker](https://spinnaker.io/ "Spinnaker")
* [How to provision dynamic review environments using merge requests and Argo CD](https://about.gitlab.com/blog/2022/08/02/how-to-provision-reviewops/ "How to provision dynamic review environments using merge requests and Argo CD")

## Why Kube

### Evaluating different orchestration tools

* Docker Swarm

  PRO:
  * Easy to configure
  * Smooth transition from Docker compose

  CONS:
  * The community seems to have left it apart
  * Not clear who is maintaining it

* HashiCorp Nomad

  PRO:
  * Already used in the company
  * Few concept to learn

  CONS:
  * Few resources and discussions
  * Following a single company Roadmap
  * a lot of _Magic_ going on

* Kubernetes

  PRO:
  * Many resources available online
  * Very active community
  * Lots of tool
  * Community driven: tons of feature already developed

  CONS:
  * Learning curve quite complex
  * a lot of _Magic_ going on

### Evaluating different datacenter / infra providers

* Home made solution

  PRO:
  * Maximixing performace
  * Using dedicated HW
  * Using tailored and on-purpose configurations and hw
  * Cost are clear and defined

  CONS:
  * Huge effort to run and maintain hw and infrastructure
  * Running a datacenter is a company within the company

* Baremetal solution

  PRO:
  * Using dedicated HW
  * Using tailored and on-purpose configurations and hw

  CONS:
  * Reliability of provider impact directly performance of service (see Latitude)
  * High rates
  * Difficult to maximize usage of resources

* Cloud provider

  PRO:
  * seamless usage
  * Self-healing system on infra failures

  CONS:
  * Hidden costs
  * Hidden / shared hw

### Why Bare Metal

* [What is Bare Metal Blockchain Infrastructure? — Blockdaemon Blog](https://www.blockdaemon.com/blog/what-is-bare-metal-blockchain-infrastructure "What is Bare Metal Blockchain Infrastructure? — Blockdaemon Blog")
* [Ankr | Blog](https://www.ankr.com/blog/ankr-RPC-performance-advantage-global-bare-metal-node-infrastructure/ "Ankr | Blog")
* [Bare Metal is Web3’s Way Forward. Web3 has a cloud problem | by Liquify | Medium](https://medium.com/@liquify/bare-metal-is-web3s-way-forward-839b10f58e14 "Bare Metal is Web3’s Way Forward. Web3 has a cloud problem | by Liquify | Medium")
* [2311.09440v1.pdf](https://arxiv.org/pdf/2311.09440 "2311.09440v1.pdf")

### Alternative Bare Metal Providers

* [Bare Metal Cloud Server AMD BLOCKCHAIN SERVER](https://www.cherryservers.com/pricing/dedicated-servers/amd_blockchain_server "Bare Metal Cloud Server AMD BLOCKCHAIN SERVER")
* [Bare Metal Cloud Infrastructure for Web3 - Server Room](https://www.serverroom.net/web3/ "Bare Metal Cloud Infrastructure for Web3 - Server Room")
* [Tinkerbell](https://tinkerbell.org/)

### Other discussions

* How to effectively replicate / deploy multiple validators
* Effective Infra Benchmark
  * Supernova?
  * Template config
