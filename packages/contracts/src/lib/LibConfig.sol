// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { GameConfigComponentData as GameConfig } from "../codegen/Tables.sol";
import { GameConfigType } from "../codegen/Types.sol";
 
library LibConfig {
  function getConfigValue(GameConfig memory config , GameConfigType configType) internal pure returns (uint32) {
      
        uint32 result = 0;
        uint32 _type = uint32(configType);
        if(_type < uint32(GameConfigType.ViewWidth)){
            uint256 t = config.arg0 >>(32*(_type));
            result = uint32(t % (2 ** 32));
        }
        else{
            uint256 t = config.arg1 >>(32*(_type-uint32(GameConfigType.ViewWidth)));
            result = uint32(t % (2 ** 32));
        }
        return result;
  }
}  