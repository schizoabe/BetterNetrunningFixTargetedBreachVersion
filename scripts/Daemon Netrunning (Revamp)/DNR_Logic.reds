module DNR.Logic
import DNR.Core.*
import DNR.Settings.*

public func DNR_BP_GetActivePrograms(bb: ref<IBlackboard>) -> array<TweakDBID> =
  FromVariant<array<TweakDBID>>(bb.GetVariant(GetAllBlackboardDefs().HackingMinigame.ActivePrograms))

public func DNR_BP_HasProgram(list: array<TweakDBID>, id: TweakDBID) -> Bool {
  let i: Int32 = 0;
  while i < ArraySize(list) { if list[i] == id { return true; }; i += 1; }
  return false;
}

public func DNR_BP_TryQuickhack(target: wref<GameObject>, id: TweakDBID) -> Bool {
  if IsDefined(target as PlayerPuppet) { return false; }
  let puppet: wref<ScriptedPuppet> = target as ScriptedPuppet;
  if !IsDefined(puppet) || puppet.IsDead() { return false; }
  let player: wref<GameObject> = GetPlayer(target.GetGame());
  let act: ref<PuppetAction> = new PuppetAction();
  act.RegisterAsRequester(target.GetEntityID());
  act.SetExecutor(player);
  act.SetObjectActionID(id);
  act.SetUp(puppet.GetPuppetPS());
  act.SetDisableSpread(true);
  act.ProcessRPGAction(target.GetGame());
  return true;
}

public func DNR_BP_VisitedHas(visited: array<PersistentID>, id: PersistentID) -> Bool {
  let i: Int32 = 0; while i < ArraySize(visited) { if Equals(visited[i], id) { return true; }; i += 1; }
  return false;
}

public func DNR_BP_IsFriendlyOrCompanion(puppet: wref<ScriptedPuppet>, player: wref<PlayerPuppet>) -> Bool {
  if !IsDefined(puppet) || !IsDefined(player) { return false; }
  let attitude: EAIAttitude = puppet.GetAttitudeTowards(player);
  if Equals(attitude, EAIAttitude.AIA_Friendly) {
    return true;
  }
  return false;
}

public func DNR_BP_CollectAllPuppets(root: ref<AccessPointControllerPS>, const devices: script_ref<[ref<DeviceComponentPS>]>, out puppets: array<wref<GameObject>>) -> Void {
  let queueAP: array<ref<AccessPointControllerPS>>;
  let visited: array<PersistentID>;
  let seen: array<EntityID>;
  let tmp: array<ref<DeviceComponentPS>>;
  let idx: Int32 = 0;
  ArrayPush(visited, root.GetID());

  let i: Int32 = 0;
  while i < ArraySize(Deref(devices)) {
    let ap: ref<AccessPointControllerPS> = Deref(devices)[i] as AccessPointControllerPS;
    if IsDefined(ap) && !DNR_BP_VisitedHas(visited, ap.GetID()) {
      ArrayPush(queueAP, ap);
      ArrayPush(visited, ap.GetID());
    } else {
      let link: ref<PuppetDeviceLinkPS> = Deref(devices)[i] as PuppetDeviceLinkPS;
      if IsDefined(link) {
        let go: wref<GameObject> = link.GetOwnerEntityWeak() as GameObject;
        if IsDefined(go) && !IsDefined(go as PlayerPuppet) && !ArrayContains(seen, go.GetEntityID()) {
          ArrayPush(puppets, go);
          ArrayPush(seen, go.GetEntityID());
        };
      };
    };
    i += 1;
  }

  while idx < ArraySize(queueAP) {
    let current: ref<AccessPointControllerPS> = queueAP[idx]; idx += 1;
    current.GetChildren(tmp);
    i = 0;
    while i < ArraySize(tmp) {
      let dev: ref<DeviceComponentPS> = tmp[i];
      let asAP: ref<AccessPointControllerPS> = dev as AccessPointControllerPS;
      if IsDefined(asAP) {
        if !DNR_BP_VisitedHas(visited, asAP.GetID()) {
          ArrayPush(queueAP, asAP);
          ArrayPush(visited, asAP.GetID());
        }
      } else {
        let link2: ref<PuppetDeviceLinkPS> = dev as PuppetDeviceLinkPS;
        if IsDefined(link2) {
          let go2: wref<GameObject> = link2.GetOwnerEntityWeak() as GameObject;
          if IsDefined(go2) && !IsDefined(go2 as PlayerPuppet) && !ArrayContains(seen, go2.GetEntityID()) {
            ArrayPush(puppets, go2);
            ArrayPush(seen, go2.GetEntityID());
          }
        }
      }
      i += 1;
    }
  }
}

@if(ModuleExists("RadialBreach"))
public func DNR_IntegrateUnlinkedPuppets(root: ref<AccessPointControllerPS>, out puppets: array<wref<GameObject>>) -> Void {
  let allPuppets: array<wref<GameObject>> = root.GetAllNearbyObjects();
  let i: Int32 = 0;
  while i < ArraySize(allPuppets) {
    if !ArrayContains(puppets, allPuppets[i]) {
      ArrayPush(puppets, allPuppets[i]);
    }
    i += 1;
  }
}

public class DNR_ApplyNextQueuedHack extends Event {
  public let hacks: array<TweakDBID>;
  public let index: Int32;
}

@addMethod(ScriptedPuppet)
protected cb func OnDNR_ApplyNextQueuedHack(evt: ref<DNR_ApplyNextQueuedHack>) -> Bool {
  if this.IsDead() { return false; }
  let ok: Bool = DNR_BP_TryQuickhack(this, evt.hacks[evt.index]);
  if ok && evt.index + 1 < ArraySize(evt.hacks) && !this.IsDead() {
    let s: ref<DNR_Settings> = DNR_Svc();
    let step: Float = IsDefined(s) ? s.stepDelaySeconds : 0.60;
    let nextEvt: ref<DNR_ApplyNextQueuedHack> = new DNR_ApplyNextQueuedHack();
    nextEvt.hacks = evt.hacks;
    nextEvt.index = evt.index + 1;
    GameInstance.GetDelaySystem(this.GetGame()).DelayEvent(this, nextEvt, step);
  }
  return true;
}

@if(ModuleExists("RadialBreach"))
@wrapMethod(AccessPointControllerPS)
private final func RefreshSlaves(const devices: script_ref<[ref<DeviceComponentPS>]>) -> Void {
  wrappedMethod(devices);
  let bbSys: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGameInstance());
  let bb: ref<IBlackboard> = bbSys.Get(GetAllBlackboardDefs().HackingMinigame);
  if !IsDefined(bb) { return; }
  let progs: array<TweakDBID> = DNR_BP_GetActivePrograms(bb);
  if ArraySize(progs) == 0 { return; }
  
  let puppets: array<wref<GameObject>>;
  DNR_BP_CollectAllPuppets(this, devices, puppets);
  DNR_IntegrateUnlinkedPuppets(this, puppets);
  
  let s: ref<DNR_Settings> = DNR_Svc();
  let requireTagged: Bool = IsDefined(s) && s.enableRules && s.bpdeviceRequiresTagged;
  
  let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
  let i: Int32 = 0;
  while i < ArraySize(puppets) {
    let p: wref<GameObject> = puppets[i];
    let sp: wref<ScriptedPuppet> = p as ScriptedPuppet;
    if IsDefined(sp) {
      let shouldProcess: Bool = true;
      
      if !IsDefined(s) || !s.enableFriendlyFire {
        if DNR_BP_IsFriendlyOrCompanion(sp, player) {
          shouldProcess = false;
        }
      }
      
      if requireTagged && !DNR_BP_IsTargetTagged(sp) {
        shouldProcess = false;
      }
      
      if shouldProcess {
        let q: array<TweakDBID>;
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteCyberpsychosis") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteCyberpsychosis"), player) {
          ArrayPush(q, t"QuickHack.MadnessLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteSuicide") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteSuicide"), player) {
          ArrayPush(q, t"QuickHack.SuicideLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteSystemReset") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteSystemReset"), player) {
          ArrayPush(q, t"QuickHack.CyberwareMalfunctionLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteDetonateGrenade") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteDetonateGrenade"), player) {
          ArrayPush(q, t"QuickHack.GrenadeLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteNetworkOverload") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteNetworkOverload"), player) {
          ArrayPush(q, t"QuickHack.OverloadLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteNetworkContagion") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteNetworkContagion"), player) {
          ArrayPush(q, t"QuickHack.ContagionLvl4Hack");
        }
        if ArraySize(q) > 1 {
          if IsDefined(s) && s.enableRandomSequencing {
            let k: Int32 = ArraySize(q) - 1;
            let j: Int32;
            let tmp: TweakDBID;
            while k > 0 {
              j = RandRange(0, k + 1);
              tmp = q[k];
              q[k] = q[j];
              q[j] = tmp;
              k -= 1;
            }
          }
        }
        if ArraySize(q) > 0 {
          let start: ref<DNR_ApplyNextQueuedHack> = new DNR_ApplyNextQueuedHack();
          start.hacks = q;
          start.index = 0;
          sp.QueueEvent(start);
        }
      }
    }
    i += 1;
  }
}

@if(!ModuleExists("RadialBreach"))
@wrapMethod(AccessPointControllerPS)
private final func RefreshSlaves(const devices: script_ref<[ref<DeviceComponentPS>]>) -> Void {
  wrappedMethod(devices);
  let bbSys: ref<BlackboardSystem> = GameInstance.GetBlackboardSystem(this.GetGameInstance());
  let bb: ref<IBlackboard> = bbSys.Get(GetAllBlackboardDefs().HackingMinigame);
  if !IsDefined(bb) { return; }
  let progs: array<TweakDBID> = DNR_BP_GetActivePrograms(bb);
  if ArraySize(progs) == 0 { return; }
  
  let puppets: array<wref<GameObject>>;
  DNR_BP_CollectAllPuppets(this, devices, puppets);
  
  let s: ref<DNR_Settings> = DNR_Svc();
  let requireTagged: Bool = IsDefined(s) && s.enableRules && s.bpdeviceRequiresTagged;
  
  let player: ref<PlayerPuppet> = GetPlayer(this.GetGameInstance());
  let i: Int32 = 0;
  while i < ArraySize(puppets) {
    let p: wref<GameObject> = puppets[i];
    let sp: wref<ScriptedPuppet> = p as ScriptedPuppet;
    if IsDefined(sp) {
      let shouldProcess: Bool = true;
      
      if !IsDefined(s) || !s.enableFriendlyFire {
        if DNR_BP_IsFriendlyOrCompanion(sp, player) {
          shouldProcess = false;
        }
      }
      
      if requireTagged && !DNR_BP_IsTargetTagged(sp) {
        shouldProcess = false;
      }
      
      if shouldProcess {
        let q: array<TweakDBID>;
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteCyberpsychosis") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteCyberpsychosis"), player) {
          ArrayPush(q, t"QuickHack.MadnessLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteSuicide") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteSuicide"), player) {
          ArrayPush(q, t"QuickHack.SuicideLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteSystemReset") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteSystemReset"), player) {
          ArrayPush(q, t"QuickHack.CyberwareMalfunctionLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteDetonateGrenade") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteDetonateGrenade"), player) {
          ArrayPush(q, t"QuickHack.GrenadeLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteNetworkOverload") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteNetworkOverload"), player) {
          ArrayPush(q, t"QuickHack.OverloadLvl4Hack");
        }
        if DNR_BP_HasProgramAny(progs, t"MinigameAction.RemoteNetworkContagion") && DNR_BP_Roll(DNR_BP_ChanceFor(t"MinigameAction.RemoteNetworkContagion"), player) {
          ArrayPush(q, t"QuickHack.ContagionLvl4Hack");
        }
        if ArraySize(q) > 1 {
          if IsDefined(s) && s.enableRandomSequencing {
            let k: Int32 = ArraySize(q) - 1;
            let j: Int32;
            let tmp: TweakDBID;
            while k > 0 {
              j = RandRange(0, k + 1);
              tmp = q[k];
              q[k] = q[j];
              q[j] = tmp;
              k -= 1;
            }
          }
        }
        if ArraySize(q) > 0 {
          let start: ref<DNR_ApplyNextQueuedHack> = new DNR_ApplyNextQueuedHack();
          start.hacks = q;
          start.index = 0;
          sp.QueueEvent(start);
        }
      }
    }
    i += 1;
  }
}