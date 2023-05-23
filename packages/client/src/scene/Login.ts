const { regClass, property } = Laya;
import { NetMgr } from '../common/NetMgr';
import { setup } from '../mud/setup';
import { LoginBase } from './Login.generated';
 
@regClass()
export class Login extends LoginBase {

    gameComponents:any;
 
    result:any;

    onAwake() {
        console.log("Login start");

    
        this.Start_Button.on(Laya.Event.CLICK,this,this.onStartButtenEvent.bind(this));
        this.Rank_Button.on(Laya.Event.CLICK,this,this.onRankButtenEvent.bind(this));

        setup().then( async (result)=>{
            const net = NetMgr.getInstance();
            net.SetMud(result);
            console.log('load mud success');
            result.components.GameConfigComponent.update$.subscribe((update) => {
                
                const [nextValue, prevValue] = update.value;
                console.log('GameConfigComponent--- ',update);
     
               
              });
          });
 
        /*
        this.result = await setup();
        console.log('-----');
      
        const playerInfo = await this.result.api.GetPlayerInfo();
        if(playerInfo && playerInfo.baseSeed.size != 0){
            this.onChangeScene();
        }
        */
    }
    onOpened(param: any): void {
        Laya.Tween.to(this.Mask,{alpha:0},1200,Laya.Ease.linearIn);
    }
    onActionFinishEvent(){
        this.onChangeScene();
    }
    onStartButtenEvent( ){
        Laya.Tween.to(this.Mask,{alpha:1},1200,Laya.Ease.linearIn,Laya.Handler.create(this,this.onActionFinishEvent.bind(this)));
    };
    onRankButtenEvent( ){
        Laya.Scene.open("resources/prefab/P_rank.lh", false, {"text":'112'}) 
      
    };
    onChangeScene(){
        Laya.Scene.open("resources/scene/Game.ls",true, null, null,null);
        Laya.Scene.close("resources/scene/Login.ls")
        Laya.Scene.destroy("resources/scene/Login.ls")
    }
}
 