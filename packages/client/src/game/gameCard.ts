import { GameManagerEvent } from "../common/Config";

const { regClass, property } = Laya;

@regClass()
export class gameCard extends Laya.Script {
    //declare owner : Laya.Sprite3D;

    @property( { type: Laya.Image } )
    private alphabet: Laya.Image;

    public uid:number = -1;
    public touchFlag:boolean = true;
    constructor() {
        super();
    }
    onAwake(): void {
        this.alphabet.on(Laya.Event.CLICK,this,this.onClickEvent.bind(this));
    }
    onClickEvent( ){
        console.log('card touch');
        if(this.touchFlag == false){
            return;
        }
        console.log('card touch enabled ');
        Laya.stage.event(GameManagerEvent.TouchCard,this.uid);
        
    }

    SetAlphabet(alphabet:Laya.Texture){
        if(this.alphabet != undefined){
            this.alphabet.texture = alphabet;
        }
    }
 
}