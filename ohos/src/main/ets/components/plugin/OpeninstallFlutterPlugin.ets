import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodChannel
} from '@ohos/flutter_ohos';
import { OpenInstallCallHandler } from './OpenInstallCallHandler';

export default class OpenInstallPlugin implements FlutterPlugin, AbilityAware {
  private methodChannel: MethodChannel | null = null
  private pluginBinding: AbilityPluginBinding | null = null
  private methodCallHandler: OpenInstallCallHandler | null = null

  getUniqueClassName(): string {
    return "OpeninstallFlutterPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.methodChannel = new MethodChannel(binding.getBinaryMessenger(), "openinstall_flutter_plugin")
    this.methodCallHandler = new OpenInstallCallHandler(this.methodChannel)
    this.methodChannel.setMethodCallHandler(this.methodCallHandler)
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.pluginBinding = binding
    binding.addOnNewWantListener(this.methodCallHandler)
    this.methodCallHandler?.attachedToAbility(binding.getAbility())
  }

  onDetachedFromAbility(): void {
    this.methodCallHandler?.detachedFromAbility()
    this.pluginBinding?.removeOnNewWantListener(this.methodCallHandler)
    this.pluginBinding = null
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    this.methodChannel?.setMethodCallHandler(null)
    this.methodChannel = null
    this.methodCallHandler = null
  }
}