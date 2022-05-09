#!/bin/bash

# [assignment] create your own bash script to compile Multipler3.circom using PLONK below

cd contracts/circuits

mkdir _plonkMultiplier3

if [ -f ./powersOfTau28_hez_final_10.ptau ]; then
    echo "powersOfTau28_hez_final_10.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_10.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_10.ptau
fi

echo "Compiling Multiplier3.circom..."

# compile circuit

circom Multiplier3.circom --r1cs --wasm --sym -o _plonkMultiplier3
snarkjs r1cs info _plonkMultiplier3/Multiplier3.r1cs

# Start a new zkey and make a contribution

snarkjs plonk setup _plonkMultiplier3/Multiplier3.r1cs powersOfTau28_hez_final_10.ptau _plonkMultiplier3/circuit_final.zkey
# snarkjs zkey contribute _plonkMultiplier3/circuit_0000.zkey _plonkMultiplier3/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey _plonkMultiplier3/circuit_final.zkey _plonkMultiplier3/verification_key.json

# generate solidity contracts

snarkjs zkey export solidityverifier _plonkMultiplier3/circuit_final.zkey ../_plonkMultiplier3Verifier.sol

# generate witness
node "_plonkMultiplier3/Multiplier3_js/generate_witness.js" _plonkMultiplier3/Multiplier3_js/Multiplier3.wasm input.json _plonkMultiplier3/witness.wtns
        
# generate proof
snarkjs plonk prove _plonkMultiplier3/circuit_final.zkey _plonkMultiplier3/witness.wtns _plonkMultiplier3/proof.json _plonkMultiplier3/public.json

# verify proof
snarkjs plonk verify _plonkMultiplier3/verification_key.json _plonkMultiplier3/public.json _plonkMultiplier3/proof.json

# generate call
snarkjs zkey export soliditycalldata _plonkMultiplier3/public.json _plonkMultiplier3/proof.json > _plonkMultiplier3/call.txt

cd ../..

