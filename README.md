# LearnEarnDApp
# Learn-to-Earn Platform

## Vision

The **Learn-to-Earn** platform aims to revolutionize education by integrating blockchain technology to reward students for their learning achievements. By offering tokens and NFTs for completing courses and tasks, we seek to create a more engaging and incentivized learning experience, bridging the gap between education and real-world benefits.

## Flowchart

![Flowchart](flowchart.png)

*Note: Ensure you add a flowchart image showing the process of course enrollment, task completion, and reward distribution.*

## Features

- **Blockchain Integration**: Utilizes Ethereum smart contracts for secure reward distribution.
- **Incentivized Learning**: Earn tokens and NFTs for completing educational tasks.
- **Course Management**: Educators can create courses and define tasks with rewards.
- **Token Economy**: ERC-20 tokens and ERC-721 NFTs are used to reward students.
- **MongoDB Backend**: Manages user data, courses, and tasks effectively.

## Smart Contracts

- **EDUToken**: [0xYourEduTokenAddress](https://etherscan.io/address/0xYourEduTokenAddress)
- **EducationNFT**: [0xYourEduNFTAddress](https://etherscan.io/address/0xYourEduNFTAddress)
- **LearnToEarnPlatform**: [0xYourLearnToEarnAddress](https://etherscan.io/address/0xYourLearnToEarnAddress)

## Getting Started

### Prerequisites

- Node.js and npm
- MongoDB (local or Atlas)
- MetaMask or any Ethereum wallet
- Infura or Alchemy account for Ethereum node access

### Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/learn-to-earn.git
    cd learn-to-earn
    ```

2. **Install backend dependencies**:
    ```bash
    cd backend
    npm install
    ```

3. **Set up environment variables**:
   Create a `.env` file in the `backend` directory:
   ```plaintext
   INFURA_URL=<Your Infura Project URL>
   EDU_TOKEN_ADDRESS=0xYourEduTokenAddress
   EDU_NFT_ADDRESS=0xYourEduNFTAddress
   LEARN_TO_EARN_ADDRESS=0xYourLearnToEarnAddress
   MONGO_URI=<Your MongoDB Connection String>
