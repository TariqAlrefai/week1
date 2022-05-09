pragma circom 2.0.0;

// [assignment] Modify the circuit below to perform a multiplication of three signals

template Multiplier3 () {  

   signal input x; 
   signal input y; 
   signal input z; 
   signal temp;
   signal output r;
 
   temp <== x*y; 
   temp*z ==> r;
}

component main = Multiplier3();