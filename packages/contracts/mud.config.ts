import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  namespace: "game",
  systems: {
    IncrementSystem: {
      name: "increment",
      openAccess: true,
    },
    JoinGameSystem: {
      name: "joinGame",
      openAccess: true,
    },
    PlayGameSystem: {
      name: "playGame",
      openAccess: true,
    }
  },
  enums: {
    GameConfigType: ["SlotNum", "ComposeNumMin", "ComposeNumMax", "TypeNum", "LevelBlockInitNum",
     "BorderStep", "LevelNum", "CardSize", "ViewWidth", "ViewHeight", "TotalRangeNum", "StageNum", "RemoveRule"],
    RemoveRuleType: ["Continue", "Discrete"],
  },
  tables: {
    Counter: {
      keySchema: {},
      schema: "uint32",
    },
    PlayerComponent:"bool",
    SeedComponent: {
      keySchema: {},
      schema: {
        value: "uint256",
        updatePeriod: "uint256",
        startFrom: "uint256"
      }
    },
    StageComponent: "uint32",
    ScoreComponent: "uint32",
    RankComponent: {
      schema: { 
        addr: "address[10]", 
        score: "uint32[10]" 
      },
    },
    GameConfigComponent:{
      keySchema: {},
      schema: {
        config1: "uint256",
        config2: "uint256"
      },
    }
  },
});
