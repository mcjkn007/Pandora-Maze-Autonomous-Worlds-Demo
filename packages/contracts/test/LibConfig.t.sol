pragma solidity >=0.8.10;

import "forge-std/Test.sol";
import { GameConfigComponentData as GameConfig } from "../src/codegen/Tables.sol";
import { LibConfig } from "../src/lib/LibConfig.sol";
import { GameConfigType, RemoveRuleType } from "../src/codegen/Types.sol";

contract LibConfigTest is Test {
    GameConfig testConfig;

    function setUp() public {
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
        arg1 += 25<<64;//TotalRangeNum
        arg1 += 3<<96;//StageNum
        arg1 += uint8(RemoveRuleType.Continue)<<128;//RemoveRule
        testConfig = GameConfig({config1: arg0, config2: arg1});
    }

    function test_SlotIs7() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.SlotNum);
        assertEq(value, 7);
    }

    function test_ComposeNumMinIs2() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.ComposeNumMin);
        assertEq(value, 2);
    }

    function test_ComposeNumMaxIs7() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.ComposeNumMax);
        assertEq(value, 7);
    }

    function test_TypeNumIs16() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.TypeNum);
        assertEq(value, 16);
    }

    function test_LevelBlockInitNumIs16() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.LevelBlockInitNum);
        assertEq(value, 16);
    }

    function test_BorderStepIs16() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.BorderStep);
        assertEq(value, 16);
    }

    function test_LevelNumIs16() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.LevelNum);
        assertEq(value, 16);
    }

    function test_CardSizeIs16() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.CardSize);
        assertEq(value, 16);
    }

    function test_ViewWidthIs9() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.ViewWidth);
        assertEq(value, 9);
    }

    function test_ViewHeightIs9() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.ViewHeight);
        assertEq(value, 9);
    }

    function test_TotalRangeNumIs25() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.TotalRangeNum);
        assertEq(value, 25);
    }

    function test_StageNumIs3() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.StageNum);
        assertEq(value, 3);
    }

    function test_RemoveRuleIs0() public {
        uint32 value = LibConfig.getConfigValue(testConfig, GameConfigType.RemoveRule);
        assertEq(value, 0);
    }
}
