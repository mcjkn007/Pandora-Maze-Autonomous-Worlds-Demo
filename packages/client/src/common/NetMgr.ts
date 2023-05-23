
export class NetMgr {
    mud:any;
    private constructor() {
    }

    private static instance: NetMgr | undefined

    static getInstance():NetMgr{
        if(NetMgr.instance === undefined) {
            NetMgr.instance = new NetMgr()
        }
        return NetMgr.instance;
    }
    public SetMud(mud:any){
        this.mud = mud;
    }
    public GetMud():any{
        return this.mud;
    }
}
 