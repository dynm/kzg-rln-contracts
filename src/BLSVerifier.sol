pragma solidity ^0.8.0;

import "./HashToPoint.sol";

contract BLS_Verifier is BN254HashToG1 {
    // X A0: 1800DEEF121F1E76426A00665E5C4479674322D4F75EDADD46DEBD5CD992F6ED
    // X A1: 198E9393920D483A7260BFB731FB5D25F1AA493335A9E71297E485B7AEF312C2
    // Y A0: 1D9BEFCD05A5323E6DA4D435F3B617CDB3AF83285C2DF711EF39C01571827F9D
    // Y A1: 275DC4A288D1AFB3CBB1AC09187524C7DB36395DF7BE3B99E673B13A075A65EC
    uint256 constant nG2x0 = 0x1800DEEF121F1E76426A00665E5C4479674322D4F75EDADD46DEBD5CD992F6ED;
    uint256 constant nG2x1 = 0x198E9393920D483A7260BFB731FB5D25F1AA493335A9E71297E485B7AEF312C2;
    uint256 constant nG2y0 = 0x1D9BEFCD05A5323E6DA4D435F3B617CDB3AF83285C2DF711EF39C01571827F9D;
    uint256 constant nG2y1 = 0x275DC4A288D1AFB3CBB1AC09187524C7DB36395DF7BE3B99E673B13A075A65EC;

    function verifyMessage(
        bytes memory message,
        G2Point memory pubKey,
        G1Point memory signature
    ) public view returns (bool) {
        uint256[2] memory messageAsG1 = hashToPoint(message);
        G1Point memory messageHashPoint = G1Point(messageAsG1[0], messageAsG1[1]);
        bool ok = verify(
            messageHashPoint,
            pubKey,
            signature
        );
        return ok;
    }

    //signature G1, pubKey G2, message G1
    function verify(
        G1Point memory message,
        G2Point memory pubKey,
        G1Point memory signature
    ) public view returns (bool) {
        uint256[2] memory messageAsG1 = [message.X, message.Y];
        uint256[4] memory pubKeyAsG2 = [pubKey.X[0], pubKey.X[1], pubKey.Y[0], pubKey.Y[1]];
        uint256[2] memory signatureAsG1 = [signature.X, signature.Y];
        return verifySingle(
            signatureAsG1,
            pubKeyAsG2,
            messageAsG1
        );
    }

    function verifySingle(
        uint256[2] memory signature, // small signature
        uint256[4] memory pubkey, // big public key: 96 bytes
        uint256[2] memory message
    ) internal view returns (bool) {
        uint256[12] memory input = [
            signature[0],
            signature[1],
            nG2x1,
            nG2x0,
            nG2y1,
            nG2y0,
            message[0],
            message[1],
            pubkey[1],
            pubkey[0],
            pubkey[3],
            pubkey[2]
        ];
        uint256[1] memory out;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, 384, out, 0x20)
            switch success
                case 0 {
                    invalid()
                }
        }
        require(success, "");
        return out[0] != 0;
    }
}
