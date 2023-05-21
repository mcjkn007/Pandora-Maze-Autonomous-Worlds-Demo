const { regClass, property } = Laya;

 
import {GameConfigType,defaultGameConfig,BlockType,ChessBoardUnitType, GameManagerEvent, RemoveRuleType} from '../common/Config'
import { RandomMgr } from '../common/RandomMgr';
import { gameCard } from '../game/gameCard';
import { GameBase } from './Game.generated';

@regClass()
export class Game extends GameBase {
    
    randMgr:RandMgr;
   // 保存整个 "棋盘" 的每个格子状态（下标为格子起始点横纵坐标）
    chessBoard: ChessBoardUnitType[][] = [];
 
    res:Laya.PrefabImpl = null;
    card_res:Laya.PrefabImpl = null;
   // cardMap:Map<number,BlockType> = new Map();
    cardNodeMap:Map<number,Laya.Image> = new Map();
 
    cardBlocks: BlockType[] = [];

    curSlotNum:number = 0;
    slotArea:number[];
    score:number=0;
    gameConfig:GameConfigType;
    cardMoveSpeed:number = 1;
    slotCardMoveSpeed:number = 0.5;
    blockLevel:number = 0;
    playerOpCards:number[];
    stageNum:number = 0;
    async onAwake() {
        console.log("Game start");
       await Laya.loader.load("resources/prefab/P_card.lh").then((res)=>{
            this.res = res;
        } );
        await Laya.loader.load("resources/atlas/letter/letter.atlas", Laya.Loader.ATLAS).then((res)=> {
          this.card_res = res;
        });

       
        this.view.size(defaultGameConfig.viewWidth*defaultGameConfig.cardSize,defaultGameConfig.viewHeight*defaultGameConfig.cardSize);
        Laya.stage.on(GameManagerEvent.TouchCard,this,this.onTouchCardEvent.bind(this));
        Laya.stage.on(GameManagerEvent.RestartGame,this,this.RestartGame.bind(this));
     
        Laya.Tween.to(this.Mask,{alpha:0},1500,Laya.Ease.linearIn);
        this.onInitGame(defaultGameConfig);
    }
    onActionFinishEvent(){
      Laya.Scene.open("resources/scene/Login.ls",true, null, null,null);
      Laya.Scene.close("resources/scene/Game.ls")
      Laya.Scene.destroy("resources/scene/Game.ls")
  }
    onChangeScene(){
      Laya.Tween.to(this.Mask,{alpha:1},1200,Laya.Ease.linearIn,Laya.Handler.create(this,this.onActionFinishEvent.bind(this)));
  }
    RestartGame(type:number){
      console.log(type);
      if(type == 0){
        this.onChangeScene();
        return;
      }else if (type == 1){
        this.stageNum++;
        if(this.stageNum == defaultGameConfig.stageNum){
          this.onChangeScene();
        }
      }
      this.onInitGame(defaultGameConfig);
    }
    onTouchCardEvent(uid:number){
        console.log(uid);
        if(uid >= this.cardBlocks.length || uid < 0 ){
            return ;
        }

        const status = this.cardBlocks[uid].status;
        if(status == 0){
            this.onTouchViewCardEvent(uid);
        }else if(status == 1){
            this.onTouchSlotCardEvent(uid);
        }
    }
    onTouchViewCardEvent(uid:number){
        console.log('触摸：',uid);
        
        if(uid > this.cardBlocks.length){
           // this.onPopDialog('没有此卡');
           
            return;
        }
        let card = this.cardBlocks[uid];
        console.log('类型',card.type);
        if(card.lowerThanBlocks.size != 0){
            for(let a of card.lowerThanBlocks){
              console.log(a);
            }
          
            //this.onPopDialog('不是最上面的卡');
            return;
        }
        if(card.status != 0){
           // this.onPopDialog('已经被摸过了');
            return;
        }
        for (let x of card.higherThanBlocks){
            if(this.cardBlocks[x].lowerThanBlocks.has(card.id)){
                this.cardBlocks[x].lowerThanBlocks.delete(card.id);
                
                console.log('删除', card.id,"下面有",x);
                if(this.cardBlocks[x].lowerThanBlocks.size == 0){
                    this.cardNodeMap.get(x).gray = false;
                }
            }
        }
 

        
        this.onMoveTouchCard(uid); 
    }
    onMoveTouchCard(uid:number){
        this.curSlotNum++;
        if(this.curSlotNum > this.gameConfig.slotNum)
        {
            this.onPopResult(0,this.score.toString());
            return; 
        }
        this.cardBlocks[uid].status = 1;
        this.cardNodeMap.get(uid).zOrder = 999;
        const cPoint = new Laya.Point(this.cardNodeMap.get(uid).x,this.cardNodeMap.get(uid).y);
        let movePoint= new Laya.Point(0,0);
        this.slot_bg.localToGlobal(movePoint,false);
        this.view.globalToLocal(movePoint,false);
        movePoint.x += (this.curSlotNum-1)*(this.gameConfig.cardSize+8)+22;
     
        movePoint.y += 18;
        const sTime = this.calcDistance(cPoint,movePoint)/this.cardMoveSpeed;

        let script = this.cardNodeMap.get(uid).getComponent(Laya.Script) as gameCard;

        script.touchFlag = false;
        
        this.slotArea[this.curSlotNum-1] = uid;
        this.playerOpCards.push(uid);
        Laya.Tween.to(this.cardNodeMap.get(uid),movePoint,sTime,Laya.Ease.linearIn,Laya.Handler.create(this,this.onMoveCardFinishEvent.bind(this),[uid]));
       
    }
    calcDistance(a:Laya.Point,b:Laya.Point){
        return Math.sqrt(Math.pow(a.x-b.x,2)+Math.pow(a.y-b.y,2));
    }
    onMoveCardFinishEvent(args:number){
        const uid = args;
        let script = this.cardNodeMap.get(uid).getComponent(Laya.Script) as gameCard;
        script.touchFlag = true;
    }
    onMoveSlotCardFinishEvent(args:number){
        const uid = args;
 
        let script = this.cardNodeMap.get(uid).getComponent(Laya.Script) as gameCard;
        script.touchFlag = true;
    }
    onTouchSlotCardEvent(uid:number){
   
        if(!this.cardNodeMap.has(uid)){
          //  this.onPopDialog('卡片错误');
            return;
        }
        let newSlot = [];
        let n = 0;
        const type = this.cardBlocks[uid].type;
       
         
        if(this.gameConfig.removeRule == RemoveRuleType.CONTINUE){
          let removeArray = [];
           
          let p_index = 0;

          for (let i = 0; i < this.slotArea.length; i++) {
            if(this.slotArea[i] == uid){
                p_index = i;
                break;
            }
        }
          for (let i = p_index; i < this.slotArea.length; i++) {
            if(this.slotArea[i] == -1){
                break;
            }
            if(this.cardBlocks[this.slotArea[i]].type == type){
                 removeArray.push(i);
                 n++;
                 if(n >= this.gameConfig.composeNumMax){
                    break;
                 }
            }
            else{
                break;
            }
          }
          if(n < this.gameConfig.composeNumMax){
            for (let i = p_index-1; i >= 0; i--) {
              if(this.slotArea[i] == -1){
                  break;
              }
              if(this.cardBlocks[this.slotArea[i]].type == type){
                  removeArray.push(i);
                  n++;
                  if(n >= this.gameConfig.composeNumMax){
                    break;
                  }
              }
              else{
                  break;
              }
            }
          } 
          if(n < this.gameConfig.composeNumMin){
             // this.onPopDialog('没有到最低消除个数! ');
              return;
          }
          this.curSlotNum  -= n;
        
          for (let index = 0; index < removeArray.length; index++) {
              const id = this.slotArea[removeArray[index]];
              this.cardNodeMap.get(id).removeSelf();
              this.cardNodeMap.delete(id);
              this.cardBlocks[id].status = 2;
              this.slotArea[removeArray[index]] = -1;
          }
        
          for (let index = 0; index < this.slotArea.length; index++) {
            const element = this.slotArea[index];
            if(element != -1){
                newSlot.push(element);
            }
          }
          const dC = this.slotArea.length-this.curSlotNum;
          for (let index = 0; index < dC; index++) {
            newSlot.push(-1);
          }
        }else if(this.gameConfig.removeRule == RemoveRuleType.DISCONTINUE)
        {
          for (let i = 0; i < this.slotArea.length; i++) {
            const id = this.slotArea[i];
            if(id == -1){
              break;
            }
            console.log(id,type);
            if(this.cardBlocks[id].type == type){
              this.cardNodeMap.get(id).removeSelf();
              this.cardNodeMap.delete(id);
              this.cardBlocks[id].status = 2;
              this.curSlotNum--;
              n++;
              if(n >= this.gameConfig.composeNumMax){
                break;
              }
              this.slotArea[i] = -1;
            }
          }
          for (let index = 0; index < this.slotArea.length; index++) {
            const element = this.slotArea[index];
            if(element != -1){
                newSlot.push(element);
            }
          }
          const dC = this.slotArea.length-this.curSlotNum;
          for (let index = 0; index < dC; index++) {
            newSlot.push(-1);
          }
        }

        this.score += Math.pow(2,n-this.gameConfig.composeNumMin);
        this.score_text.text = this.score.toString();

        this.slotArea = newSlot;

        console.log('new slot ',this.slotArea);
        for (let i = 0; i < this.slotArea.length; i++) {
            const index = this.slotArea[i];
            if(index == -1 && !this.cardNodeMap.has(index)){
                continue;
            }
    
            const cPoint = new Laya.Point(this.cardNodeMap.get(index).x,this.cardNodeMap.get(index).y);
            let movePoint= new Laya.Point(0,0);
            this.slot_bg.localToGlobal(movePoint,false);
            this.view.globalToLocal(movePoint,false);
            movePoint.x += i*(this.gameConfig.cardSize+8)+22;

            movePoint.y += 18;
            const sTime = this.calcDistance(cPoint,movePoint)/this.slotCardMoveSpeed;
            let script = this.cardNodeMap.get(index).getComponent(Laya.Script) as gameCard;
    
            script.touchFlag = false;
            Laya.Tween.to(this.cardNodeMap.get(index),movePoint,sTime,Laya.Ease.linearIn,Laya.Handler.create(this,this.onMoveSlotCardFinishEvent.bind(this),[index]));
        }
        this.playerOpCards.push(uid);
        if(this.cardNodeMap.size == 0){
          this.onPopResult(1,this.score.toString());
          return; 
        } 
    }
    onInitGame(gameConfig:GameConfigType){
        this.gameConfig = gameConfig;
        this.chessBoard = [];

        for(let node of this.cardNodeMap)
        {
            node[1].removeSelf();
        }
        
        this.cardNodeMap = new Map();
        this.cardBlocks = [];
        this.curSlotNum = 0;
        this.slotArea =  new Array(gameConfig.slotNum).fill(-1);
         
        this.score_text.text = this.score.toString();
        this.blockLevel = 0;
        this.playerOpCards = [];
         
        this.chessBoard = new Array(gameConfig.viewWidth*gameConfig.cardSize);
        for (let i = 0; i < gameConfig.viewWidth*gameConfig.cardSize; i++) {
            this.chessBoard[i] = new Array(gameConfig.viewHeight*gameConfig.cardSize);
          for (let j = 0; j < gameConfig.viewHeight*gameConfig.cardSize; j++) {
            this.chessBoard[i][j] = {
              blocks: [],
            };
          }
        }

        const blockNumUnit = gameConfig.composeNumMax * 2 * gameConfig.typeNum;

        this.randMgr = new RandomMgr();
        this.randMgr.init(this.score);

 
        const totalNum = gameConfig.totalRangeNum;
        let typeCount = 0;
        let RandomTypeArray = Array<number>();
        let bitFlag = 0n;
        while (typeCount < gameConfig.typeNum) {
            const index = this.randMgr.randomNum(0,totalNum);
            if((bitFlag & BigInt(1<<index)) == BigInt(1)){
              continue;
            }
            bitFlag += BigInt(1<<index);
            RandomTypeArray[typeCount] = index;
            typeCount++;
        }
   
        let TypeArray = Array<number>();
        for (let i = 0; i < blockNumUnit; i++) {
            TypeArray.push(RandomTypeArray[i % gameConfig.typeNum]);
          }

        for (let i = 0; i < TypeArray.length; i++) {
            const j = this.randMgr.randomNum(0,i+1);
            let a = TypeArray[i];
            TypeArray[i] = TypeArray[j];
            TypeArray[j] = a;
        }

        let AllBlockArray = Array<BlockType>();
        for (let i = 0; i < blockNumUnit; i++) {
            const newBlock = {
              id: i,
              status: 0,
              level: 0,
              type: TypeArray[i],
              higherThanBlocks:new Set,
              lowerThanBlocks:new Set,
            } as BlockType;
            AllBlockArray.push(newBlock);
          }

            // 4. 计算有层级关系的块
            const levelBlocks: BlockType[] = [];
            let minX = 0;
            let maxX = (gameConfig.viewWidth-1)*gameConfig.cardSize;
            let minY = 0;
            let maxY = (gameConfig.viewHeight-1)*gameConfig.cardSize;
            let pos = 0;
          let leftBlockNum = blockNumUnit;
          for (let i = 0; i < gameConfig.levelNum; i++) {
            let nextBlockNum = Math.min(leftBlockNum,gameConfig.levelBlockInitNum);
            // 最后一批，分配所有 leftBlockNum
            if (i == gameConfig.levelNum - 1) {
              nextBlockNum = leftBlockNum;
            }
            // 边界收缩
            if (gameConfig.borderStep > 0) {
              const dir = i % 4;
              if (i > 0) {
                if (dir === 0) {
                  minX = Math.min(minX+gameConfig.borderStep,maxX);
                } else if (dir === 1) {
                  maxY = Math.max(minY,maxY-gameConfig.borderStep);
                } else if (dir === 2) {
                  minY = Math.min(minY+gameConfig.borderStep,maxY);
                } else {
                  maxX = Math.max(minX,maxX-gameConfig.borderStep);
                }
              }
            }
            const nextGenBlocks = AllBlockArray.slice(pos, pos + nextBlockNum);
            console.log('next  ',nextGenBlocks.length);
            levelBlocks.push(...nextGenBlocks);
            pos += nextBlockNum;
            // 生成块的坐标
            this.genLevelBlockPos(defaultGameConfig,nextGenBlocks, minX, minY, maxX, maxY);
            leftBlockNum -= nextBlockNum;
            if (leftBlockNum <= 0) {
              break;
            }
          }

     
          this.cardBlocks.push(...levelBlocks);
          this.initCard(levelBlocks);
          this.gameStart();
        
    }
   
    initCard(blockInfo:BlockType[]){

      for (let index = 0; index < blockInfo.length; index++) {
            
        const info = blockInfo[index];
       // this.cardMap.set(info.id,info);

      //  const [a,c] = this.getCardInfo(defaultGameConfig,info.type);

        let ct = this.res.create() as Laya.Image;
        let script =  ct.getComponent(Laya.Script) as gameCard;
        script.uid = info.id;
       
        let res:Laya.Texture = Laya.loader.getRes(`atlas/letter/letter_${info.type+1}.png`);
        script.SetAlphabet(res);

        ct.x = this.view.width/4;
        ct.y = this.view.height/4;
        //ct.x = info.x;
        //ct.y = info.y;
        ct.zOrder = info.level;
         
        if(info.lowerThanBlocks.size != 0){
            ct.gray = true;
        }
        
        this.view.addChild(ct);
        this.cardNodeMap.set(info.id,ct);
      }
    }
    gameStart(){
        const basePoint = new Laya.Point(0,0);
        for (let index = 0; index < this.cardBlocks.length; index++) {
          const info = this.cardBlocks[index];
          const node = this.cardNodeMap.get(info.id);
          let movePoint= new Laya.Point(info.x,info.y);
          const sTime = this.calcDistance(basePoint,movePoint)/this.slotCardMoveSpeed;
          let script = this.cardNodeMap.get(index).getComponent(Laya.Script) as gameCard;
  
          script.touchFlag = false;

          Laya.Tween.to(node,movePoint,sTime,Laya.Ease.linearIn,Laya.Handler.create(this,this.onMoveSlotCardFinishEvent.bind(this),[index]));
         
        }
        
    }
   //getCardInfo(gameConfig:GameConfigType,type:number):[cardAlphabet:string,cardColor:string]{
       // return [gameConfig.alphabetArray[type%gameConfig.alphabetNum],
       // gameConfig.colorArray[type%gameConfig.colorNum]];
   // }
    genLevelBlockPos = (
        gameConfig:GameConfigType,
        blocks: BlockType[],
        minX: number,
        minY: number,
        maxX: number,
        maxY: number
      ) => {
        // 记录这批块的坐标，用于保证同批次元素不能完全重叠
        const currentPosSet = new Set<string>();
        for (let i = 0; i < blocks.length; i++) {
          const block = blocks[i];
          // 随机生成坐标
          let newPosX;
          let newPosY;
          let key;
          while (true) {
            newPosX = this.randMgr.randomNum(minX,maxX) ;
            newPosY = this.randMgr.randomNum(minY,maxY) ;
            key = newPosX + "," + newPosY;
            // 同批次元素不能完全重叠
            if (!currentPosSet.has(key)) {
              break;
            }
          }
          this.chessBoard[newPosX][newPosY].blocks.push(block);
          currentPosSet.add(key);
          block.x = newPosX;
          block.y = newPosY;
          block.level = this.blockLevel++;
          // 填充层级关系
          this.genLevelRelation(gameConfig,block);
        }
      };
      genLevelRelation = (gameConfig:GameConfigType,block: BlockType) => {
        // 确定该块附近的格子坐标范围
        const minX = Math.max(block.x-gameConfig.cardSize, 0);
        const minY = Math.max(block.y-gameConfig.cardSize, 0);
        const maxX = Math.min(block.x + gameConfig.cardSize+1, (gameConfig.viewWidth-1)*gameConfig.cardSize);
        const maxY = Math.min(block.y + gameConfig.cardSize+1, (gameConfig.viewHeight-1)*gameConfig.cardSize);
        // 遍历该块附近的格子
        //let maxLevel = 0;
        for (let i = minX; i < maxX; i++) {
          for (let j = minY; j < maxY; j++) {
            const relationBlocks = this.chessBoard[i][j].blocks;
            if (relationBlocks.length > 0) {
              // 取当前位置最高层的块
              const maxLevelRelationBlock = relationBlocks[relationBlocks.length - 1];
              // 排除自己
              if (maxLevelRelationBlock.id === block.id) {
                console.log('-----');
                continue;
              }
              //maxLevel = Math.max(maxLevel, maxLevelRelationBlock.level);
              block.higherThanBlocks.add(maxLevelRelationBlock.id);
              maxLevelRelationBlock.lowerThanBlocks.add(block.id);
            }
          }
        }
        // 比最高层的块再高一层（初始为 1）
        //block.level = maxLevel + 1;
      };
    onPopDialog(message:string){
        Laya.Scene.open("resources/prefab/P_dialog.lh", false, {"text":message}) 
    }
    onPopResult(type:number,message:string){
      if(type == 0){
        Laya.Scene.open("resources/prefab/P_defeat.lh", false, {"text":message,"type":type});
      }
      else{
        Laya.Scene.open("resources/prefab/P_victory.lh", false, {"text":message,"type":type});
      }
  }
}