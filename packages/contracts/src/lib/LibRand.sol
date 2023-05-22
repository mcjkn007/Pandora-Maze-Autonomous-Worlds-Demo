// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
 
library LibRand {
    uint256 constant _a = 214013;
    uint256 constant _b = 2531011;
    uint256 constant _m = 4294967296;
 
    function rand(uint256 seed,uint256 length) internal pure returns (uint256,uint256){
        seed = (seed  * _a + _b) % _m;
        return (seed,seed % length);
    }
    function randomNum(uint256 seed,uint256 minNum,uint256 maxNum)internal pure returns (uint256,uint256){
        (uint256 s,uint256 r) = rand(seed,maxNum-minNum) ;
        return (s,r+minNum);
    }

    function rand1(uint256 seed,uint256 length) internal pure returns (uint256){
        seed = (seed  * _a + _b) % _m;
        return seed % length;
    }
    
}
