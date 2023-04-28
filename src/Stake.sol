pragma solidity ^0.8.15;

import "../src/BLSVerifier.sol";
import "forge-std/console.sol";

contract Stake is BLS_Verifier{
    // mapping(G1Point => bool) public publicKeys;
    // function deposit(uint256 G1Point)
    // require value = 1ether
    // record G1Point in publicKeys
    // then emit Deposit event with G1Point
    
    // function withdraw(G1Point publicKey, signature G1Point)
    // check if publicKeys[publicKey] is true
    // use verifyMessage(msgsender, publicKey, signature) to verify
    // require signature is valid
    // message is msg.sender, use abi.encodePacked to converte to bytes
    // set publicKeys[publicKey] to false
    // transfer 1 ether to msg.sender
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;
    uint256 public constant WAIT_TIME = 1 days;

    struct DepositInfo {
        bool exists;
        uint256 timestamp;
    }

    mapping(bytes32 => DepositInfo) public publicKeys;
    event Deposit(bytes32 indexed publicKeyHash, uint256 timestamp);
    event Withdraw(bytes32 indexed publicKeyHash);

    function deposit(G2Point calldata publicKey) external payable {
        require(msg.value == DEPOSIT_AMOUNT, "Incorrect deposit amount");
        bytes32 publicKeyHash = keccak256(abi.encodePacked(publicKey.X, publicKey.Y));
        require(!publicKeys[publicKeyHash].exists, "Public key already exists");
        publicKeys[publicKeyHash] = DepositInfo({exists: true, timestamp: block.timestamp});
        emit Deposit(publicKeyHash, block.timestamp);
    }

    function withdraw90Percent(G2Point calldata publicKey, G1Point calldata signature) external {
        bytes32 publicKeyHash = keccak256(abi.encodePacked(publicKey.X, publicKey.Y));
        require(publicKeys[publicKeyHash].exists, "Invalid public key");

        bytes memory message = abi.encode(msg.sender);
        console.logBytes(message);
        require(verifyMessage(message, publicKey, signature), "Invalid signature");
        publicKeys[publicKeyHash].exists = false;
        console.log("msg.sender", msg.sender);
        payable(msg.sender).transfer(DEPOSIT_AMOUNT * 9 / 10);
        emit Withdraw(publicKeyHash);
    }

    function withdrawWaitFor1day(G2Point calldata publicKey, G1Point calldata signature) external {
        bytes32 publicKeyHash = keccak256(abi.encodePacked(publicKey.X, publicKey.Y));
        require(publicKeys[publicKeyHash].exists, "Invalid public key");

        bytes memory message = abi.encodePacked(msg.sender);
        require(verifyMessage(message, publicKey, signature), "Invalid signature");

        require(block.timestamp >= publicKeys[publicKeyHash].timestamp + WAIT_TIME, "Withdrawal not allowed before 1 day");

        publicKeys[publicKeyHash].exists = false;
        payable(msg.sender).transfer(DEPOSIT_AMOUNT);
        emit Withdraw(publicKeyHash);
    }
}