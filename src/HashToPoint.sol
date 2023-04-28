pragma solidity ^0.8.0;

contract BN254HashToG1 {
    uint256 constant FIELD_MODULUS = 0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000001;
    // The structure of a G1 point on the BN254 curve.
    struct G1Point {
        uint256 X;
        uint256 Y;
    }
    // The structure of a G2 point on the BLS12-381 curve.
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    G1Point NOTHING_UP_MY_SLEEVE = G1Point(
        {X: 0x059dac1925a1d0bee704dd2ae3836a3d8e76a4c4249f17860ce1d0a530c5f8f7,
         Y: 0x03870b29cb77fab35c1394ac29e19344465046309674e8d138da412f834ecaee});

    function hashToPoint(bytes memory data) public view returns (uint256[2] memory result) {
        uint256 h = uint256(keccak256(data));
        G1Point memory p = scalarMul(NOTHING_UP_MY_SLEEVE, h);
        result[0] = p.X;
        result[1] = p.Y;
    }

    function scalarMul(G1Point memory point, uint256 scalar) public view returns (G1Point memory) {
        uint256[3] memory input = [
            point.X % FIELD_MODULUS,
            point.Y % FIELD_MODULUS,
            scalar % FIELD_MODULUS
        ];

        uint256[2] memory output;

        assembly {
            if iszero(staticcall(not(0), 0x07, input, 0x60, output, 0x40)) {
                revert(0, 0)
            }
        }

        return G1Point(output[0], output[1]);
    }
}
