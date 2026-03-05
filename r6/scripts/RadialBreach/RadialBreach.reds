module RadialBreach
import RadialBreach.Config.*

@if(ModuleExists("BetterNetrunning"))
import BetterNetrunningConfig.*

///////////////////////////////////////////////////////////////////////////////////////////////
// Exposed methods

@addMethod(GameComponentPS)
public final func GetAllNearbyObjects() -> array<wref<GameObject>> {
  let obj: ref<GameObject>;
  let objects: array<wref<GameObject>>;
  let targetParts: array<TS_TargetPartInfo> = this.GetRadialBreachTargets();
  for target in targetParts {
    obj = TS_TargetPartInfo.GetComponent(target).GetEntity() as GameObject;
    if IsDefined(obj) {
      ArrayPush(objects, obj);
    };
  };
  return objects;
}

@addMethod(GameComponentPS)
public final func GetAllNearbyEnemyPuppets() -> array<wref<GameObject>> {
  let puppet: ref<NPCPuppet>;
  let objects: array<wref<GameObject>>;
  let targetParts: array<TS_TargetPartInfo> = this.GetRadialBreachTargets();
  for target in targetParts {
    puppet = TS_TargetPartInfo.GetComponent(target).GetEntity() as NPCPuppet;
    if IsDefined(puppet) && puppet.IsEnemy() {
      ArrayPush(objects, puppet);
    };
  };
  return objects;
}

@addMethod(GameComponentPS)
public final func GetAllNearbyPuppets() -> array<wref<GameObject>> {
  let puppet: ref<NPCPuppet>;
  let objects: array<wref<GameObject>>;
  let targetParts: array<TS_TargetPartInfo> = this.GetRadialBreachTargets();
  for target in targetParts {
    puppet = TS_TargetPartInfo.GetComponent(target).GetEntity() as NPCPuppet;
    if IsDefined(puppet) {
      ArrayPush(objects, puppet);
    };
  };
  return objects;
}

@addMethod(GameComponentPS)
public final func GetAllNearbyDevices() -> array<wref<GameObject>> {
  let device: ref<Device>;
  let objects: array<wref<GameObject>>;
  let targetParts: array<TS_TargetPartInfo> = this.GetRadialBreachTargets();
  for target in targetParts {
    device = TS_TargetPartInfo.GetComponent(target).GetEntity() as Device;
    if IsDefined(device) {
      ArrayPush(objects, device);
    };
  };
  return objects;
}

@addMethod(GameComponentPS)
public final func GetAllNearbyVehicles() -> array<wref<GameObject>> {
  let vehicle: ref<VehicleObject>;
  let objects: array<wref<GameObject>>;
  let targetParts: array<TS_TargetPartInfo> = this.GetRadialBreachTargets();
  for target in targetParts {
    vehicle = TS_TargetPartInfo.GetComponent(target).GetEntity() as VehicleObject;
    if IsDefined(vehicle) {
      ArrayPush(objects, vehicle);
    };
  };
  return objects;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Network unlocks

@if(!ModuleExists("BetterNetrunning"))
@wrapMethod(AccessPointControllerPS)
private final func RefreshSlaves(const devices: script_ref<array<ref<DeviceComponentPS>>>) -> Void {
  wrappedMethod(devices);
  this.RadialBreach(true, true, true, true, true);
}

@addMethod(AccessPointControllerPS)
public final func RadialBreach(unlockDevices: Bool, unlockNPCs: Bool, unlockCameras: Bool, unlockTurrets: Bool, opt applyStatus: Bool) -> Void {
  let i: Int32 = 0;
  let npc: ref<NPCPuppet>;
  let device: ref<Device>;
  let vehicle: wref<VehicleObject>;
  let targetParts: array<TS_TargetPartInfo> = this.GetRadialBreachTargets();
  while i < ArraySize(targetParts) {
    npc = TS_TargetPartInfo.GetComponent(targetParts[i]).GetEntity() as NPCPuppet;
    device = TS_TargetPartInfo.GetComponent(targetParts[i]).GetEntity() as Device;
    vehicle = TS_TargetPartInfo.GetComponent(targetParts[i]).GetEntity() as VehicleObject;
    if unlockNPCs && IsDefined(npc) {
      let puppetPS: wref<ScriptedPuppetPS> = npc.GetPS();
      puppetPS.SetIsBreached(true);
      this.QueuePSEvent(puppetPS, puppetPS.ActionSetExposeQuickHacks());
      if applyStatus {
        StatusEffectHelper.ApplyStatusEffect(npc, t"MinigameAction.ICEBrokenMinigameMinor");
      };
    };
    if IsDefined(vehicle) && (unlockDevices || unlockNPCs) {
      vehicle.GetVehiclePS().ExposeQuickHacks(true);
    };
    if IsDefined(device) && device.GetDevicePS().IsON() {
      let isCamera: Bool = IsDefined(device.GetDevicePS() as SurveillanceCameraControllerPS);
      let isTurret: Bool = IsDefined(device.GetDevicePS() as SecurityTurretControllerPS);
      if unlockDevices && !isCamera && !isTurret {
        device.GetDevicePS().ExposeQuickHacks(true);
      };
      if unlockCameras && isCamera {
        device.GetDevicePS().ExposeQuickHacks(true);
      };
      if unlockTurrets && isTurret {
        device.GetDevicePS().ExposeQuickHacks(true);
      };
    };
    i += 1;
  };
}

@addMethod(GameComponentPS)
private final func GetRadialBreachTargets() -> array<TS_TargetPartInfo> {
  let targetParts: array<TS_TargetPartInfo>;
  let searchQuery: TargetSearchQuery = TSQ_ALL();
  let player: wref<GameObject> = GameInstance.GetPlayerSystem(this.GetGameInstance()).GetLocalPlayerControlledGameObject();
  let config: ref<RadialBreachSettings> = new RadialBreachSettings();
  if !config.enabled || !IsDefined(player) {
    return targetParts;
  };
  searchQuery.testedSet = TargetingSet.Complete;
  searchQuery.maxDistance = config.breachRange > 0.0 ? config.breachRange : 0.0;
  searchQuery.filterObjectByDistance = true;
  searchQuery.includeSecondaryTargets = false;
  searchQuery.ignoreInstigator = true;
  if (player as PlayerPuppet).GetIsAiming() {
    searchQuery.testedSet = TargetingSet.Frustum;
    searchQuery.maxDistance = searchQuery.maxDistance > 0.0 ? searchQuery.maxDistance + 10.0 : 0.0;
  };
  GameInstance.GetTargetingSystem(player.GetGame()).GetTargetParts(player, searchQuery, targetParts);
  return targetParts;
}

@addMethod(PlayerPuppet)
public func GetIsAiming() -> Bool {
  return this.m_isAiming;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// Better Netrunning

@if(ModuleExists("BetterNetrunning"))
@wrapMethod(VehicleObject)
public const func IsQuickHackAble() -> Bool {
  if !this.IsQuickHacksExposed() {
    let isNetrunner: Bool = this.IsNetrunner();
    let isQHBlockedByScene: Bool = QuickhackModule.IsQuickhackBlockedByScene(GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject());
    return isNetrunner && !isQHBlockedByScene;
  };
  return wrappedMethod();
}

@if(ModuleExists("BetterNetrunning"))
@wrapMethod(AccessPointControllerPS)
private final func RefreshSlaves(const devices: script_ref<array<ref<DeviceComponentPS>>>) -> Void {
  wrappedMethod(devices);
  if BetterNetrunningSettings.EnableClassicMode() {
    this.RadialBreach(true, true, true, true, true);
    return;
  };
  let minigameBB: ref<IBlackboard> = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().HackingMinigame);
  let minigamePrograms: array<TweakDBID> = FromVariant<array<TweakDBID>>(minigameBB.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms));
  let devices: Bool = false;
  let npcs: Bool = false;
  let cameras: Bool = false;
  let turrets: Bool = false;
  let i: Int32 = 0;
  while i < ArraySize(minigamePrograms) {
    switch minigamePrograms[i] {
      case t"MinigameAction.UnlockQuickhacks": devices = true; break;
      case t"MinigameAction.UnlockNPCQuickhacks": npcs = true; break;
      case t"MinigameAction.UnlockCameraQuickhacks": cameras = true; break;
      case t"MinigameAction.UnlockTurretQuickhacks": turrets = true; break;
    };
    i +=1;
  };
  if devices || npcs || cameras || turrets {
    this.RadialBreach(devices, npcs, cameras, turrets, true);
  };
}

@if(ModuleExists("BetterNetrunning"))
@wrapMethod(MinigameGenerationRuleScalingPrograms)
public final func FilterPlayerPrograms(programs: script_ref<array<MinigameProgramData>>) -> Void {
  wrappedMethod(programs);
  let config: ref<RadialBreachSettings> = new RadialBreachSettings();
  if !config.enabled || BetterNetrunningSettings.EnableClassicMode() || BetterNetrunningSettings.UnlockIfNoAccessPoint() {
    return;
  };
  let isBackdoor: Bool = !IsDefined(this.m_entity as AccessPoint) && IsDefined(this.m_entity as Device) && (this.m_entity as Device).GetDevicePS().IsConnectedToBackdoorDevice();
  let miniGameActionRecord: wref<MinigameAction_Record>;
  let hasDeviceUnlock: Bool = false;
  let hasPuppetUnlock: Bool = false;
  let hasCameraUnlock: Bool = false;
  let hasTurretUnlock: Bool = false;
  let data: ConnectedClassTypes;
  let i: Int32 = 0;
  while i < ArraySize(Deref(programs)) {
    miniGameActionRecord = TweakDBInterface.GetMinigameActionRecord(Deref(programs)[i].actionID);
    switch Deref(programs)[i].actionID {
      case t"MinigameAction.UnlockQuickhacks": hasDeviceUnlock = true; break;
      case t"MinigameAction.UnlockNPCQuickhacks": hasPuppetUnlock = true; break;
      case t"MinigameAction.UnlockCameraQuickhacks": hasCameraUnlock = true; break;
      case t"MinigameAction.UnlockTurretQuickhacks": hasTurretUnlock = true; break;
    };
    i += 1;
  };
  if (this.m_entity as GameObject).IsPuppet() {
    data = (this.m_entity as ScriptedPuppet).GetMasterConnectedClassTypes();
  } else {
    data = (this.m_entity as Device).GetDevicePS().CheckMasterConnectedClassTypes();
  };
  if !this.m_isRemoteBreach || (IsDefined(this.m_entity as ScriptedPuppet) && (this.m_entity as ScriptedPuppet).IsNetrunnerPuppet()) {
    if data.securityTurret && !hasTurretUnlock && !isBackdoor {
      this.AddMinigameAction(programs, t"MinigameAction.UnlockTurretQuickhacks", n"LocKey#34844");
    };
    if data.surveillanceCamera && !hasCameraUnlock {
      this.AddMinigameAction(programs, t"MinigameAction.UnlockCameraQuickhacks", n"LocKey#34844");
    };
  };
  if data.puppet && !hasPuppetUnlock && !isBackdoor {
    this.AddMinigameAction(programs, t"MinigameAction.UnlockNPCQuickhacks", n"LocKey#34844");
  };
  if !hasDeviceUnlock {
    this.AddMinigameAction(programs, t"MinigameAction.UnlockQuickhacks", n"LocKey#34844");
  };
}

@if(ModuleExists("BetterNetrunning"))
@addMethod(MinigameGenerationRuleScalingPrograms)
public final func AddMinigameAction(programs: script_ref<array<MinigameProgramData>>, actionID: TweakDBID, programName: CName) -> Void {
  let daemon: MinigameProgramData;
  daemon.actionID = actionID;
  daemon.programName = programName;
  ArrayInsert(Deref(programs), 0, daemon);
}

@if(ModuleExists("BetterNetrunning"))
@wrapMethod(SharedGameplayPS)
public final const func CheckMasterConnectedClassTypes() -> ConnectedClassTypes {
  let data: ConnectedClassTypes = wrappedMethod();
  let device: wref<Device>;
  let devicePS: wref<ScriptableDeviceComponentPS>;
  let nearbyObjects: array<wref<GameObject>> = this.GetAllNearbyObjects();
  let i: Int32 = 0;
  while i < ArraySize(nearbyObjects) {
    if data.puppet && data.surveillanceCamera && data.securityTurret {
      break;
    };
    if IsDefined(nearbyObjects[i] as NPCPuppet) {
      if !data.puppet && ScriptedPuppet.IsAlive(nearbyObjects[i]) {
        data.puppet = true;
      };
    } else {
      device = nearbyObjects[i] as Device;
      if IsDefined(device) {
        devicePS = device.GetDevicePS() as ScriptableDeviceComponentPS;
        if devicePS.IsON() && !devicePS.IsBroken() {
          switch devicePS.GetClassName() {
            case n"SurveillanceCameraControllerPS": data.surveillanceCamera = true; break;
            case n"SecurityTurretControllerPS": data.securityTurret = true; break;
          };
        };
      };
    };
    i += 1;
  };
  return data;
}
