// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { LibConfig } from "../lib/LibConfig.sol";
import { LibBlock } from "../lib/LibBlock.sol";
import { GameConfigType } from "../codegen/Types.sol";
import { PlayerComponent as Player, SeedComponent as Seed } from "../codegen/Tables.sol";
import { StageComponent as Stage, ScoreComponent as Score, RankComponent as Rank, RankComponentData as RankData } from "../codegen/Tables.sol";
import { GameConfigComponent,  GameConfigComponentData as GameConfig } from "../codegen/Tables.sol";

contract PlayGameSystem is System {
  function verifyGamePlay(uint32[] calldata _opts) public {
    bytes32 playerEntity = bytes32(uint256(uint160(_msgSender())));
    uint curTotalScore = Score.get(playerEntity);
    uint curStage = Stage.get(playerEntity);
    GameConfig memory gameConfig = GameConfigComponent.get();
    uint32 stageNum = LibConfig.getConfigValue(gameConfig, GameConfigType.StageNum);

    (bool updated, uint seed) = updateSeed();
    if (updated) {
      curTotalScore = 0;
      curStage = 0;
    }
    // TODO verification
    (bool pass, uint score) = LibBlock.verify(_opts, gameConfig, curTotalScore + seed);
    curTotalScore += score;
    ++curStage;
    if (!pass || curStage == stageNum) {
      curStage = 0;
      updateRank(gameConfig, seed, uint32(curTotalScore));
      curTotalScore = 0;
    }
    Score.set(playerEntity, uint32(curTotalScore));
    Stage.set(playerEntity, uint32(curStage));
  }

  function verify(uint32[] calldata _opts, uint _seed) public pure returns (bool pass, uint score) {}

  function updateSeed() internal returns (bool updated, uint value) {
    value = Seed.getValue();
    uint period = Seed.getUpdatePeriod();
    uint start = Seed.getStartFrom();
    uint newValue = (block.timestamp - start) / period;
    if (newValue == value) {
        return (false, value);
    } {
        Seed.setValue(newValue);
        return (true, newValue);
    }
  }

  function updateRank(GameConfig memory _gameConfig, uint _seed, uint32 _score) internal {
    if (_score == 0) {
      return;
    }
    address player = _msgSender();
    bytes32 rankHash = keccak256(abi.encodePacked(_gameConfig.config1, _gameConfig.config2, _seed));
    RankData memory rank = Rank.get(rankHash);
    address[10] memory addrs = rank.addr;
    uint32[10] memory scores = rank.score;
    if (_score <= scores[9]) {
      return;
    }
    uint insertAt;
    address[10] memory newAddrs;
    uint32[10] memory newScores;
    for (uint i; i < 10; ++i) {
      if (scores[i] < _score) {
        insertAt = i;
        break;
      } else if (addrs[i] == player) {
        return;
      } else {
        newAddrs[i] = addrs[i];
        newScores[i] = scores[i];
      }
    }

    newAddrs[insertAt] = player;
    newScores[insertAt] = _score;

    for ((uint i, uint j) = (insertAt, insertAt+1); i < 9; ++i) {
      if (addrs[i] == player) {
        continue;
      } else if (scores[i] == 0) {
        break;
      } else {
        newAddrs[j] = addrs[i];
        newScores[j] = scores[i];
        ++j;
      }
    }

    rank.addr = newAddrs;
    rank.score = newScores;
    Rank.set(rankHash, rank);
  }
}