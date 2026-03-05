module DNR.Core
import DNR.Settings.*

public func DNR_BP_GetAllRemotePrograms() -> array<TweakDBID> {
  let programs: array<TweakDBID>;
  ArrayPush(programs, t"MinigameAction.RemoteCyberpsychosis");
  ArrayPush(programs, t"MinigameAction.RemoteSuicide");
  ArrayPush(programs, t"MinigameAction.RemoteSystemReset");
  ArrayPush(programs, t"MinigameAction.RemoteDetonateGrenade");
  ArrayPush(programs, t"MinigameAction.RemoteNetworkOverload");
  ArrayPush(programs, t"MinigameAction.RemoteNetworkContagion");
  return programs;
}

public func DNR_BP_GetAllAPPrograms() -> array<TweakDBID> {
  let programs: array<TweakDBID>;
  ArrayPush(programs, t"MinigameAction.Cyberpsychosis_AP");
  ArrayPush(programs, t"MinigameAction.Suicide_AP");
  ArrayPush(programs, t"MinigameAction.SystemReset_AP");
  ArrayPush(programs, t"MinigameAction.DetonateGrenade_AP");
  ArrayPush(programs, t"MinigameAction.NetworkOverload_AP");
  ArrayPush(programs, t"MinigameAction.NetworkContagion_AP");
  return programs;
}

public func DNR_BP_GetProgramGate(programID: TweakDBID, player: wref<PlayerPuppet>) -> Bool {
  if programID == t"MinigameAction.RemoteCyberpsychosis" || programID == t"MinigameAction.Cyberpsychosis_AP" {
    return DNR_BP_Gate_Cyberpsychosis(player);
  }
  if programID == t"MinigameAction.RemoteSuicide" || programID == t"MinigameAction.Suicide_AP" {
    return DNR_BP_Gate_Suicide(player);
  }
  if programID == t"MinigameAction.RemoteSystemReset" || programID == t"MinigameAction.SystemReset_AP" {
    return DNR_BP_Gate_SystemReset(player);
  }
  if programID == t"MinigameAction.RemoteDetonateGrenade" || programID == t"MinigameAction.DetonateGrenade_AP" {
    return DNR_BP_Gate_Grenade(player);
  }
  if programID == t"MinigameAction.RemoteNetworkOverload" || programID == t"MinigameAction.NetworkOverload_AP" {
    return DNR_BP_Gate_Overload(player);
  }
  if programID == t"MinigameAction.RemoteNetworkContagion" || programID == t"MinigameAction.NetworkContagion_AP" {
    return DNR_BP_Gate_Contagion(player);
  }
  return false;
}

public func DNR_BP_RemoveAllDNRPrograms(list: script_ref<[MinigameProgramData]>) -> Void {
  let remote: array<TweakDBID> = DNR_BP_GetAllRemotePrograms();
  let ap: array<TweakDBID> = DNR_BP_GetAllAPPrograms();
  let i: Int32 = 0;
  
  while i < ArraySize(remote) {
    DNR_BP_RemoveProgram(list, remote[i]);
    i += 1;
  }
  
  i = 0;
  while i < ArraySize(ap) {
    DNR_BP_RemoveProgram(list, ap[i]);
    i += 1;
  }
}

public func DNR_BP_AddQualifiedPrograms(player: wref<PlayerPuppet>, list: script_ref<[MinigameProgramData]>, isRemote: Bool) -> Void {
  let programs: array<TweakDBID> = isRemote ? DNR_BP_GetAllRemotePrograms() : DNR_BP_GetAllAPPrograms();
  let i: Int32 = 0;
  
  while i < ArraySize(programs) {
    if DNR_BP_GetProgramGate(programs[i], player) {
      DNR_BP_PushProgram(list, programs[i]);
    }
    i += 1;
  }
}

public func DNR_BP_RemoveWrongVariant(list: script_ref<[MinigameProgramData]>, isRemote: Bool) -> Void {
  let toRemove: array<TweakDBID> = isRemote ? DNR_BP_GetAllAPPrograms() : DNR_BP_GetAllRemotePrograms();
  let i: Int32 = 0;
  
  while i < ArraySize(toRemove) {
    DNR_BP_RemoveProgram(list, toRemove[i]);
    i += 1;
  }
}

public func DNR_Svc() -> ref<DNR_Settings> {
  let c = GameInstance.GetScriptableServiceContainer();
  let a = c.GetService(n"DNR_Settings") as DNR_Settings;
  if IsDefined(a) { return a; }
  return c.GetService(n"DNR.Settings.DNR_Settings") as DNR_Settings;
}

public func DNR_PlayerHasQueueMastery(p: wref<PlayerPuppet>) -> Bool {
  if !IsDefined(p) { return false; }
  let dev: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(p);
  if !IsDefined(dev) { return false; }
  return dev.IsNewPerkBought(gamedataNewPerkType.Intelligence_Master_Perk_1) > 0;
}

public func DNR_BP_DefaultChance(programID: TweakDBID) -> Int32 {
  if programID == t"MinigameAction.RemoteDetonateGrenade" { return 50; }
  if programID == t"MinigameAction.RemoteSuicide" { return 20; }
  if programID == t"MinigameAction.RemoteCyberpsychosis" { return 60; }
  if programID == t"MinigameAction.RemoteNetworkOverload" { return 100; }
  if programID == t"MinigameAction.RemoteNetworkContagion" { return 100; }
  if programID == t"MinigameAction.RemoteSystemReset" { return 60; }
  return 100;
}

public func DNR_BP_ChanceFor(programID: TweakDBID) -> Int32 {
  let s: ref<DNR_Settings> = DNR_Svc();
  if !IsDefined(s) || !s.enableProb { return DNR_BP_DefaultChance(programID); }
  if programID == t"MinigameAction.RemoteDetonateGrenade" { return s.chanceDetonate; }
  if programID == t"MinigameAction.RemoteSuicide" { return s.chanceSuicide; }
  if programID == t"MinigameAction.RemoteCyberpsychosis" { return s.chanceCyber; }
  if programID == t"MinigameAction.RemoteNetworkOverload" { return s.chanceOverload; }
  if programID == t"MinigameAction.RemoteNetworkContagion" { return s.chanceContagion; }
  if programID == t"MinigameAction.RemoteSystemReset" { return s.chanceSystemReset; }
  return DNR_BP_DefaultChance(programID);
}

public func DNR_BP_GetIntelligenceBonus(player: wref<PlayerPuppet>) -> Int32 {
  let s: ref<DNR_Settings> = DNR_Svc();
  if !IsDefined(s) || !s.probaScaleIntelligence {
    return 0;
  }
  
  let statSys: ref<StatsSystem> = GameInstance.GetStatsSystem(player.GetGame());
  let intelligence: Float = statSys.GetStatValue(Cast<StatsObjectID>(player.GetEntityID()), gamedataStatType.Intelligence);

  let rawBonus: Float = (intelligence - 3.0) * 3.0;
  if rawBonus < 0.0 {
    return 0;
  }
  let bonus: Int32 = Cast<Int32>(rawBonus);
  return bonus;
}

public func DNR_BP_Roll(pct: Int32, player: wref<PlayerPuppet>) -> Bool {
  let bonus: Int32 = DNR_BP_GetIntelligenceBonus(player);
  let finalChance: Int32 = Min(100, pct + bonus);
  return RandRange(1, 100) <= finalChance;
}

public func DNR_BP_HasItem(self: wref<PlayerPuppet>, tdb: TweakDBID) -> Bool =
  GameInstance.GetTransactionSystem(self.GetGame()).HasItem(self, ItemID.FromTDBID(tdb))

public func DNR_BP_DeckHas(self: wref<PlayerPuppet>, tdb: TweakDBID) -> Bool {
  let es: ref<EquipmentSystemPlayerData> = EquipmentSystem.GetData(self);
  let deckID: ItemID = es.GetActiveItem(gamedataEquipmentArea.SystemReplacementCW);
  if !EquipmentSystem.IsItemCyberdeck(deckID) { return false; }
  let ts: ref<TransactionSystem> = GameInstance.GetTransactionSystem(self.GetGame());
  let data: ref<gameItemData> = ts.GetItemData(self, deckID);
  if !IsDefined(data) { return false; }
  let parts: array<InnerItemData>;
  data.GetItemParts(parts);
  let i: Int32 = 0;
  while i < ArraySize(parts) {
    if ItemID.GetTDBID(InnerItemData.GetItemID(parts[i])) == tdb { return true; }
    i += 1;
  }
  return false;
}

public func DNR_BP_OwnsOrInstalled(self: wref<PlayerPuppet>, ids: array<TweakDBID>) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(ids) {
    let id: TweakDBID = ids[i];
    if DNR_BP_HasItem(self, id) || DNR_BP_DeckHas(self, id) { return true; }
    i += 1;
  }
  return false;
}

public func DNR_BP_Gate_Cyberpsychosis(self: wref<PlayerPuppet>) -> Bool = DNR_BP_OwnsOrInstalled(self, [
  t"Items.MadnessLvl3Program", t"Items.MadnessLvl4Program", t"Items.MadnessLvl4PlusPlusProgram"
])

public func DNR_BP_Gate_Suicide(self: wref<PlayerPuppet>) -> Bool = DNR_BP_OwnsOrInstalled(self, [
  t"Items.SuicideLvl3Program", t"Items.SuicideLvl4Program", t"Items.SuicideLvl4PlusPlusProgram"
])

public func DNR_BP_Gate_SystemReset(self: wref<PlayerPuppet>) -> Bool = DNR_BP_OwnsOrInstalled(self, [
  t"Items.SystemCollapseLvl3Program", t"Items.SystemCollapseLvl4Program", t"Items.SystemCollapseLvl4PlusPlusProgram",
  t"Items.DisableCyberwareLvl2Program", t"Items.DisableCyberwareLvl3Program",
  t"Items.DisableCyberwareLvl4Program", t"Items.DisableCyberwareLvl4PlusPlusProgram"
])

public func DNR_BP_Gate_Grenade(self: wref<PlayerPuppet>) -> Bool = DNR_BP_OwnsOrInstalled(self, [
  t"Items.GrenadeExplodeLvl3Program", t"Items.GrenadeExplodeLvl4Program", t"Items.GrenadeExplodeLvl4PlusPlusProgram"
])

public func DNR_BP_Gate_Overload(self: wref<PlayerPuppet>) -> Bool = DNR_BP_OwnsOrInstalled(self, [
  t"Items.EMPOverloadLvl1Program", t"Items.EMPOverloadLvl2Program", t"Items.EMPOverloadLvl3Program",
  t"Items.EMPOverloadLvl4Program", t"Items.EMPOverloadLvl4PlusPlusProgram",
  t"Items.OverheatLvl1Program", t"Items.OverheatLvl2Program", t"Items.OverheatLvl3Program",
  t"Items.OverheatLvl4Program", t"Items.OverheatLvl4PlusPlusProgram"
])

public func DNR_BP_Gate_Contagion(self: wref<PlayerPuppet>) -> Bool = DNR_BP_OwnsOrInstalled(self, [
  t"Items.ContagionProgram", t"Items.ContagionLvl2Program", t"Items.ContagionLvl3Program",
  t"Items.ContagionLvl4Program", t"Items.ContagionLvl4PlusPlusProgram"
])

public func DNR_BP_ContainsProgram(list: script_ref<[MinigameProgramData]>, id: TweakDBID) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(Deref(list)) {
    if Deref(list)[i].actionID == id { return true; }
    i += 1;
  }
  return false;
}

public func DNR_BP_PushProgram(list: script_ref<[MinigameProgramData]>, id: TweakDBID) -> Void {
  if DNR_BP_ContainsProgram(list, id) { return; }
  let rec: wref<MinigameAction_Record> = TweakDBInterface.GetMinigameActionRecord(id);
  if !IsDefined(rec) { return; }
  let d: MinigameProgramData;
  d.actionID = id;
  d.programName = StringToName(LocKeyToString(rec.ObjectActionUI().Caption()));
  ArrayPush(Deref(list), d);
}

public func DNR_BP_RemoveProgram(list: script_ref<[MinigameProgramData]>, id: TweakDBID) -> Void {
  let kept: array<MinigameProgramData>;
  let i: Int32 = 0;
  while i < ArraySize(Deref(list)) {
    if Deref(list)[i].actionID != id { ArrayPush(kept, Deref(list)[i]); }
    i += 1;
  }
  ArrayClear(Deref(list));
  i = 0;
  while i < ArraySize(kept) { ArrayPush(Deref(list), kept[i]); i += 1; }
}

public func DNR_BP_HasProgram(list: array<TweakDBID>, id: TweakDBID) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(list) {
    if list[i] == id { return true; }
    i += 1;
  }
  return false;
}

public func DNR_BP_DeviceVariant(id: TweakDBID) -> TweakDBID {
  if id == t"MinigameAction.RemoteCyberpsychosis" { return t"MinigameAction.Cyberpsychosis_AP"; }
  if id == t"MinigameAction.RemoteSuicide" { return t"MinigameAction.Suicide_AP"; }
  if id == t"MinigameAction.RemoteSystemReset" { return t"MinigameAction.SystemReset_AP"; }
  if id == t"MinigameAction.RemoteDetonateGrenade" { return t"MinigameAction.DetonateGrenade_AP"; }
  if id == t"MinigameAction.RemoteNetworkOverload" { return t"MinigameAction.NetworkOverload_AP"; }
  if id == t"MinigameAction.RemoteNetworkContagion" { return t"MinigameAction.NetworkContagion_AP"; }
  return id;
}

public func DNR_BP_EffectiveId(id: TweakDBID, isRemote: Bool) -> TweakDBID =
  isRemote ? id : DNR_BP_DeviceVariant(id)

public func DNR_BP_HasProgramAny(list: array<TweakDBID>, base: TweakDBID) -> Bool =
  DNR_BP_HasProgram(list, base) || DNR_BP_HasProgram(list, DNR_BP_DeviceVariant(base))

public func DNR_BP_AddProgram(self: wref<PlayerPuppet>, id: TweakDBID) -> Void {
  let rec: wref<MinigameAction_Record> = TweakDBInterface.GetMinigameActionRecord(id);
  if !IsDefined(rec) { return; }
  let data: MinigameProgramData;
  data.actionID = id;
  data.programName = StringToName(LocKeyToString(rec.ObjectActionUI().Caption()));
  self.UpdateMinigamePrograms(data, true);
}

public func DNR_BP_RemoteTargetNetworkBreached(ent: wref<Entity>) -> Bool {
  let go: wref<GameObject> = ent as GameObject;
  if !IsDefined(go) { return false; }
  let sp: wref<ScriptedPuppet> = go as ScriptedPuppet;
  if !IsDefined(sp) { return false; }
  let spps: ref<ScriptedPuppetPS> = sp.GetPuppetPS();
  if !IsDefined(spps) { return false; }
  let ap: ref<AccessPointControllerPS> = spps.GetAccessPoint();
  return IsDefined(ap) && ap.IsNetworkBreached();
}

public func DNR_BP_CheckNetworkBreached(ent: wref<Entity>, isRemote: Bool) -> Bool {
  if isRemote {
    return DNR_BP_RemoteTargetNetworkBreached(ent);
  } else {
    let dev: wref<Device> = ent as Device;
    if !IsDefined(dev) { return false; }
    let devPS: ref<ScriptableDeviceComponentPS> = dev.GetDevicePS();
    if !IsDefined(devPS) { return false; }
    let apPS: ref<AccessPointControllerPS> = devPS.GetBackdoorAccessPoint();
    return IsDefined(apPS) && apPS.IsNetworkBreached();
  }
}

public func DNR_BP_IsTargetTagged(puppet: wref<GameObject>) -> Bool {
  if !IsDefined(puppet) { return false; }
  
  return puppet.IsTaggedinFocusMode();
}