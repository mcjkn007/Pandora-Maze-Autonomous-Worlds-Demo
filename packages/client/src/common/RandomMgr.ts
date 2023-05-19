 
export class RandomMgr{
 
    public seed:number = -1;
     
    private readonly _a:number = 214013;
    private readonly _b:number = 2531011;
    private readonly _m:number = 4294967296;

    constructor() {
    }

    init(seed:number){
        this.seed = seed;
    }

    rand(length:number):number{
        this.seed = (this.seed  * this._a + this._b) % this._m;
        return this.seed % length;
    }
    randomNum(minNum:number,maxNum:number):number{ 
        return this.rand(maxNum-minNum)+minNum;
    } 
}

 