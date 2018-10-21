# AsenaFabric - A Turnkey Blockchain Platform for the Enterprise
## History
We had proposed a solution to share data between Vodafone Turkey, Turkish Telekom and Turkcell. After Proof of Concept and demo stages, we decided to produce a turnkey solution and then the AsenaFabric was born.
## AsenaFabric Features
- a built-in general-purpose **Smart Contract**
- an easy to setup **Hyperledger Fabric** environment
- a modular and scalable architecture that meets **enterprise** needs
- can run on Linux, Windows, Mac OSX
- can be hosted in your **datacenter** or on **AWS, Azure, Google** cloud
- a complete solution with **performance and log management**

**AsenaFabric** is a turnkey blockchain platform for the enterprise. It’s based on Hyperledger Fabric which is built by Linux Foundation.

**AsenaFabric** provides **enterprise-level security and scalability as well as performance**. It provides a key-value datastore and **JSON document database** to store data. Data can be on a private area where other organizations cannot access or data can be on a public area where only the organizations in a consortium can access.

**AsenaFabric** hardens the Hyperledger Fabric and provides a secure platform where organizations can share data safely. AsenaFabric comes with **performance monitoring and log management solutions** to support IT operations.

**AsenaFabric** provides a **ready-to-use Smart Contract** so that you can start using the blockchain platform immediately. You can use Hyperledger SDKs in NodeJS and Java to integrate your applications to the platform.
## Asena Smart Contract (Chain Code)
- It's already included in the solution. You don't need to write your own smart contract.
- It's a general purpose smart contract that meets most enterprise needs.
- It provides an API to integrate with your applications.
- It has built-in performance metrics and logging capabilities.
## What is Hyperledger?
- [Hyperledger](https://www.hyperledger.org) is an **open source** collaborative effort to advance cross-industry blockchain technologies.
- It is hosted by the [**Linux Foundation**](https://www.linuxfoundation.org).
- It's a global collaboration spanning
  - **finance**
  - **banking**
  - **IoT**
  - **supply chains**
  - **healthcare**
  - **manufacturing**
  - **technology**
## Why Docker?
- [Docker](https://www.docker.com) enables faster development
- It improves developer productivity
- It can run on your datacenter or on a cloud
- It reduces IT infrastructure costs
## AsenaFabric General Architecture
| Component | Description |
|-----------|-------------|
| Your App  | Uses NodeJS or Java SDK for Hyperledger Fabric |
| Asena Smart Contract | A general-purpose Smart Contract for Enterprise needs |
| Asena Fabric | Automates setup, provides log and performance management |
| Datastore | Blockchain and CouchDB |
| Docker | Provides containers |
| Operating Systems | Linux, Windows, Mac OSX |

## AsenaFabric Installation
| Action | Description |
|--------|-------------|
| Download AsenaFabric | git clone https://github.com/gokhankocak/AsenaFabric.git |
| AsenaDockerInstall.sh | installs Docker CE and some necessary tools |
| AsenaDockerSetup.sh | installs Docker Compose and pulls docker images |
| AsenaFabricSetup.sh | creates the AsenaFabric configuration files |
| AsenaFabricStart.sh | starts AsenaFabric containers |
| AsenaFabricInit.sh | installs Asena Smart Contract |
| backend/go | run go build Backend.go and then ./Backend to load some sample data to AsenaFabric |
| backend/node | run node . to start the backend NodeJS server |
| Open a browser | connect to http://localhost:3000/AsenaSmartContract to display info |
| Open a browser | connect to http://localhost:3000/GetCustomerData to view sample data loaded by backend/go/Backend.go |

