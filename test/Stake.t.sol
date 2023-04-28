// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Stake.sol";

contract StakeTest is Test,BLS_Verifier {
    Stake public stake;

    function setUp() public {
        stake = new Stake();
    }

    receive() external payable {}

    /**
    Public key (G2):
X A0: 0x00a87f9b1882a24bacfe0cea10ffa229d458c41df7b8d2c939bc9536729706f8
X A1: 0x281d910af3346fd2ca08a98ecc225740b621f8dc723c3c39919d6b38ab18a85c
Y A0: 0x13b44c8858669843006ca03acf60928a98993036ceace7b0f5ed08cbab98f638
Y A1: 0x16e84bded6f3e69a4ab1c6ba59fe63d92e13f5bad20518021250fefab7053474
Hashed message (G1):
X: 0x20c27751372b8f8f95d47a56255c87b6a5b31329dec67fa2feb61048ef6467b2
Y: 0x202209114e6e3b167ecc53f327aba06f3a14229669f367bda32ea8b3d7ffc905
Signature (G1):
X: 0x301d3c53c20e01f4daac8e7b0f8ee5b2b13abae3adb7a1dc55713b5ec86b3d50
Y: 0x2681ff7ceb14f2e08583d498983843ade2521fd78698344c633e7261dc9a4f13
    
     */

    function testWithdraw() public {
        G2Point memory publicKey = G2Point({
            X: [
                0x00a87f9b1882a24bacfe0cea10ffa229d458c41df7b8d2c939bc9536729706f8,
                0x281d910af3346fd2ca08a98ecc225740b621f8dc723c3c39919d6b38ab18a85c
            ],
            Y: [
                0x13b44c8858669843006ca03acf60928a98993036ceace7b0f5ed08cbab98f638,
                0x16e84bded6f3e69a4ab1c6ba59fe63d92e13f5bad20518021250fefab7053474
            ]
         });
        G1Point memory signature = G1Point({
            X: 0x301d3c53c20e01f4daac8e7b0f8ee5b2b13abae3adb7a1dc55713b5ec86b3d50,
            Y: 0x2681ff7ceb14f2e08583d498983843ade2521fd78698344c633e7261dc9a4f13
        });
        // bytes32 publicKeyHash = keccak256(abi.encodePacked(publicKey.X, publicKey.Y));
        stake.deposit{value: 1 ether}(publicKey);
        stake.withdraw90Percent(publicKey, signature);
    }
}
