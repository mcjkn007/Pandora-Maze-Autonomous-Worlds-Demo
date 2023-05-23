pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import { BlockType, LibBlock } from "../src/lib/LibBlock.sol";
import { GameConfigComponentData as GameConfig } from "../src/codegen/Tables.sol";
import { RemoveRuleType } from "../src/codegen/Types.sol";

contract LibBlockTest is Test {
    GameConfig testConfig;
    uint seed;

    function setUp() public {
        uint256 arg0 = 7;//slot
        arg0 += 2<<32;//composeNumbMin;
        arg0 += 7<<64;//composeNumbMax;
        arg0 += 1<<96;//typeNum;
        arg0 += 16<<128;//levelBlockInitNum;
        arg0 += 16<<160;//borderStep;
        arg0 += 16<<192;//levelNum;
        arg0 += 44<<224;//cardSize;
    
        uint256 arg1 = 9;//viewWidth
        arg1 += 9<<32;//viewHeight
        arg1 += 25<<64;//TotalRangeNum
        arg1 += 3<<96;//StageNum
        arg1 += uint8(RemoveRuleType.Continue)<<128;//RemoveRule
        testConfig = GameConfig({config1: arg0, config2: arg1});

        seed = 1000;
    }

    function test_CreateBlocks() public {
        BlockType[] memory blocks = LibBlock.createBlocks(testConfig, seed);
        // assert block 0 locates at (248, 219)
        assertEq(blocks[0].x, 248);
        assertEq(blocks[0].y, 219);
        // assert block 0 locates at (346, 309)
        assertEq(blocks[5].x, 346);
        assertEq(blocks[5].y, 309);
        // assert block 10 locates at (12, 351)
        assertEq(blocks[10].x, 12);
        assertEq(blocks[10].y, 351);
        // assert block 0 is under block 6, 7, 11, 13
        assertEq(blocks[0].lowerThanBlocks[0], 7);
        assertEq(blocks[0].lowerThanBlocks[1], 8);
        assertEq(blocks[0].lowerThanBlocks[2], 12);
        assertEq(blocks[0].lowerThanBlocks[3], 14);
        //printBlocks(blocks);
    }
    
    function test_ScoreIs12() public {
        uint8[18] memory sopts = [9,10,2,9,13,7,6,7,5,4,3,8,8,12,11,0,1,11];
        uint32[] memory opts = new uint32[](sopts.length);
        for (uint i; i < sopts.length; ++i) {
            opts[i] = sopts[i];
        }
        (bool pass, uint score) = LibBlock.verify(opts, testConfig, seed);
        assertTrue(pass);
        assertEq(score, 12);
    }

    function test_ScoreIs12Discrete() public {
        // reset removeRule to Discrete
        testConfig.config2 += 1<<128;
        test_ScoreIs12();
    }

    function test_ScoreIs18Discrete() public {
        // reset removeRule to Discrete
        testConfig.config2 += 1<<128;
        // reset composeNumMax to 5
        testConfig.config1 -= 2<<64; 
        // reset typeNum to 2
        testConfig.config1 += 1<<96;
        uint8[26] memory sopts = [17,7,19,17,13,8,12,16,18,12,3,0,0,10,9,1,4,14,6,15,1,11,5,2,2,11];
        uint32[] memory opts = new uint32[](sopts.length);
        for (uint i; i < sopts.length; ++i) {
            opts[i] = sopts[i];
        }
        (bool pass, uint score) = LibBlock.verify(opts, testConfig, seed);
        assertTrue(pass);
        assertEq(score, 18);
    }

    function test_Revert_MovingBlockNotOnTop() public {
        uint32[] memory opts = new uint32[](1);
        opts[0] = 6;
        vm.expectRevert("moving a block not on top");
        LibBlock.verify(opts, testConfig, seed);
    }

    function test_Revert_GameNotComplete() public {
        uint32[] memory opts = new uint32[](3);
        opts[0] = 13;
        opts[1] = 11;
        opts[2] = 13;
        vm.expectRevert("game not complete");
        LibBlock.verify(opts, testConfig, seed);
    }

    function test_Revert_GameIsOver() public {
        uint32[] memory opts = new uint32[](8);
        opts[0] = 13;
        opts[1] = 11;
        opts[2] = 7;
        opts[3] = 6;
        opts[4] = 8;
        opts[5] = 4;
        opts[6] = 5;
        opts[7] = 9;
        (bool pass, uint score) = LibBlock.verify(opts, testConfig, seed);
        assertFalse(pass);
        assertEq(score, 0);
    }

    function test_Revert_AlreadyClearedBlock() public {
        uint32[] memory opts = new uint32[](4);
        opts[0] = 13;
        opts[1] = 11;
        opts[2] = 13;
        opts[3] = 13;
        vm.expectRevert("this block has already been cleared");
        LibBlock.verify(opts, testConfig, seed);
    }

    function test_Revert_InsufficientMatchNum() public {
        uint32[] memory opts = new uint32[](2);
        opts[0] = 13;
        opts[1] = 13;
        vm.expectRevert("insufficient match number");
        LibBlock.verify(opts, testConfig, seed);
    }

    function printBlocks(BlockType[] memory _blocks) private view {
        for (uint i; i < _blocks.length; ++i) {
            console.log("block %d x: %d, y: %d", i, _blocks[i].x, _blocks[i].y);
            for (uint j; j < _blocks[i].lowerThanBlocks.length; ++j) {
                console.log("  lower than blocks %d", _blocks[i].lowerThanBlocks[j]);
            }
        }
    } 
}
