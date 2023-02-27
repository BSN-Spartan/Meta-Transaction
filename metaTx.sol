// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MetaTx is ERC20 {
    constructor() ERC20("MyToken", "MTK") {}

    mapping(address => uint256) private _nonces;

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    bytes32 public DOMAIN_SEPARATOR =
        keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes("metaTx")),
                keccak256(bytes("1.0")),
                block.chainid,
                address(this)
            )
        );

    bytes32 private constant _TYPEHASH =
        keccak256(
            "metaTransferFrom(address from,address to,uint256 amount,uint256 nonce,uint256 deadline,uint8 v,bytes32 r,bytes32 s)"
        );

    function getNonce(address from) public view returns (uint256) {
        return _nonces[from];
    }

    function metaTransferFrom(
        address from,
        address to,
        uint256 amount,
        uint256 nonce,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(_TYPEHASH, from, to, amount, nonce, deadline)
                )
            )
        );
        require(ecrecover(digest, v, r, s) == from, "ERC20:invalid signature");
        require(
            deadline == 0 || block.timestamp <= deadline,
            "ERC20:expired signature"
        );
        _nonces[from]++;
        require(nonce == _nonces[from], "ERC20:invalid nonce");

        _transfer(from, to, amount);
    }
}
