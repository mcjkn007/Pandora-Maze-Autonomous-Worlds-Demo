import { GameManagerEvent } from "../common/Config";
import { gameResultBase } from "./gameResult.generated";

const { regClass, property } = Laya;

@regClass()
export class gameResult extends gameResultBase {
    type:number = 0;
    constructor() {
        super();
    }
    onAwake(): void {

        this.Text.text = "";

       
    }
    onOpened(param: any): void {
        this.Text.text = param.text;
        this.type = param.type;
    }
    onDisable(): void {
    }
    onClosed(type?: string): void {
        Laya.stage.event(GameManagerEvent.RestartGame,this.type);
    }
   
}