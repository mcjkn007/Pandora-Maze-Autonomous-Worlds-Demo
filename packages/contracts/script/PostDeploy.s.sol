// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";
import { GameConfigInitializer } from "../src/lib/GameConfigInitializer.sol";
import { SeedComponent as Seed } from "../src/codegen/Tables.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // ------------------ INITIALIZATION ------------------

    GameConfigInitializer.init(IWorld(worldAddress));

    Seed.setUpdatePeriod(IWorld(worldAddress), 86400);
    Seed.setStartFrom(IWorld(worldAddress), block.timestamp - (block.timestamp % 86400));

    vm.stopBroadcast();
  }
}
