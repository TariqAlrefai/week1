#!/bin/bash

cd ./projects/zkPuzzles/circuits

mkdir sudoku

if [ -f ./powersOfTau28_hez_final_15.ptau ]; then
    echo "powersOfTau28_hez_final_15.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_15.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_15.ptau
fi


echo "Compiling sudoku.circom..."

# compile circuit

circom sudoku.circom --r1cs --wasm --sym -o sudoku
snarkjs r1cs info sudoku/sudoku.r1cs

# Start a new zkey and make a contribution

snarkjs groth16 setup sudoku/sudoku.r1cs powersOfTau28_hez_final_15.ptau sudoku/circuit_0000.zkey
snarkjs zkey contribute sudoku/circuit_0000.zkey sudoku/circuit_final.zkey --name="1st Contributor Name" -v -e="random text"
snarkjs zkey export verificationkey sudoku/circuit_final.zkey sudoku/verification_key.json

# generate solidity contract
snarkjs zkey export solidityverifier sudoku/circuit_final.zkey ../sudokuVerifier.sol


node sudoku/sudoku_js/generate_witness.js "sudoku/sudoku_js/sudoku.wasm" ./input.json ./witness.wtns
cd ..
echo "Inputs are valid, witness is generated"

# # Generate public.json
# snarkjs groth16 prove "sudoku/circuit_0000.zkey" witness.wtns proof.json public.json

# # Check proof is correct
# snarkjs groth16 verify sudoku/verification_key.json public.json proof.json

cd ../..