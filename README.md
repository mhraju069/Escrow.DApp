# Decentralized Escrow System

A secure and decentralized Ethereum-based Escrow system built with Solidity. This project facilitates trustless transactions between clients and workers, ensuring that funds are held safely until the agreed-upon work is completed and verified.

## 📝 Features

The `Escrow` smart contract supports the full lifecycle of a service agreement:

- **Create Order**: A client initiates an order by depositing Ether into the contract. The order is identified by a unique Project ID.
- **Accept Order**: A worker can accept a created order, locking the engagement between the specific client and worker.
- **Complete Order**: Once the work is done, the worker marks the order as completed.
- **Release Funds**: The client verifies the work and releases the deposited Ether to the worker.
- **Dispute Mechanism**: If issues arise, either the client or the worker can raise a dispute, locking the funds.
- **Admin Resolution**: The contract owner (arbiter) has the authority to resolve disputes by transferring the funds to the rightful party (either returning to the client or paying the worker).

## 🛠 Technology Stack

- **Smart Contract**: Solidity `^0.8.0`
- **Framework**: [Hardhat](https://hardhat.org/)
- **Security**: [OpenZeppelin](https://openzeppelin.com/contracts/) (ReentrancyGuard)
- **Testing**: Mocha, Chai, and Web3.js

## 📂 Project Structure

- `contracts/Escrow.sol`: The main smart contract logic.
- `test/escrow_testing.js`: Comprehensive test suite verifying all contract functionalities.

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:
- [Node.js](https://nodejs.org/) (v20+ recommended)
- [npm](https://www.npmjs.com/) or [yarn](https://yarnpkg.com/)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <project-directory>
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

### Compile Contract

Compile the Solidity smart contracts to generate the artifacts:

```bash
npx hardhat compile
```

### Run Tests

Execute the test suite to verify the contract logic:

```bash
npx hardhat test
```

## 📜 Contract Workflow

1. **Initialization**: The contract is deployed, and the deployer becomes the `owner` (arbiter).
2. **Client**: Calls `Create(projectId)` creating an order and sending ETH.
   - Status: `Created`
3. **Worker**: Calls `Accept(projectId)` to take the job.
   - Status: `Accepted`
4. **Worker**: Calls `Complete(projectId)` when work is ready.
   - Status: `Completed`
5. **Client**: Calls `Release(projectId)` to release payment to the worker.
   - Status: `Released`
   - **Note**: Funds are transferred to the worker.

### Dispute Flow

- At any point before release, if there is a disagreement, `Dispute(projectId, reason)` can be called.
  - Status: `Disputed`
- The `owner` then reviews the case and calls `Resolve(projectId, receiverAddress)`.
  - Status: `Resolved`
  - Funds are sent to the `receiverAddress`.

## 🛡 Security

The contract utilizes `ReentrancyGuard` from OpenZeppelin to prevent reentrancy attacks during fund transfers.

## 📄 License

This project is licensed under the MIT License.
