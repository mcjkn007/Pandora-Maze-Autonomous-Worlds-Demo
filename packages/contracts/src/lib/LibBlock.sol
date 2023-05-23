// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { GameConfigComponentData as GameConfig} from "../codegen/Tables.sol";
import { LibConfig} from "./LibConfig.sol";
import { LibRand} from "./LibRand.sol";
import { GameConfigType, RemoveRuleType } from "../codegen/Types.sol";

struct BlockType {
    uint32 id;
    uint32 x;
    uint32 y;
    uint32 level;
    uint32 blockType;
    uint8 status;
    // a list of block id. 
    // Note that all block id are incremented by 1.
    uint32[] higherThanBlocks;
    // a list of block id. 
    // Note that all block id are incremented by 1.
    uint32[] lowerThanBlocks;
  }
library LibBlock {
  /*
   * @dev Return the final score if the given _opts is valid according to _config and _seed.
   */
  function Verify(uint32[] calldata _opts, GameConfig memory _config, uint _seed) public pure returns (bool pass, uint score) {
    BlockType[] memory blocks = CreateBlocks(_config, _seed);
    uint blockLength = blocks.length;
    uint8[] memory statusChecker = new uint8[](blockLength);
    /*
     * if slotNum = 7, slots would be like(id*=id+1, type*=type+1):
     *   index: 0 ....  6    7 ..... 13
     *   value: id* .. id* type* .. type*
     */
    uint[] memory slots = new uint[](LibConfig.getConfigValue(_config, GameConfigType.SlotNum) * 2);
    uint optsLength = _opts.length;
    for (uint i; i < optsLength; ++i) {
      uint id = _opts[i];
      if (statusChecker[id] == 0) {
        if (moveBlockIntoSlot(blocks, slots, id)) {
          return (pass, score);
        }
        ++statusChecker[id];
      } else if (statusChecker[id] == 1) {
        (uint obtainedScore, uint[] memory clearedBlocks) = clearSlot(_config, slots, id+1, uint(blocks[id].blockType)+1);
        score += obtainedScore;
        uint maxMatch = clearedBlocks.length;
        for (uint j; j < maxMatch; ++j) {
          uint cleared = clearedBlocks[j];
          if (cleared == 0) {
            break;
          }
          ++statusChecker[--cleared];
        }
      } else {
        revert("this block has already been cleared");
      }
    }

    // check whether there is still uncleared block
    uint sum;
    for (uint i; i < blockLength; ++i) {
      sum += statusChecker[i];
    }
    if (sum == blockLength * 2) {
      pass = true;
    } else {
      revert("game not complete");
    }
  }

  function moveBlockIntoSlot(BlockType[] memory _blocks, uint[] memory _slots, uint _id) internal pure returns (bool isOver){
    BlockType memory targetBlk = _blocks[_id];
    require(targetBlk.lowerThanBlocks[0] == 0, "moving a block not on top");
    uint slotNum = _slots.length / 2;
    for (uint i; i < slotNum; ++i) {
      if (_slots[i] == 0) {
        // In order to find unset slot by default value 0, we increment id and type inserted into slot by 1.
        _slots[i] = _id + 1;
        _slots[i+slotNum] = uint(targetBlk.blockType) + 1;
        uint hLength = targetBlk.higherThanBlocks.length;
        for (uint j; j < hLength; ++j) {
          uint currentId = uint(targetBlk.higherThanBlocks[j]);
          if (currentId == 0) {
            break;
          }
          --currentId;
          BlockType memory currentBlk = _blocks[currentId];
          uint lLength = currentBlk.lowerThanBlocks.length;
          for (uint k; k < lLength; ++k) {
            if (uint(currentBlk.lowerThanBlocks[k]) == _id + 1) {
              currentBlk.lowerThanBlocks[k] = 0;
              break;
            }
            // note what if we don't find block _id in blk's lowerThanBlocks?
          }
          _blocks[currentId] = currentBlk;
        }
        return isOver;
      }
    }
    isOver = true;
  }

  /*
   * @dev Return the obtained score for this clearing operation.
   */
  function clearSlot(GameConfig memory _config, uint[] memory _slots, uint _id, uint _type) internal pure returns (uint256, uint[] memory) {
    uint minMatch = uint(LibConfig.getConfigValue(_config, GameConfigType.ComposeNumMin));
    uint maxMatch = uint(LibConfig.getConfigValue(_config, GameConfigType.ComposeNumMax));
    uint8 removeRule = uint8(LibConfig.getConfigValue(_config, GameConfigType.RemoveRule));
    require(minMatch <= maxMatch, "minMatch should be less than or equal to maxMatch");
    if (removeRule == uint8(RemoveRuleType.Continue)) {
      return clearContinueSlot(_slots, minMatch, maxMatch, _id);
    } else {
      return clearDiscreteSlot(_slots, minMatch, maxMatch, _id, _type);
    }
  }

  function clearDiscreteSlot(uint[] memory _slots, uint _minMatch, uint _maxMatch, uint _id, uint _type) internal pure returns (uint256, uint[] memory) {
    uint slotNum = _slots.length / 2;
    uint[] memory clearedBlocks = new uint[](_maxMatch);
    uint matchNum;

    {
      bool targetIncluded;
      for (uint i; i < slotNum; ++i) {
        if (matchNum == _maxMatch) {
          if (!targetIncluded) {
            clearedBlocks[_maxMatch-1] = _id;
          }
          break;
        }
        if (_slots[i+slotNum] == _type) {
          if (_slots[i] == _id) {
            targetIncluded = true;
          }
          clearedBlocks[matchNum] = _slots[i];
          ++matchNum;
        }
      }
    }

    if (matchNum < _minMatch) {
      revert("insufficient match number");
    }    

    for ((uint i, uint j)=(0, 0); i < slotNum; ++i) {
      while (j < _maxMatch && _slots[i+j] == clearedBlocks[j]) {
        ++j;
      }
      (_slots[i], _slots[i+slotNum]) = (i+j) < slotNum ? (_slots[i+j], _slots[i+j+slotNum]) : (0, 0);
    }

    return (1 << (matchNum - _minMatch), clearedBlocks);
  }

  function clearContinueSlot(uint[] memory _slots, uint _minMatch, uint _maxMatch, uint _id) internal pure returns (uint256, uint[] memory) {
    uint slotNum = _slots.length / 2;
    for (uint i; i < slotNum; ++i) {
      // find the target slot i
      if (_slots[i] == _id) {
        uint matchNum = 1;
        uint clearFrom = i;
        // iterate slots before i
        for (uint j = i; j > 0 ; --j) {
          // when a slot ahead has different type
          if (_slots[j+slotNum-1] != _slots[j+slotNum]) {
            break;
          }
          ++matchNum;
          --clearFrom;
        }
        // iterate slots after i
        for (uint j = i + 1; j < slotNum; ++j) {
          // when a followed slot has different type
          if (_slots[j+slotNum] != _slots[j+slotNum-1]) {
            break;
          }
          ++matchNum;
        }
        // check for sufficient match number
        if (matchNum >= _minMatch) {
          if (matchNum > _maxMatch) {
            matchNum = _maxMatch;
          }
          uint[] memory clearedBlocks = new uint[](_maxMatch);
          for (uint j; j < matchNum; ++j) {
            clearedBlocks[j] = _slots[j+clearFrom];
          }
          for (uint j = clearFrom; j < slotNum; ++j) {
            (_slots[j], _slots[j+slotNum]) = (j+matchNum) < slotNum ? (_slots[j+matchNum], _slots[j+matchNum+slotNum]) : (0, 0);
          }
          return (1 << (matchNum - _minMatch), clearedBlocks);
        }
        revert("insufficient match number");
      }
    }
    // should not happen
    revert("serious error: no matched slot");
  }
  
  function CreateBlocks(GameConfig memory gameConfig , uint256 seed) public pure returns (BlockType[] memory) {
    uint32 blockNumUnit = getBlockNumUnit(gameConfig);
    require(blockNumUnit < (1 << 32) - 1, "too many blocks, should be less than (1<<32)-1");
    BlockType[] memory AllBlockArray = new BlockType[](blockNumUnit);
    
    uint32 typeNum = LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
    (uint256 s,uint32[] memory randomArray) = getRandomArray(gameConfig,seed);
    uint32[] memory totalArray = new uint32[](blockNumUnit);
    for (uint256 i = 0; i < blockNumUnit; i++) {
      totalArray[i] =randomArray[i % typeNum];
    }

    seed = shuffleBlocks(totalArray,s);

    for (uint256 i = 0; i < blockNumUnit; i++) {
      AllBlockArray[i] =  BlockType({
        id: uint32(i),
        x:0,
        y:0,
        level: uint32(i),
        status: 0,
        blockType: uint32(totalArray[i]),
        higherThanBlocks:new uint32[](blockNumUnit),
        lowerThanBlocks:new uint32[](blockNumUnit)
      }) ;
    }
    

    // place those blocks at random position one by one and manage the up-down relationship between already placed blocks
    // newly placed block should always be on top of already placed blocks if there are.  
    initializeBlocks(gameConfig, AllBlockArray, seed);

    return AllBlockArray;
  }

  function getBlockNumUnit(GameConfig memory gameConfig)internal pure returns (uint32){
      uint32 composeNumMax =  LibConfig.getConfigValue(gameConfig, GameConfigType.ComposeNumMax);
      uint32 typeNum =  LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
      return  composeNumMax * 2 * typeNum;
  }
  function getRandomArray(GameConfig memory gameConfig, uint256 seed)internal pure returns (uint256,uint32[] memory){
      uint32 totalNum =  LibConfig.getConfigValue(gameConfig, GameConfigType.TotalRangeNum);
      uint32 typeNum = LibConfig.getConfigValue(gameConfig, GameConfigType.TypeNum);
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
  function shuffleBlocks(uint32[] memory totalArray, uint256 seed)internal pure returns (uint256){
    uint length = totalArray.length;
    for (uint256 i = 0; i < length; i++) {
      (uint256 s,uint256 j) = LibRand.randomNum(seed,0,i+1);
      seed = s;
      uint32 a = totalArray[i];
      totalArray[i] = totalArray[j];
      totalArray[j] = a;
    }
    return seed;
  }

  function initializeBlocks(GameConfig memory _gameConfig, BlockType[] memory _blocks, uint _seed) internal pure {
    uint blkNumPerRound = LibConfig.getConfigValue(_gameConfig, GameConfigType.LevelBlockInitNum);
    uint round = LibConfig.getConfigValue(_gameConfig, GameConfigType.LevelNum);
    uint leftBlkNum = _blocks.length;
    for (uint i; i < round; ++i) {
      uint blkNum;
      if (i == round-1) {
        blkNum = leftBlkNum;
      } else {
        blkNum = blkNumPerRound < leftBlkNum ? blkNumPerRound : leftBlkNum;
      }
      _seed = placeBlocks(_gameConfig, _blocks, i, blkNum, _seed);
      leftBlkNum -= blkNum;
      if (leftBlkNum == 0) {
        break;
      }
    }
  }

  function placeBlocks(GameConfig memory _gameConfig, BlockType[] memory _blocks, uint _round, uint _num, uint _seed) internal pure returns (uint) {
    uint blkNumPerRound = LibConfig.getConfigValue(_gameConfig, GameConfigType.LevelBlockInitNum);
    uint start = _round == 0 ? 0 : _round * blkNumPerRound;
    uint end = start + _num;
    for (uint i=start; i < end; ++i) {
      _seed = genUniqueRandomPosition(_gameConfig, _blocks, _round, start, i, _seed);
      updateUpDownRelationship(_gameConfig, _blocks, i);
    }
    return _seed;
  }

  function getBoarder(GameConfig memory _gameConfig, uint _round) internal pure returns (uint left, uint right, uint up, uint down) {
    uint32 rightMax = (LibConfig.getConfigValue(_gameConfig, GameConfigType.ViewWidth) - 1) *
      LibConfig.getConfigValue(_gameConfig, GameConfigType.CardSize);
    uint32 upMax = (LibConfig.getConfigValue(_gameConfig, GameConfigType.ViewHeight) - 1) *
      LibConfig.getConfigValue(_gameConfig, GameConfigType.CardSize);
    // step represents the shrink speed of the map for placing blocks
    uint32 step = LibConfig.getConfigValue(_gameConfig, GameConfigType.BorderStep);
    uint maxShrinkage = (_round/4 + 1) * 2 * step;
    require(maxShrinkage < rightMax, "inappropriate config");
    require(maxShrinkage < upMax, "inappropriate config");
    left = _round/4 * step;
    right = rightMax - (_round+1)/4 * step;
    down = (_round+2)/4 * step;
    up = upMax - (_round+3)/4 * step;
  }

  /**
   * @dev generate unique(per round) and random position for a block.
   */
  function genUniqueRandomPosition(GameConfig memory _gameConfig, BlockType[] memory _blocks, uint _round, uint _start, uint _target, uint _seed) internal pure returns (uint) {
    (uint left, uint right, uint up, uint down) = getBoarder(_gameConfig, _round);
    uint x;
    uint y;
    bool unique;
    while (!unique) {
      (_seed, x) = LibRand.randomNum(_seed, left, right);
      (_seed, y) = LibRand.randomNum(_seed, down, up);
      uint positionChecker = (x << 32) + y;
      unique = true;
      for (uint i = _start; i < _target; ++i) {
        BlockType memory currentBlk = _blocks[i];
        if ((uint(currentBlk.x) << 32) + currentBlk.y == positionChecker) {
          unique = false;
          break;
        }
      }
    }
    _blocks[_target].x = uint32(x);
    _blocks[_target].y = uint32(y);
    return _seed;
  }

  /**
   * @dev find all blocks that are covered by target block, and update fields related to up-down relationship.
   */
  function updateUpDownRelationship(GameConfig memory _gameConfig, BlockType[] memory _blocks, uint _target) internal pure {
    int64 blockSize = int64(uint64(LibConfig.getConfigValue(_gameConfig, GameConfigType.CardSize)));
    BlockType memory targetBlk = _blocks[_target];
    int64 left = int64(uint64(targetBlk.x)) - blockSize;
    int64 right = int64(uint64(targetBlk.x)) + blockSize;
    int64 down = int64(uint64(targetBlk.y)) - blockSize;
    int64 up = int64(uint64(targetBlk.y)) + blockSize;
    for (uint i; i < _target; ++i) {
      BlockType memory currentBlk = _blocks[i];
      if (int64(uint64(currentBlk.x)) >= left && int64(uint64(currentBlk.x)) <= right &&
        int64(uint64(currentBlk.y)) >= down && int64(uint64(currentBlk.y)) <= up) {
        // add block i's id into target block's higherThanBlocks
        uint hLength = targetBlk.higherThanBlocks.length;
        for (uint j; j < hLength; ++j) {
          if (targetBlk.higherThanBlocks[j] == 0) {
            // increment id by 1 before inserting into higherThanBlocks
            targetBlk.higherThanBlocks[j] = currentBlk.id + 1;
            break;
          }
        }
        // add target block's id into block i's lowerThanBlocks
        uint lLength = currentBlk.lowerThanBlocks.length;
        for (uint j; j < lLength; ++j) {
          if (currentBlk.lowerThanBlocks[j] == 0) {
            // increment id by 1 before inserting into lowerThanBlocks
            currentBlk.lowerThanBlocks[j] = targetBlk.id + 1;
            break;
          }
        }
        _blocks[i] = currentBlk;
      }
    }
    _blocks[_target] = targetBlk;
  }
}  