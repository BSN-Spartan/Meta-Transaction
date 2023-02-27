# Meta-Transaction

[![Smart Contract](https://badgen.net/badge/smart-contract/Solidity/orange)](https://soliditylang.org/)

A meta transaction is an Ethereum transaction that inserts another transaction in the original one. The user signs it using their private key and sends it to the relayer, which verifies it, submits it to the blockchain, and handles the gas credit.

## Prerequisite

Before using this smart contract, it is important to have a basic understanding of Ethereum and Solidity, as well as [ERC2612](https://eips.ethereum.org/EIPS/eip-2612) standard.

## Overview

Before talking about meta transaction, let's take a glance at what a transaction is. An Ethereum-based transaction contains the following parameters:

- `from` – sender's address
- `to` – receiver's address（if it is a wallet address, the transaction will transmit the value to it. If it is a contract address, the transaction will execute the contract code）
- `signature` – the signature of the sender. This signature is generated when the transaction is signed by the sender's private key to ensure that the sender has authorized the transaction.
- `value` – the amount of ETH to be transferred from the sender to the receiver (in WEI, a denomination of ETH) 
- `data` – an optional field that can include any data
- `gasLimit` – the maximum amount of Gas that can be consumed by the transaction. The Gas is the unit of calculating resources
- `gasPrice` – the fee paid by the sender per unit of Gas
- `nonce` – the number of transactions that the sender has sent

Note that the `signature` field allows anyone to verify that the transaction was signed by the sender. When sending the transaction to the blockchain, the sender will pay the gas fee, and the verified transaction will be submitted to the node. Then the node will broadcast this transaction in the blockchain network. **If this transaction is sent to an intermediary that can help the sender pay the gas fee and execute the transaction, then this is a meta transaction**.

How can we achieve this? We embed a meta transaction inside an ordinary transaction, and then the intermidiary signs that meta transaction, and specifies the recipient address as the address of the meta-transaction smart contract. Therefore, the gas fee will be paid by the intermediary. After receiving a meta transaction, the meta transaction smart contract will verify the signature information of the meta transaction. After confirmation, the meta transaction will be executed by the meta transaction smart contract.

## Usage

Get the Meta Transaction contract source code by command:

```
$ git clone https://github.com/BSN-Spartan/Meta-Transaction.git
```

For beginners, the contracts in this application can be deployed by the steps in [Spartan Quick Testing](https://www.spartan.bsn.foundation/main/quick-testing#step1).

### Scenario

Suppose that Alice holds 100 MKT tokens (ERC20 standard tokens), and now she would like to transfer 50 tokens to Bob. However, there is no gas credit in Alice's wallet address. Carol, as Alice's friend, has enough gas credit in her wallet. In this case, Carol can use this contract to help Alice pay for the transaction:

1. The contract owner deploys the MetaTx contract
2. The contract owner calls `mint` function to mint 100 MKT tokens to Alice's wallet address. 
3. Alice inputs her wallet address in `getNonce` function and calls the function. Then, it returns a nonce value that represents the number of meta transactions sent by Alice's wallet address. The nonce value used in encapsulating the meta transaction needs to be increased by 1 on the basis of the obtained nonce value. For example, if the returned nonce value is 4, the nonce value in the encapsulated meta transaction is 5.
4. Alice calls `DOMAIN_SEPARATOR` function to get the encrypted data of this contract.
5. Alice signs the transaction data in the offline signature program provided by the contract package, and sends the parameters of the data, including r, s, v signatures, to Carol. The use of offline signature program can be found in the section below.
6. After receiving the data, Carol calls `metaTransferFrom` function to send the transaction. Note that the parameters `from`, `to`, `amount`, `nonce`, and `deadline` passed in should be consistent with the data signed by Alice.
7. After calling the contract, the meta transaction is completed, and there are 50 MKT tokens in Bob's wallet address.

### Offline Signature Program

This contract provides an offline signature package. Developers can use the offline signature program to sign the meta transaction. This program is running by Node.js, and developers can generate the signature in the command prompt by follow steps:


1. Install Node.js in the system and check the version:

```
node v14.17.6
npm  v6.14.15
```

2. Enter the project directory

```
cd ERC20MetaTxSign
```

3. Pull the node package into the directory

```
npm install
```

4. Open the 'ERC20MetaTxSign.js' file and modify the following parameters, for example:

```javascript
var from = "0x40e4f939d1cc1555a3dd1a9f477a3d8353857106";				//Sender's address（Alice's wallet address）
var to = "0x04AB1d364B0B62B3489094c407437fD427bCbb0e";				//Receiver's address（Bob's wallet address）
var amount = 100;				//Amount of token to be transferred
var nonce = 2;				//nonce value for encapsulating the meta transaction （one more than the nonce value returned by getNonce function）
var deadline = 1677313438;			//Deadline, in the form of Unix Timestamp. The time should be later than the current time. 
var DOMAIN_SEPARATOR = "0x5dbe00f463a498cb4d0c93c383323875ce01c1b24b78fca345a6a3a28baf179e";	//encrypted data of this contract, generated by DOMAIN_SEPARATOR function
var privateKey = "0x44196799c946ac9fc872bede04d8704b3086757f16b6849b10d5d73d97d8d6f4"; 		//Sender's private key（Alice's private key）
```

5. Run command below:

```
node ERC20MetaTxSign.js
```

6. The returned data contains `r,s,v` parameters, which can be used by the transaction sender (Carol) to pay the gas fee:

```javascript
{
  r: '0x0e0c86fdc3613b959f2923ba8f1d23379d6e3d7b276ff810362599be84a8c5f9',
  s: '0x7d79a24fe767856424e9a19e78bb3fddcf4234578f9617537d9dc10fe2734499',
  _vs: '0x7d79a24fe767856424e9a19e78bb3fddcf4234578f9617537d9dc10fe2734499',
  recoveryParam: 0,
  v: 27,
  yParityAndS: '0x7d79a24fe767856424e9a19e78bb3fddcf4234578f9617537d9dc10fe2734499',
  compact: '0x0e0c86fdc3613b959f2923ba8f1d23379d6e3d7b276ff810362599be84a8c5f97d79a24fe767856424e9a19e78bb3fddcf4234578f9617537d9dc10fe2734499'
}
```

## Main Functions

### getNonce

This function can get the number of meta transactions the sender has already sent.

```
function getNonce(address from)
```

### metaTransferFrom

This function allows a user to pay for and send a meta transaction signed by another user. 

```
function metaTransferFrom(address from,address to,uint256 amount,uint256 nonce,uint256 deadline,uint8 v,bytes32 r,bytes32 s)
```

## License

Spartan-Meta Transaction Contract is released under the [Spartan License](https://github.com/BSN-Spartan/Beginner-Level-Contracts/blob/main/Spartan%20License.md).
