const { ethers } = require("ethers");

const { keccak256, defaultAbiCoder, toUtf8Bytes, solidityPack } = require("ethers/lib/utils");

var from = "";
var to = "";
var amount = 0;
var nonce = 0;
var deadline = 0;
var DOMAIN_SEPARATOR = "";
var privateKey = ""; 

function getMetaTransferFromDigest(
    from,
    to,
    amount,
    nonce,
    deadline,
    DOMAIN_SEPARATOR,
    TYPEHASH
) {
    return keccak256(
        solidityPack(
            ['bytes1', 'bytes1', 'bytes32', 'bytes32'],
            [
                '0x19',
                '0x01',
                DOMAIN_SEPARATOR,
                keccak256(
                    defaultAbiCoder.encode(
                        ['bytes32', 'address', 'address', 'uint256', 'uint256','uint256'],
                        [TYPEHASH, from,to, amount, nonce, deadline]
                    )
                ),
            ]
        )
    )
}

const metaTransferFrom = keccak256(
    toUtf8Bytes('metaTransferFrom(address from,address to,uint256 amount,uint256 nonce,uint256 deadline,uint8 v,bytes32 r,bytes32 s)')
)

//生成签名sign
async function metaTransferGenerateSignature() {
    var MetaTx_TYPEHASH = metaTransferFrom;
    var signer = new ethers.utils.SigningKey(privateKey);
    var digest = getMetaTransferFromDigest(from,to,amount,nonce,deadline,DOMAIN_SEPARATOR,MetaTx_TYPEHASH);
    var signature = signer.signDigest(digest)
    console.log(signature);
}

if (require.main === module) {
    metaTransferGenerateSignature();
}
