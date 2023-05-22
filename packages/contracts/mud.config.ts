import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  enums: {
    GameConfigType: ["SlotNum", "ComposeNumMin", "ComposeNumMax", "TypeNum", "LevelBlockInitNum",
     "BorderStep", "LevelNum", "CardSize", "ViewWidth", "ViewHeight", "AlphabetNum", "ColorNum"],
  },
  tables: {
    Counter: {
      keySchema: {},
      schema: "uint32",
    },
    PlayerComponent:"bool",
    SeedComponent: "uint256",
    StageComponent: "uint32",
    ScoreComponent: "uint32",
    RankComponent: {
      schema: { 
        addr: "address[10]", 
        score: "uint32[10]" 
      },
    },
    GameConfigComponent:{
      schema: {
        config1: "uint256",
        config2: "uint256"
      },
    }
  },
});
