import { mudConfig } from "@latticexyz/world/register";

export default mudConfig({
  tables: {
    PlayerComponent:"bool",
    SeedComponent: "uint256",
    StageComponent: "uint32",
    ScoreComponent: "uint32",
    RankComponent: {
      schema: { 
        address: "uint256", 
        score: "uint32" 
      },
    },
    GameConfigComponent:{
      schema: {
        optionArray: "uint32[]", // Store supports dynamic arrays
      },
    }
  },
});
