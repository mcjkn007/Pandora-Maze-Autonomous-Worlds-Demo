import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
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
