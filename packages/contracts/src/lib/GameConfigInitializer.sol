// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { IStore } from "@latticexyz/store/src/IStore.sol";
import { GameConfigComponent } from "../codegen/Tables.sol";

library GameConfigInitializer {
  function init(IStore world) internal { 
    uint256 arg0 = 7;//slot
    arg0 += 2<<32;//composeNumbMin;
    arg0 += 7<<64;//composeNumbMax;
    arg0 += 16<<96;//typeNum;
    arg0 += 16<<128;//levelBlockInitNum;
    arg0 += 16<<160;//borderStep;
    arg0 += 16<<192;//levelNum;
    arg0 += 16<<224;//cardSize;
 
    uint256 arg1 = 9;//viewWidth
    arg1 += 9<<32;//viewHeight
    arg1 += 25<<64;//AlphabetNum
    arg1 += 7<<96;//ColorNum

    uint256 configHash = uint256(keccak256(abi.encodePacked(arg0, arg1)));

    GameConfigComponent.set(world, configHash, arg0, arg1);
  }
}