
 
export const enum RemoveRuleType {
    CONTINUE,
    DISCONTINUE,
};

export const enum BlockStatusType {
    Normal,
    Clicked,
    Removed
};
export const enum GameResultType {
      DEFEAT,
      VICTORY,  
    }
    
export const enum GameManagerEvent {
    TouchCard = 'TouchCard',
    RestartGame = 'RestartGame'
};

export enum GameConfigType {
      SlotNum,
      ComposeNumMin,
      ComposeNumMax,
      TypeNum,
      LevelBlockInitNum,
      BorderStep,
      LevelNum,
      CardSize,
      ViewWidth,
      ViewHeight,
      TotalRangeNum,
      StageNum,
      RemoveRule
    }
    
  
export interface GameConfig {
   
      slotNum: number;
      
      composeNumMin: number;
   
      composeNumMax: number;
   
      typeNum: number;
   
      levelBlockInitNum: number;
   
      borderStep: number;
   
      levelNum: number;
  
      cardSize:number;
  
      removeRule:RemoveRuleType;
  
      viewWidth:number;
  
      viewHeight:number;
  
      totalRangeNum:number;
      
      stageNum:number;
};
  
export interface BlockType {
      id: number;

      x: number;

      y: number;

      level: number;

      type: number;
     
      status: BlockStatusType;

      higherThanBlocks: Set<number>;

      lowerThanBlocks:Set<number>;
};
    
export interface ChessBoardUnitType {
      // Blocks placed in the current grid (with higher levels and larger subscripts)
      blocks: BlockType[];
};

export const defaultGameConfig: GameConfig = {
      
      slotNum: 9,
  
      composeNumMin: 2,
  
      composeNumMax:7,
  
      typeNum: 16,
   
      levelBlockInitNum: 32,
  
      borderStep: 4,
  
      levelNum: 8,
  
      cardSize:44,
  
      removeRule:RemoveRuleType.DISCONTINUE,
  
      viewWidth:9,
  
      viewHeight:9,
  
      totalRangeNum:25,
  
      stageNum:3,
      
};
    