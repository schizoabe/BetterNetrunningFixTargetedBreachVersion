module DNR.Replace
import DNR.Core.*
import DNR.Settings.*

private func DNR_BP_RemoteTargetNetworkBreached(ent: wref<Entity>) -> Bool {
  let go: wref<GameObject> = ent as GameObject;
  if !IsDefined(go) { return false; }
  let sp: wref<ScriptedPuppet> = go as ScriptedPuppet;
  if !IsDefined(sp) { return false; }
  let spps: ref<ScriptedPuppetPS> = sp.GetPuppetPS();
  if !IsDefined(spps) { return false; }
  let ap: ref<AccessPointControllerPS> = spps.GetAccessPoint();
  return IsDefined(ap) && ap.IsNetworkBreached();
}

@wrapMethod(PlayerPuppet)
private final func UnlockAccessPointPrograms() -> Void {
  wrappedMethod();
  DNR_BP_AddProgram(this, t"MinigameAction.RemoteCyberpsychosis");
  DNR_BP_AddProgram(this, t"MinigameAction.RemoteSuicide");
  DNR_BP_AddProgram(this, t"MinigameAction.RemoteSystemReset");
  DNR_BP_AddProgram(this, t"MinigameAction.RemoteDetonateGrenade");
  DNR_BP_AddProgram(this, t"MinigameAction.RemoteNetworkOverload");
  DNR_BP_AddProgram(this, t"MinigameAction.RemoteNetworkContagion");
}

@wrapMethod(MinigameGenerationRuleScalingPrograms)
public final func FilterPlayerPrograms(programs: script_ref<[MinigameProgramData]>) -> Void {
  wrappedMethod(programs);

  let player: wref<PlayerPuppet> = this.m_player as PlayerPuppet;
  if !IsDefined(player) { return; }

  let isRemote: Bool = this.m_isRemoteBreach;
  let s: ref<DNR_Settings> = DNR_Svc();

  if IsDefined(s) && s.bpdeviceRequiresQueueMastery && !DNR_PlayerHasQueueMastery(player) {
    DNR_BP_RemoveAllDNRPrograms(programs);
    return;
  }

  if IsDefined(s) && s.bpdeviceRequiresNetworkBreached {
    if !DNR_BP_CheckNetworkBreached(this.m_entity, isRemote) {
      DNR_BP_RemoveAllDNRPrograms(programs);
      return;
    }
  }

  DNR_BP_AddQualifiedPrograms(player, programs, isRemote);
  DNR_BP_RemoveWrongVariant(programs, isRemote);
}

@replaceMethod(MinigameGenerationRuleScalingPrograms)
public func DefineLength(combinedPowerLevel: Float, bufferSize: Int32, numPrograms: Int32) -> Int32 {
  if !this.m_isRemoteBreach {
    let devBase: Int32 = 2;
    let devCap:  Int32 = 4;
    let length: Int32 = devBase + Cast<Int32>(combinedPowerLevel / 120.00);
    let clamped: Int32 = (length < devBase) ? devBase : ((length > devCap) ? devCap : length);
    return (clamped > bufferSize) ? bufferSize : clamped;
  }

  let s: ref<DNR_Settings> = DNR_Svc();

  let reducePerPoint: Float = 5.00;
  let hardCap: Int32 = 10;

  if IsDefined(s) && s.enableCustomLength {
    reducePerPoint = Cast<Float>(s.intelReducePerPoint);
    if s.enableUncappedLength {
      hardCap = 2147483647; 
    }
  }

  if IsDefined(this.m_player) {
    let stats: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_player.GetGame());
    let intel: Float = stats.GetStatValue(Cast<StatsObjectID>(this.m_player.GetEntityID()), gamedataStatType.Intelligence);
    combinedPowerLevel = MaxF(0.00, combinedPowerLevel - reducePerPoint * intel);
  }

  let min: Float = 1.00;
  let max: Float = 120.00;
  if numPrograms > 0 {
    combinedPowerLevel = combinedPowerLevel - (3.00 * combinedPowerLevel * Cast<Float>(numPrograms)) / max;
  }

  let normalizedLevel: Float = 2.00 + ((combinedPowerLevel - min) * 3.00) / (max - min);
  let length2: Int32 = Cast<Int32>(normalizedLevel);

  if IsDefined(this.m_player) {
    let stats2: ref<StatsSystem> = GameInstance.GetStatsSystem(this.m_player.GetGame());
    let perk: Float = stats2.GetStatValue(Cast<StatsObjectID>(this.m_player.GetEntityID()), gamedataStatType.ShorterChains);
    if perk > 0.00 && length2 > 2 { length2 -= 1; }
  }

  if length2 < 2 { length2 = 2; }
  if length2 > hardCap { length2 = hardCap; }
  if length2 > bufferSize { return bufferSize; }
  return length2;
}