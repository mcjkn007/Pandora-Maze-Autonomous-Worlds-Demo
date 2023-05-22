// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { PlayerComponent as Player } from "../codegen/Tables.sol";

contract joinGameSystem is System {
  function joinGame() public {
    Player.set(bytes32(uint256(uint160(_msgSender()))), true);
  }
}