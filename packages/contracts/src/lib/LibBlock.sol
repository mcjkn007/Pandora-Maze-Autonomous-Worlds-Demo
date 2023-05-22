// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { GameConfigComponent as GameConfig} from "../codegen/Tables.sol";
import { LibConfig} from "./LibConfig.sol";
import { LibRand} from "./LibRand.sol";
import { GameConfigType } from "../codegen/Types.sol";
struct BlockType {
    uint32 id;
    uint32 x;
    uint32 y;
    uint32 level;
    uint32 blockType;
    uint8 status;
    uint256 higherThanBlocks;
    uint256 lowerThanBlocks;
  }
library LibBlock {
  function CreateBlocks(GameConfig memory gameConfig , uint256 seed) internal pure {
    uint32 blockNumUnit = getBlockNumUnit(gameConfig);
    uint32 typeNum = LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
    (uint256 s,uint32[] memory randomArray) = getRandomArray(gameConfig,seed);
    uint32[] memory totalArray = new uint32[](blockNumUnit);
    for (uint256 i = 0; i < blockNumUnit; i++) {
      totalArray[i] =randomArray[i % typeNum];
    }

    seed = shuffleBlocks(totalArray,s);

    BlockType[] memory AllBlockArray = new BlockType[](blockNumUnit);
    for (uint256 i = 0; i < blockNumUnit; i++) {
      AllBlockArray[i] =  BlockType({
        id: uint32(i),
        x:0,
        y:0,
        level: 0,
        status: 0,
        blockType: uint32(totalArray[i]),
        higherThanBlocks:0,
        lowerThanBlocks:0
      }) ;
    }

    // place those blocks at random position one by one and manage the up-down relationship between already placed blocks
    // newly placed block should always be on top of already placed blocks if there is.  
    initializeBlocks(AllBlockArray, seed);
  }

  function getTotalBlocks(GameConfig memory gameConfig , uint256 seed) internal pure returns (uint32[] memory){
      uint32 blockNumUnit = getBlockNumUnit(gameConfig);
      uint32 typeNum = LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
      (uint256 s,uint32[] memory randomArray) = getRandomArray(gameConfig,seed);
      uint32[] memory totalArray = new uint32[](blockNumUnit);
        for (uint256 i = 0; i < blockNumUnit; i++) {
          totalArray[i] =randomArray[i % typeNum];
      }
      return totalArray;
  }
  function getBlockNumUnit(GameConfig memory gameConfig) internal pure returns (uint32){
      uint32 colorNum =  LibConfig.getConfigValue(gameConfig, GameConfigType.ComposeNumMax);
      uint32 alphabetNum =  LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
      return  colorNum * 2 * alphabetNum;
  }
  function getRandomArray(GameConfig memory gameConfig , uint256 seed) internal pure returns (uint256,uint32[] memory){
      uint32 colorNum =  LibConfig.getConfigValue(gameConfig, GameConfigType.ColorNum);
      uint32 alphabetNum =  LibConfig.getConfigValue(gameConfig, GameConfigType.AlphabetNum);
      uint32 typeNum = LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
      uint32 totalNum = colorNum*alphabetNum;
      uint32[] memory typeArray = new uint32[](typeNum);
      uint32 typeCount = 0;
      uint256 bitFlag = 0;
      while(typeCount < typeNum){
         
        (uint256 s,uint256 index) = LibRand.randomNum(seed,0,totalNum);
        seed = s;
        if(bitFlag & 1<<index == 1){
          continue;
        }
        bitFlag += 1<<index;
        typeArray[typeCount] = uint32(index);
        typeCount += 1;
      }
      return (seed,typeArray);
  }
  function shuffleBlocks(uint32[] memory totalArray, uint256 seed) internal pure returns (uint256){
    for (uint256 i = 0; i < totalArray.length; i++) {
      (uint256 s,uint256 j) = LibRand.randomNum(seed,0,i+1);
      seed = s;
      uint32 a = totalArray[i];
      totalArray[i] = totalArray[j];
      totalArray[j] = a;
    }
    return seed;
  }

  function initializeBlocks(BlockType[] memory _blocks, uint256 _seed) internal pure {
    uint32 blkNumPerRound = LibConfig.getConfigValue(gameConfig, GameConfigType.LevelBlockInitNum);
    uint32 round = LibConfig.getConfigValue(gameConfig, GameConfigType.LevelNum);
    uint32 leftBlkNum = _blocks.length;
    for (uint i; i < round; ++i) {
      uint32 blkNum = blkNumPerRound < leftBlkNum ? blkNumPerRound : leftBlkNum;
      if (i == round-1) {
        blkNum = leftBlkNum;
      }
      if (blkNum == 0) {
        break;
      }
      placeBlocks(_blocks, i, blkNum, _seed);
    }
  }

  function placeBlocks(BlockType[] memory _blocks, uint _round, uint _num, uint256 _seed) internal pure {
    (uint32 left, uint32 right, uint32 up, uint32 down) = getBoarder(_round);
    uint64[] memory positionChecker = new uint64[](_num);
    for (uint i; i < _num; ++i) {
      placeBlock(positionChecker, i, left, right, up, down, _seed);
      manageBlocksRelationship();
    }
  }

  function getBoarder(uint _round) internal pure returns (uint32 left, uint32 right, uint32 up, uint32 down) {
    uint32 rightMax = (LibConfig.getConfigValue(gameConfig, GameConfigType.ViewWidth) - 1) *
      LibConfig.getConfigValue(gameConfig, GameConfigType.CardSize);
    uint32 upMax = (LibConfig.getConfigValue(gameConfig, GameConfigType.ViewHeight) - 1) *
      LibConfig.getConfigValue(gameConfig, GameConfigType.CardSize);
    // step represents the shrink speed of the map for placing blocks
    uint32 step = LibConfig.getConfigValue(gameConfig, GameConfigType.BorderStep);
    require((_round/4 + 1) * 2 * step < rightMax, "inappropriate config");
    require((_round/4 + 1) * 2 * step < upMax, "inappropriate config");
    left = _round/4 * step;
    right = rightMax - (_round+1)/4 * step;
    down = (_round+2)/4 * step;
    up = upMax - (_round+3)/4 * step;
  }

  function placeBlock(uint64[] memory _positionChecker, uint _index, uint32 left, uint32 right, uint32 up, uint32 down, uint256 _seed) internal pure returns (uint256) {
    assert(_index < _positionChecker.length);
    while (true) {
      uint32 x;
      uint32 y;
      (_seed, x) = LibRand.randomNum(_seed, left, right);
      (_seed, y) = LibRand.randomNum(_seed, up, down);
      _positionChecker[_index] = (x << 32) + y;
      bool isDifferent = true;
      for (uint i; i < _index; ++i) {
        if (_positionChecker[i] == _positionChecker[_index]) {
          isDifferent = false;
          break;
        }
      }
      if (isDifferent) {
        break;
      }
    }
    return _seed;
  }
}  