module HackthePlanetForReal
import HackthePlanetForRealConfig.*


public class SJKIStampNPCBreachedEvent extends Event {}

@addMethod(ScriptedPuppetPS)
public func OnSJKIStampNPCBreachedEvent(evt: ref<SJKIStampNPCBreachedEvent>) -> EntityNotificationType {
  this.m_sjkiNPCSubnetBreached = true;
  if HackthePlanetForRealSettings.EnableDebugLog() {
    LogChannel(n"DEBUG", s"[SJKI] OnSJKIStampNPCBreachedEvent: stamped on canonical PS");
  };
  return EntityNotificationType.DoNotNotifyEntity;
}

private func SJKI_Log(msg: String) -> Void {
  if HackthePlanetForRealSettings.EnableDebugLog() {
    LogChannel(n"DEBUG", s"[SJKI] \(msg)");
  };
}


@addField(ScriptableDeviceComponentPS)
public let m_isSJKIStandaloneDevice: Bool;


private func SJKI_IsTargetDevice(name: String) -> Bool {
  return
    Equals(name, "Computer")                                 ||
    Equals(name, "Spontaneous Craving Satisfaction Machine") ||
    Equals(name, "Weapon Vending Machine")                   ||
    Equals(name, "Confession Booth")                         ||
    Equals(name, "Ice Machine")                              ||
    Equals(name, "Arcade Machine")                           ||
    Equals(name, "Pachinko Machine")                         ||
    Equals(name, "Terminal")                                 ||
    Equals(name, "Laptop")                                   ||
    Equals(name, "Server");
}


private func SJKI_OpenBreachHUD(ps: ref<ScriptableDeviceComponentPS>) -> Void {
  let bb: ref<IBlackboard> = GameInstance.GetBlackboardSystem(ps.GetGameInstance())
                               .Get(GetAllBlackboardDefs().NetworkBlackboard);
  let minigameDef: TweakDBID = ps.GetMinigameDefinition();
  bb.SetInt     (GetAllBlackboardDefs().NetworkBlackboard.DevicesCount,  1);
  bb.SetBool    (GetAllBlackboardDefs().NetworkBlackboard.OfficerBreach, false);
  bb.SetBool    (GetAllBlackboardDefs().NetworkBlackboard.RemoteBreach,  false);
  bb.SetInt     (GetAllBlackboardDefs().NetworkBlackboard.Attempt,       ps.m_minigameAttempt);
  bb.SetEntityID(GetAllBlackboardDefs().NetworkBlackboard.DeviceID,      ps.GetMyEntityID());
  if TDBID.IsValid(minigameDef) {
    bb.SetVariant(GetAllBlackboardDefs().NetworkBlackboard.MinigameDef,  ToVariant(minigameDef));
  }
  bb.SetString  (GetAllBlackboardDefs().NetworkBlackboard.NetworkName,   ps.GetDeviceName(), true);
}



@replaceMethod(ScriptableDeviceComponentPS)
protected const func ShouldExposePersonalLinkAction() -> Bool {

  if (Vector4.Distance(new Vector4(-1176.5278320313, 2042.3792724609, 20.097213745117, 1), this.GetLocalPlayer().GetWorldPosition()) > 3.0) {

    if this.IsPersonalLinkConnecting()                                                                      { return false; }
    if TDBID.IsValid(this.m_personalLinkCustomInteraction) && this.IsPersonalLinkConnected()                { return false; }
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) || this.m_personalLinkForced { return true; }
    if this.IsHackingSkillCheckActive()                                                                     { return false; }
    if this.IsGlitching() || this.IsDistracting()                                                           { return false; }

    if this.HasNetworkBackdoor() {
      if HackthePlanetForRealSettings.ReinitializeAccessPoints() && this.IsON() {
        this.SetMinigameState(HackingMinigameState.Unknown);
        this.TurnAuthorizationModuleON();
        this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(false);
        this.m_skillCheckContainer.GetHackingSlot().CheckPerformed();
        this.ResolveOtherSkillchecks();
      }
      return !this.WasHackingMinigameSucceeded();
    }

    if HackthePlanetForRealSettings.HackthePlanet() {
      let isJackable: Bool = false;
      let action: ref<ScriptableDeviceAction>;
      let actions: array<ref<DeviceAction>>;
      let context: GetActionsContext;
      this.GetQuickHackActions(actions, context);
      let i: Int32 = 0;
      while i < ArraySize(actions) {
        action = actions[i] as ScriptableDeviceAction;
        if IsDefined(action) && action.GetObjectActionID() == t"Items.PingDevice" {
          isJackable = true;
        }
        i += 1;
      }
      if isJackable {
        this.m_hasNetworkBackdoor = true;
        this.SetHasPersonalLinkSlot(true);
        return !this.WasHackingMinigameSucceeded();
      }
    }


    let standaloneName: String = GetLocalizedText(this.GetDeviceName());
    if SJKI_IsTargetDevice(standaloneName) && this.IsON() {
      this.m_hasNetworkBackdoor = true;
      this.SetHasPersonalLinkSlot(true);
      this.SetMinigameState(HackingMinigameState.Unknown);
      this.TurnAuthorizationModuleON();
      this.m_skillCheckContainer.GetHackingSlot().SetIsPassed(false);
      this.m_skillCheckContainer.GetHackingSlot().CheckPerformed();
      if !this.m_isSJKIStandaloneDevice {
        this.m_isSJKIStandaloneDevice = true;
        SJKI_Log("ShouldExposePersonalLinkAction: arming [" + standaloneName + "]");
      }
      return true;
    }

    return false;

  } else {
    return false;
  }
}


@replaceMethod(ScriptableDeviceComponentPS)
protected func ResolvePersonalLinkConnection(evt: ref<TogglePersonalLink>, abortOperations: Bool) -> Void {

  let isStandalone: Bool = this.m_isSJKIStandaloneDevice;

  SJKI_Log("ResolvePersonalLinkConnection: isStandalone=" + ToString(isStandalone)
    + " abort=" + ToString(abortOperations)
    + " linkStatus=" + ToString(EnumInt(this.m_personalLinkStatus)));

  if isStandalone {
    if abortOperations {
      SJKI_Log("ResolvePersonalLinkConnection: abort — clearing flag");
      this.m_isSJKIStandaloneDevice = false;
      return;
    }
    if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) {
      SJKI_Log("ResolvePersonalLinkConnection: opening HUD");
      SJKI_OpenBreachHUD(this);
    } else {
      SJKI_Log("ResolvePersonalLinkConnection: not CONNECTED — no action");
    }
    return;
  }


  let hasNetworkBackdoor: Bool = this.HasNetworkBackdoor();
  if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTING) { return; }
  if Equals(this.m_personalLinkStatus, EPersonalLinkConnectionStatus.CONNECTED) {
    if this.m_shouldSkipNetrunnerMinigame || !hasNetworkBackdoor {
      this.SetMinigameState(HackingMinigameState.Succeeded);
    }
    if hasNetworkBackdoor && !this.WasHackingMinigameSucceeded() {
      let dive: ref<ToggleNetrunnerDive> = this.ActionToggleNetrunnerDive(abortOperations, evt.m_shouldSkipMiniGame);
      dive.SetExecutor(evt.GetExecutor());
      this.ExecutePSAction(dive, evt.GetInteractionLayer());
    } else {
      this.ResolveOtherSkillchecks();
    }
  } else {
    if hasNetworkBackdoor {
      let dive: ref<ToggleNetrunnerDive> = this.ActionToggleNetrunnerDive(true);
      dive.SetExecutor(evt.GetExecutor());
      this.ExecutePSAction(dive, evt.GetInteractionLayer());
    }
  }
}


@wrapMethod(ScriptableDeviceComponentPS)
public func FinalizeNetrunnerDive(state: HackingMinigameState) -> Void {

  SJKI_Log("FinalizeNetrunnerDive: isStandalone=" + ToString(this.m_isSJKIStandaloneDevice)
    + " state=" + ToString(EnumInt(state)));

  if !this.m_isSJKIStandaloneDevice {
    wrappedMethod(state);
    return;
  }

  let gi: GameInstance = this.GetGameInstance();

  if Equals(state, HackingMinigameState.Succeeded) {
    let minigameBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(gi)
      .Get(GetAllBlackboardDefs().HackingMinigame);

    let doBasic:   Bool = false;
    let doNPCs:    Bool = false;
    let doCameras: Bool = false;
    let doTurrets: Bool = false;

    if IsDefined(minigameBB) {
      let activePrograms: array<TweakDBID> = FromVariant<array<TweakDBID>>(
        minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms));
      let pi: Int32 = 0;
      while pi < ArraySize(activePrograms) {
        let prog: TweakDBID = activePrograms[pi];
        if      prog == t"MinigameAction.UnlockQuickhacks"       { doBasic   = true; }
        else if prog == t"MinigameAction.UnlockNPCQuickhacks"    { doNPCs    = true; }
        else if prog == t"MinigameAction.UnlockCameraQuickhacks" { doCameras = true; }
        else if prog == t"MinigameAction.UnlockTurretQuickhacks" { doTurrets = true; }
        pi += 1;
      }
    }

    SJKI_Log("FinalizeNetrunnerDive: success Basic=" + ToString(doBasic)
      + " NPC=" + ToString(doNPCs) + " Camera=" + ToString(doCameras)
      + " Turret=" + ToString(doTurrets));

    if doBasic || doNPCs || doCameras || doTurrets {
      SJKI_Propagate(this, gi, doBasic, doNPCs, doCameras, doTurrets);
    }

  } else if Equals(state, HackingMinigameState.Failed) {
    SJKI_ApplyFailureLock(this, gi);
  }

  this.m_isSJKIStandaloneDevice = false;
  this.SetMinigameState(HackingMinigameState.Unknown);
  let player: ref<GameObject> = this.GetPlayerMainObject();
  let jackOut: ref<ToggleNetrunnerDive> = this.ActionToggleNetrunnerDive(true);
  jackOut.SetExecutor(player);
  this.ExecutePSAction(jackOut);
  SJKI_Log("FinalizeNetrunnerDive: done state=" + ToString(EnumInt(state)));
}



@wrapMethod(MinigameGenerationRuleScalingPrograms)
public final func FilterPlayerPrograms(programs: script_ref<array<MinigameProgramData>>) -> Void {

  let device: ref<Device> = this.m_entity as Device;
  let isStandalone: Bool = IsDefined(device)
    && SJKI_IsTargetDevice(GetLocalizedText(device.GetDeviceName()));

  if !isStandalone {
    wrappedMethod(programs);
    return;
  }

  SJKI_Log("FilterPlayerPrograms: [" + GetLocalizedText(device.GetDeviceName()) + "]");


  ArrayClear(Deref(programs));

  let gi: GameInstance = device.GetGame();
  let ts = GameInstance.GetTargetingSystem(gi);
  let query: TargetSearchQuery;
  query.testedSet              = TargetingSet.Complete;
  query.maxDistance            = 50.0;
  query.filterObjectByDistance = true;
  query.ignoreInstigator       = true;

  let parts: array<TS_TargetPartInfo>;
  ts.GetTargetParts(device, query, parts);

  let needCameras: Bool = false;
  let needTurrets: Bool = false;
  let needNPCs:    Bool = false;
  let i: Int32 = 0;
  while i < ArraySize(parts) {
    let obj: ref<GameObject> = TS_TargetPartInfo.GetComponent(parts[i]).GetEntity() as GameObject;
    if !needNPCs {
      let npc: ref<NPCPuppet> = obj as NPCPuppet;
      if IsDefined(npc) && ScriptedPuppet.IsAlive(npc) { needNPCs = true; }
    }
    let near: ref<Device> = obj as Device;
    if IsDefined(near) && near.GetDevicePS().IsON() {
      if !needCameras && IsDefined(near.GetDevicePS() as SurveillanceCameraControllerPS) { needCameras = true; }
      if !needTurrets && IsDefined(near.GetDevicePS() as SecurityTurretControllerPS)     { needTurrets = true; }
    }
    i += 1;
  }

  SJKI_InjectDaemon(programs, t"MinigameAction.UnlockQuickhacks");
  if needCameras { SJKI_InjectDaemon(programs, t"MinigameAction.UnlockCameraQuickhacks"); }
  if needTurrets { SJKI_InjectDaemon(programs, t"MinigameAction.UnlockTurretQuickhacks"); }
  if needNPCs    { SJKI_InjectDaemon(programs, t"MinigameAction.UnlockNPCQuickhacks"); }

  SJKI_Log("FilterPlayerPrograms: done Basic=true Camera=" + ToString(needCameras)
    + " Turret=" + ToString(needTurrets) + " NPC=" + ToString(needNPCs));
}

private func SJKI_InjectDaemon(programs: script_ref<array<MinigameProgramData>>, actionID: TweakDBID) -> Void {
  let record: wref<MinigameAction_Record> = TweakDBInterface.GetMinigameActionRecord(actionID);
  if !IsDefined(record) { return; }
  let d: MinigameProgramData;
  d.actionID    = actionID;
  d.programName = StringToName(LocKeyToString(record.ObjectActionUI().Caption()));
  ArrayPush(Deref(programs), d);
}



@if(ModuleExists("BetterNetrunning"))
@wrapMethod(ScriptableDeviceComponentPS)
public func SetHasPersonalLinkSlot(isPersonalLinkSlotPresent: Bool) -> Void {
  if !isPersonalLinkSlotPresent {
    let ownerDevice: ref<Device> = this.GetOwnerEntityWeak() as Device;
    let isStandalone: Bool = this.m_isSJKIStandaloneDevice
      || (IsDefined(ownerDevice) && SJKI_IsTargetDevice(GetLocalizedText(ownerDevice.GetDeviceName())));
    if isStandalone {
      SJKI_Log("SetHasPersonalLinkSlot: blocked disable on standalone");
      return;
    }
  }
  wrappedMethod(isPersonalLinkSlotPresent);
}



@if(ModuleExists("BetterNetrunning"))
private func SJKI_ApplyFailureLock(
  ps: ref<ScriptableDeviceComponentPS>,
  gi: GameInstance
) -> Void {

  let currentTime: Float = GameInstance.GetTimeSystem(gi).GetGameTimeStamp();
  ps.m_betterNetrunningAPBreachFailedTimestamp = currentTime;
  SJKI_Log("SJKI_ApplyFailureLock: stamped AP failure timestamp=" + ToString(currentTime));
}

@if(!ModuleExists("BetterNetrunning"))
private func SJKI_ApplyFailureLock(
  ps: ref<ScriptableDeviceComponentPS>,
  gi: GameInstance
) -> Void {

}

@if(ModuleExists("BetterNetrunning"))
private func SJKI_Propagate(
  ps:        ref<ScriptableDeviceComponentPS>,
  gi:        GameInstance,
  doBasic:   Bool,
  doNPCs:    Bool,
  doCameras: Bool,
  doTurrets: Bool
) -> Void {

  let player: ref<PlayerPuppet> = GetPlayer(gi);
  if !IsDefined(player) {
    SJKI_Log("SJKI_Propagate: player not found, aborting");
    return;
  }

  let currentTime: Float = GameInstance.GetTimeSystem(gi).GetGameTimeStamp();

  let ts = GameInstance.GetTargetingSystem(gi);
  let unlocked: Int32 = 0;


  if doNPCs {
    let npcQuery: TargetSearchQuery;
    npcQuery.testedSet              = TargetingSet.Complete;
    npcQuery.searchFilter           = TSF_All(TSFMV.Obj_Puppet);
    npcQuery.maxDistance            = 50.0;
    npcQuery.filterObjectByDistance = true;
    npcQuery.ignoreInstigator       = true;

    let npcParts: array<TS_TargetPartInfo>;
    ts.GetTargetParts(player, npcQuery, npcParts);
    SJKI_Log("SJKI_Propagate(BN): NPC scan found " + ToString(ArraySize(npcParts)) + " puppets");

    let ni: Int32 = 0;
    while ni < ArraySize(npcParts) {
      let npc: ref<ScriptedPuppet> = TS_TargetPartInfo.GetComponent(npcParts[ni]).GetEntity() as ScriptedPuppet;
      if IsDefined(npc) && ScriptedPuppet.IsAlive(npc) {
        let npcPS: ref<ScriptedPuppetPS> = npc.GetPS() as ScriptedPuppetPS;
        if IsDefined(npcPS) {
          npcPS.SetIsBreached(true);
          ps.QueuePSEvent(npcPS, npcPS.ActionSetExposeQuickHacks());
          let stampEvt: ref<SJKIStampNPCBreachedEvent> = new SJKIStampNPCBreachedEvent();
          ps.QueuePSEvent(npcPS, stampEvt);
          SJKI_Log("SJKI_Propagate(BN): queued stamp for ["
            + TDBID.ToStringDEBUG(npc.GetRecordID()) + "]");
          unlocked += 1;
        }
      }
      ni += 1;
    }
  }

  // --- Device scan (no searchFilter = devices only) ---
  if doBasic || doCameras || doTurrets {
    let devQuery: TargetSearchQuery;
    devQuery.testedSet              = TargetingSet.Complete;
    devQuery.maxDistance            = 50.0;
    devQuery.filterObjectByDistance = true;
    devQuery.ignoreInstigator       = true;

    let devParts: array<TS_TargetPartInfo>;
    ts.GetTargetParts(player, devQuery, devParts);
    SJKI_Log("SJKI_Propagate(BN): device scan found " + ToString(ArraySize(devParts)) + " objects");

    let di: Int32 = 0;
    while di < ArraySize(devParts) {
      let nearDevice: ref<Device> = TS_TargetPartInfo.GetComponent(devParts[di]).GetEntity() as Device;
      if IsDefined(nearDevice) && nearDevice.GetDevicePS().IsON() {
        let devPS: ref<ScriptableDeviceComponentPS> =
          nearDevice.GetDevicePS() as ScriptableDeviceComponentPS;
        if IsDefined(devPS) {
          let isCamera: Bool = IsDefined(devPS as SurveillanceCameraControllerPS);
          let isTurret: Bool = IsDefined(devPS as SecurityTurretControllerPS);
          let shouldUnlock: Bool =
            (doBasic   && !isCamera && !isTurret) ||
            (doCameras && isCamera)               ||
            (doTurrets && isTurret);
          if shouldUnlock {
            if doBasic   && !isCamera && !isTurret { devPS.m_betterNetrunningUnlockTimestampBasic   = currentTime; }
            if doCameras && isCamera               { devPS.m_betterNetrunningUnlockTimestampCameras = currentTime; }
            if doTurrets && isTurret               { devPS.m_betterNetrunningUnlockTimestampTurrets = currentTime; }
            devPS.ExposeQuickHacks(true);
            unlocked += 1;
          }
        }
      }
      di += 1;
    }
  }

  SJKI_Log("SJKI_Propagate(BN): unlocked " + ToString(unlocked) + " entities");
}

@if(!ModuleExists("BetterNetrunning"))
private func SJKI_Propagate(
  ps:        ref<ScriptableDeviceComponentPS>,
  gi:        GameInstance,
  doBasic:   Bool,
  doNPCs:    Bool,
  doCameras: Bool,
  doTurrets: Bool
) -> Void {
  let player: ref<PlayerPuppet> = GetPlayer(gi);
  if !IsDefined(player) {
    SJKI_Log("SJKI_Propagate: player not found, aborting");
    return;
  }

  let ts = GameInstance.GetTargetingSystem(gi);
  let query: TargetSearchQuery;
  query.testedSet              = TargetingSet.Complete;
  query.maxDistance            = 50.0;
  query.filterObjectByDistance = true;
  query.ignoreInstigator       = true;

  let parts: array<TS_TargetPartInfo>;
  ts.GetTargetParts(player, query, parts);
  SJKI_Log("SJKI_Propagate(vanilla): scanning " + ToString(ArraySize(parts)) + " targets");

  let unlocked: Int32 = 0;
  let i: Int32 = 0;
  while i < ArraySize(parts) {
    let obj: ref<GameObject> = TS_TargetPartInfo.GetComponent(parts[i]).GetEntity() as GameObject;

    let npc: ref<ScriptedPuppet> = obj as ScriptedPuppet;
    if IsDefined(npc) && doNPCs && ScriptedPuppet.IsAlive(npc) {
      let npcPS: ref<ScriptedPuppetPS> = npc.GetPS() as ScriptedPuppetPS;
      if IsDefined(npcPS) {
        npcPS.SetIsBreached(true);
        ps.QueuePSEvent(npcPS, npcPS.ActionSetExposeQuickHacks());
        let stampEvt: ref<SJKIStampNPCBreachedEvent> = new SJKIStampNPCBreachedEvent();
        ps.QueuePSEvent(npcPS, stampEvt);
        unlocked += 1;
      }
    } else {
      let nearDevice: ref<Device> = obj as Device;
      if IsDefined(nearDevice) && nearDevice.GetDevicePS().IsON() {
        let devPS: ref<ScriptableDeviceComponentPS> =
          nearDevice.GetDevicePS() as ScriptableDeviceComponentPS;
        if IsDefined(devPS) {
          let isCamera: Bool = IsDefined(devPS as SurveillanceCameraControllerPS);
          let isTurret: Bool = IsDefined(devPS as SecurityTurretControllerPS);
          let shouldUnlock: Bool =
            (doBasic   && !isCamera && !isTurret) ||
            (doCameras && isCamera)               ||
            (doTurrets && isTurret);
          if shouldUnlock {
            devPS.ExposeQuickHacks(true);
            unlocked += 1;
          }
        }
      }
    }

    i += 1;
  }

  SJKI_Log("SJKI_Propagate(vanilla): unlocked " + ToString(unlocked) + " entities");
}
