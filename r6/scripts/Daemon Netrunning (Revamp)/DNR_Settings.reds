module DNR.Settings

public class DNR_Settings extends ScriptableService {
  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "01-DNR-Main")
  @runtimeProperty("ModSettings.description", "DNR-EnableProb")
  @runtimeProperty("ModSettings.displayName", "DNR-EnableProbDesc")
  public let enableProb: Bool = true;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "01-DNR-Main")
  @runtimeProperty("ModSettings.description", "DNR-EnableRules")
  @runtimeProperty("ModSettings.displayName", "DNR-EnableRulesDesc")
  public let enableRules: Bool = true;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "01-DNR-Main")
  @runtimeProperty("ModSettings.description", "DNR-EnableCustomLength")
  @runtimeProperty("ModSettings.displayName", "DNR-EnableCustomLengthDesc")
  public let enableCustomLength: Bool = true;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "01-DNR-Main")
  @runtimeProperty("ModSettings.description", "DNR-EnableSequencing")
  @runtimeProperty("ModSettings.displayName", "DNR-EnableSequencingDesc")
  public let enableSequencing: Bool = true;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "01-DNR-Main")
  @runtimeProperty("ModSettings.description", "DNR-EnableComplexity")
  @runtimeProperty("ModSettings.displayName", "DNR-EnableComplexityDesc")
  public let enableComplexityAdjustment: Bool = false;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "02-DNR-Rules")
  @runtimeProperty("ModSettings.displayName", "DNR-ReqQueueMastery")
  @runtimeProperty("ModSettings.dependency", "enableRules")
  public let bpdeviceRequiresQueueMastery: Bool = false;

  @runtimeProperty("ModSettings.mod", "DNR_ModName") 
  @runtimeProperty("ModSettings.category", "02-DNR-Rules") 
  @runtimeProperty("ModSettings.displayName", "DNR-ReqNetworkBreached") 
  @runtimeProperty("ModSettings.dependency", "enableRules") 
  public let bpdeviceRequiresNetworkBreached: Bool = false;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "02-DNR-Rules")
  @runtimeProperty("ModSettings.displayName", "DNR-ReqTagged")
  @runtimeProperty("ModSettings.dependency", "enableRules")
  public let bpdeviceRequiresTagged: Bool = false;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "02-DNR-Rules")
  @runtimeProperty("ModSettings.displayName", "DNR-FriendlyFire")
  @runtimeProperty("ModSettings.description", "DNR-FriendlyFireDesc")
  @runtimeProperty("ModSettings.dependency", "enableRules")
  public let enableFriendlyFire: Bool = true;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "03-DNR-Breach-Length")
  @runtimeProperty("ModSettings.displayName", "DNR-UncapChainLength")
  @runtimeProperty("ModSettings.dependency", "enableCustomLength")
  public let enableUncappedLength: Bool = false;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "03-DNR-Breach-Length")
  @runtimeProperty("ModSettings.displayName", "DNR-IntelReduce")
  @runtimeProperty("ModSettings.description", "DNR-IntelReduceDesc")
  @runtimeProperty("ModSettings.dependency", "enableCustomLength")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "500")
  @runtimeProperty("ModSettings.step", "5")
  public let intelReducePerPoint: Int32 = 5;
  
  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "04-DNR-Sequencing")
  @runtimeProperty("ModSettings.displayName", "DNR-StepDelay")
  @runtimeProperty("ModSettings.description", "DNR-StepDelayDesc")
  @runtimeProperty("ModSettings.dependency", "enableSequencing")
  @runtimeProperty("ModSettings.min", "0.00")
  @runtimeProperty("ModSettings.max", "15.00")
  @runtimeProperty("ModSettings.step", "0.05")
  public let stepDelaySeconds: Float = 5.00;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "04-DNR-Sequencing")
  @runtimeProperty("ModSettings.displayName", "DNR-RandomSequencing")
  @runtimeProperty("ModSettings.description", "DNR-RandomSequencingDesc")
  @runtimeProperty("ModSettings.dependency", "enableSequencing")
  public let enableRandomSequencing: Bool = true;
  
  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ChanceDetonate")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let chanceDetonate: Int32 = 50;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ChanceSuicide")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let chanceSuicide: Int32 = 20;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ChanceCyber")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let chanceCyber: Int32 = 60;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ChanceOverload")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let chanceOverload: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ChanceContagion")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let chanceContagion: Int32 = 100;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ChanceSystemReset")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  @runtimeProperty("ModSettings.min", "0")
  @runtimeProperty("ModSettings.max", "100")
  @runtimeProperty("ModSettings.step", "5")
  public let chanceSystemReset: Int32 = 60;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "05-DNR-Probability")
  @runtimeProperty("ModSettings.displayName", "DNR-ProbaScaleIntelligence")
  @runtimeProperty("ModSettings.description", "DNR-ProbaScaleIntelligenceDesc")
  @runtimeProperty("ModSettings.dependency", "enableProb")
  public let probaScaleIntelligence: Bool = true;

  // Remote MinigameActions
  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityCyberpsychosis")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityCyberpsychosis: Int32 = 300;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexitySuicide")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexitySuicide: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexitySystemReset")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexitySystemReset: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityDetonateGrenade")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityDetonateGrenade: Int32 = 200;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityMemoryWipe")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityMemoryWipe: Int32 = 150;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityNetworkContagion")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityNetworkContagion: Int32 = 120;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "06-DNR-Complexity")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityNetworkOverload")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityNetworkOverload: Int32 = 80;

  // AP versions (Access Point)
  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "07-DNR-Access-Point")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityCyberpsychosisAP")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityCyberpsychosisAP: Int32 = 6;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "07-DNR-Access-Point")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexitySuicideAP")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexitySuicideAP: Int32 = 6;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "07-DNR-Access-Point")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexitySystemResetAP")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexitySystemResetAP: Int32 = 6;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "07-DNR-Access-Point")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityDetonateGrenadeAP")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityDetonateGrenadeAP: Int32 = 6;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "07-DNR-Access-Point")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityNetworkContagionAP")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityNetworkContagionAP: Int32 = 6;

  @runtimeProperty("ModSettings.mod", "DNR_ModName")
  @runtimeProperty("ModSettings.category", "07-DNR-Access-Point")
  @runtimeProperty("ModSettings.displayName", "DNR-ComplexityNetworkOverloadAP")
  @runtimeProperty("ModSettings.description", "DNR-ResetRequire")
  @runtimeProperty("ModSettings.dependency", "enableComplexityAdjustment")
  @runtimeProperty("ModSettings.min", "1")
  @runtimeProperty("ModSettings.max", "2000")
  @runtimeProperty("ModSettings.step", "5")
  public let complexityNetworkOverloadAP: Int32 = 6;

  protected cb func OnInitialize() -> Void {
    ModSettings.RegisterListenerToClass(this);
    this.ApplyComplexitySettings();
  }

  protected cb func OnModSettingsChange() -> Void {
    this.ApplyComplexitySettings();
  }

  private func ApplyComplexitySettings() -> Void {
    if !this.enableComplexityAdjustment { return; }
    this.SetC(t"MinigameAction.RemoteCyberpsychosis", this.complexityCyberpsychosis);
    this.SetC(t"MinigameAction.RemoteSuicide", this.complexitySuicide);
    this.SetC(t"MinigameAction.RemoteSystemReset", this.complexitySystemReset);
    this.SetC(t"MinigameAction.RemoteDetonateGrenade", this.complexityDetonateGrenade);
    this.SetC(t"MinigameAction.RemoteMemoryWipeHack", this.complexityMemoryWipe);
    this.SetC(t"MinigameAction.RemoteNetworkContagion", this.complexityNetworkContagion);
    this.SetC(t"MinigameAction.RemoteNetworkOverload", this.complexityNetworkOverload);
    
    this.SetC(t"MinigameAction.Cyberpsychosis_AP", this.complexityCyberpsychosisAP);
    this.SetC(t"MinigameAction.Suicide_AP", this.complexitySuicideAP);
    this.SetC(t"MinigameAction.SystemReset_AP", this.complexitySystemResetAP);
    this.SetC(t"MinigameAction.DetonateGrenade_AP", this.complexityDetonateGrenadeAP);
    this.SetC(t"MinigameAction.NetworkContagion_AP", this.complexityNetworkContagionAP);
    this.SetC(t"MinigameAction.NetworkOverload_AP", this.complexityNetworkOverloadAP);
  }
  
  private func SetC(id: TweakDBID, v: Int32) -> Void {
    let path: TweakDBID = id + t".complexity";
    let ok: Bool = TweakDBManager.SetFlat(path, Cast<Float>(v));
    TweakDBManager.UpdateRecord(id);
  }
}