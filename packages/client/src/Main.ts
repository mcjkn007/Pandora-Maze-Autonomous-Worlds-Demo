const { regClass, property } = Laya;
import { setup } from "./mud/setup";


@regClass()
export class Main extends Laya.Script {
    @property( { type: Laya.Label } )
    private label: Laya.Label;
    @property( { type: Laya.Button } )
    private button: Laya.Button;

    result:any;
    async onStart() {
        console.log("Game start");

          this.result = await setup();
          // Components expose a stream that triggers when the component is updated.
          this.result.components.Counter.update$.subscribe((update) => {
            const [nextValue, prevValue] = update.value;
            this.label.text = nextValue.value.toString();
            console.log("Counter updated", update, { nextValue, prevValue });
         
          });

          this.button.on(Laya.Event.CLICK,this,this.onButtenEvent.bind(this));
    }
    onButtenEvent( ){
      this.result.systemCalls.increment(); 
    };
}