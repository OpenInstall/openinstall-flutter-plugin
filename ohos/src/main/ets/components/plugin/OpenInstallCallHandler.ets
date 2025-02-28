import { MethodCall, MethodCallHandler, MethodChannel, MethodResult, NewWantListener } from '@ohos/flutter_ohos';
import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { OpData, OpenInstall, OpError } from '@openinstall/sdk';

export class OpenInstallCallHandler implements MethodCallHandler, NewWantListener {

  private methodChanel: MethodChannel
  private ability: UIAbility | null = null
  private initialized: boolean = false
  private wantHolder: Want | null = null

  public constructor(methodChannel: MethodChannel) {
    this.methodChanel = methodChannel
  }

  public attachedToAbility(ability: UIAbility) {
    this.ability = ability
    OpenInstall.preInit(this.ability?.context)
    this.wakeup(ability.launchWant)
  }

  public detachedFromAbility() {
    this.ability = null
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    this.log("openinstall_flutter onNewWant : " + JSON.stringify(want));
    this.wakeup(want)
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.log("openinstall_flutter onMethodCall : " + call.method);
    switch (call.method) {
      case "init":
        this.init()
        result.success("OK")
        break
      case "getInstall":
        let seconds = call.argument("seconds") as number
        OpenInstall.getInstall(seconds).then((opData: OpData) => {
          this.log("openinstall_flutter getInstall OpData : " + JSON.stringify(opData));
          this.methodChanel.invokeMethod("onInstallNotification", this.data2Map(opData))
        }).catch((opError: OpError) => {
          this.log("openinstall_flutter getInstall OpError : " + JSON.stringify(opError));
          this.methodChanel.invokeMethod("onInstallNotification", this.data2Map(opError))
        })
        result.success("OK")
        break
      case "getWakeUp":
        // ignore
        result.success("OK")
        break
      case "reportRegister":
        OpenInstall.reportRegister()
        result.success("OK")
        break
      case "reportEffectPoint":
        let pointId = call.argument("pointId") as string
        let pointValue = call.argument("pointValue") as number
        let extraMap: Map<string, string> | null = null
        if (call.hasArgument("extras")) {
          extraMap = call.argument("extras") as Map<string, string>
        }
        OpenInstall.reportEffectPoint(pointId, pointValue, extraMap)
        result.success("OK")
        break
      case "reportShare":
        let shareCode = call.argument("shareCode") as string
        let sharePlatform = call.argument("platform") as string
        OpenInstall.reportShare(shareCode, sharePlatform).then(_ => {
          result.success(this.data2Map(null))
        }).catch((opError: OpError) => {
          result.success(this.data2Map(opError))
        })
        break
      case "getOpid":
        let opid = OpenInstall.getOpid()
        result.success(opid)
        break
      default:
        result.notImplemented()
        break
    }
  }

  private init() {
    this.log("openinstall_flutter init");
    OpenInstall.init(this.ability?.context)
    this.initialized = true
    if (this.wantHolder != null) {
      this.wakeup(this.wantHolder);
      this.wantHolder = null
    }
  }

  private wakeup(want: Want | undefined): void {
    if (want == null) {
      return
    }
    this.log("openinstall_flutter wakeup want : " + JSON.stringify(want));
    if (this.initialized) {
      OpenInstall.getWakeUp(want).then((opData: OpData) => {
        this.log("openinstall_flutter getWakeUp OpData : " + JSON.stringify(opData));
        this.methodChanel.invokeMethod("onWakeupNotification", this.data2Map(opData))
      }).catch((opError: OpError) => {
        this.log("openinstall_flutter getWakeUp OpError : " + JSON.stringify(opError));
        this.methodChanel.invokeMethod("onWakeupNotification", this.data2Map(opError))
      })
    } else {
      this.wantHolder = want
    }
  }

  private data2Map(data: OpData | OpError | null): Map<string, string> {
    let result: Map<string, string> = new Map<string, string>()
    result.set("shouldRetry", "false")
    if (data instanceof OpData) {
      result.set("channelCode", data.channelCode||"")
      result.set("bindData", JSON.stringify(data.bindData)||"")
    } else if (data instanceof OpError) {
      let shouldRetry = data.code == OpError.TIMEOUT || data.code == OpError.NOT_INIT
        || data.code == OpError.REQUEST_FAIL
      result.set("shouldRetry", shouldRetry + "")
      result.set("message", data.message || (data.code + "-未知错误"))
    }
    return result;
  }

  private log(message: string){
    console.debug(message);
  }

}