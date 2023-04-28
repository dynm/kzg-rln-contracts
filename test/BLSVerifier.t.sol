// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/BLSVerifier.sol";
import "../src/HashToPoint.sol";

contract BLS_VerifierTest is Test, BN254HashToG1 {
    BLS_Verifier public verifier;
    BN254HashToG1 public hashToPoint;

    function setUp() public {
        verifier = new BLS_Verifier();
        hashToPoint = new BN254HashToG1();
    }
    /**
    Public key (G1):
    X A0: 0x2f0f1c528539d3dc685e12af7dbea31ff00394bd09d8abf0080f623d0439b435
    X A1: 0x1ed82dd3689d8debff4db5d2b44742c4ecc2bd24977e4b363be5c555961dbd9c
    Y A0: 0x0e378325bf2fc65f3ed9e3fdb33231170b929f90bfbc032f29fe082b92ff0216
    Y A1: 0x2b859a3125c907b0a3058f469cc797710b794deb23ed0045336e1f2eb238d0c5
    Hashed message (G1):
    X: 0x059dac1925a1d0bee704dd2ae3836a3d8e76a4c4249f17860ce1d0a530c5f8f7
    Y: 0x03870b29cb77fab35c1394ac29e19344465046309674e8d138da412f834ecaee
    Signature (G1):
    X: 0x0bc04ce23000c099dd233123429cc183c60c0bbbbcd3ce621363e9c3cc973456
    Y: 0x1143bc0e79358a63acdd598ab224de559d4b628b805f6bc3bb82465256315f82
    
     */

    function testVerifier() public {
        // Public key (G2)
        G2Point memory publicKey = G2Point({
            X: [
                0x2f0f1c528539d3dc685e12af7dbea31ff00394bd09d8abf0080f623d0439b435,
                0x1ed82dd3689d8debff4db5d2b44742c4ecc2bd24977e4b363be5c555961dbd9c
            ],
            Y: [
                0x0e378325bf2fc65f3ed9e3fdb33231170b929f90bfbc032f29fe082b92ff0216,
                0x2b859a3125c907b0a3058f469cc797710b794deb23ed0045336e1f2eb238d0c5
            ]
         });

        // Hashed message (G1)
        bytes memory message = abi.encodePacked("hello");
        emit log_bytes(message);
        uint256[2] memory hash = hashToPoint.hashToPoint(message);
        emit log_uint(hash[0]);
        emit log_uint(hash[1]);
        G1Point memory messageHash = G1Point({
            X: hash[0],
            Y: hash[1]
        });

        // Signature (G1)
        G1Point memory signature = G1Point({
            X: 0x0bc04ce23000c099dd233123429cc183c60c0bbbbcd3ce621363e9c3cc973456,
            Y: 0x1143bc0e79358a63acdd598ab224de559d4b628b805f6bc3bb82465256315f82
        });
        bool result = verifier.verify(messageHash, publicKey, signature);
        assertEq(result, true);
    }

    function testVerifyMessage() public{
        /*
        Public key (G2):
        X A0: 0x0c7224358bdd14152e6b4c65672cf2f525719cd9d3be24c7b14c6c3889ecec22
        X A1: 0x0b2800435195674bae34b6e14d787d5eabc8f924eff11589c35b401627b155d4
        Y A0: 0x0b733864811a530b54c94d63a968b276d8e3c01d5fec22c63f7c4b2f2d53ec76
        Y A1: 0x1f1b3abece282e4992c16338970d1b520a5969b9eee60852af4a1c372f60a0c4
        Hashed message (G1):
        X: 0x14c187c8224c4025798166d49d49d40b42df196ed5e74a1a2b2f24796ef86435
        Y: 0x09e4b87acbbfae89b60b0b49060dd8a69ec00847a14a5d46c134ced93c9abca6
        Signature (G1):
        X: 0x155622e9780f320040b92a16156772e095ffe27cc19213a92b54c825cb411f4c
        Y: 0x1296f16b961723ae23da25f5647b8ade3565ec59a47eb3340d310be2010124dd
        */
        G2Point memory publicKey = G2Point({
            X: [
                0x0c7224358bdd14152e6b4c65672cf2f525719cd9d3be24c7b14c6c3889ecec22,
                0x0b2800435195674bae34b6e14d787d5eabc8f924eff11589c35b401627b155d4
            ],
            Y: [
                0x0b733864811a530b54c94d63a968b276d8e3c01d5fec22c63f7c4b2f2d53ec76,
                0x1f1b3abece282e4992c16338970d1b520a5969b9eee60852af4a1c372f60a0c4
            ]
        });
        bytes memory message = abi.encodePacked("Hello, World!");
        G1Point memory signature = G1Point({
            X: 0x155622e9780f320040b92a16156772e095ffe27cc19213a92b54c825cb411f4c,
            Y: 0x1296f16b961723ae23da25f5647b8ade3565ec59a47eb3340d310be2010124dd
        });
        bool result = verifier.verifyMessage(message, publicKey, signature);
        assertEq(result, true);
    }
}
