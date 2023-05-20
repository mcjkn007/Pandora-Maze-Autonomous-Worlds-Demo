const { regClass, property } = Laya;
import { LoginBase } from './Login.generated';
 
@regClass()
export class Login extends LoginBase {

    gameComponents:any;
 
    result:any;

    onAwake() {
        console.log("Login start");
    
       // this.Button.on(Laya.Event.CLICK,this,this.onButtenEvent.bind(this))
    }
    async onButtenEvent( ){
       
 
     
      
    };
}
 