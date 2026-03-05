
import HackthePlanetForRealConfig.*

private func CSNL_Log(msg: String) -> Void {
  if HackthePlanetForRealSettings.EnableDebugLog() {
    LogChannel(n"DEBUG", s"[CSNL] \(msg)");
  };
}



@addField(ScriptedPuppetPS)
public persistent let m_sjkiNPCSubnetBreached: Bool;


@wrapMethod(ScriptedPuppet)
protected cb func OnGameAttached() -> Bool {
  let result: Bool = wrappedMethod();
  if this.IsCrowd() {
    this.UpdateQuickHackableState(true);
    this.UpdateLootInteraction();
  };
  return result;
}


@wrapMethod(ScriptedPuppet)
protected func ToggleInteractionLayers() -> Void {
  wrappedMethod();
  if this.IsCrowd() {
    if this.GetRecord().CanHaveGenericTalk() {
      this.EnableInteraction(n"GenericTalk", true);
    };
    this.EnableInteraction(n"Grapple", true);
    this.EnableInteraction(n"TakedownLayer", true);
    this.EnableInteraction(n"AerialTakedown", true);
    this.EnableInteraction(n"Loot", true);
  };
}


@wrapMethod(ScriptedPuppet)
public const func IsQuickHackAble() -> Bool {
  if this.IsCrowd() { return true; };
  if this.IsVendor() { return true; };
  return wrappedMethod();
}


@wrapMethod(ScriptedPuppet)
protected const func ShouldRegisterToHUD() -> Bool {
  if this.IsCrowd() { return true; };
  if this.IsVendor() { return true; };
  return wrappedMethod();
}


@wrapMethod(ScriptedPuppet)
public const func GetCurrentOutline() -> EFocusOutlineType {
  if (this.IsCivilian() && !this.IsAggressive()) || this.IsVendor() {
    return EFocusOutlineType.NEUTRAL;
  };
  if GameObject.IsFriendlyTowardsPlayer(this) {
    return EFocusOutlineType.FRIENDLY;
  };
  return wrappedMethod();
}



@wrapMethod(ScriptedPuppetPS)
public final const func GetAllChoices(
  const actions:   script_ref<array<wref<ObjectAction_Record>>>,
  const context:   script_ref<GetActionsContext>,
  puppetActions:   script_ref<array<ref<PuppetAction>>>
) -> Void {

  wrappedMethod(actions, context, puppetActions);


  let npc: ref<ScriptedPuppet> = this.GetOwnerEntity() as ScriptedPuppet;
  if !IsDefined(npc) { return; }
  if !npc.IsCrowd() && !npc.IsVendor() { return; }


  CSNL_Log("GetAllChoices: checking ["
    + TDBID.ToStringDEBUG(npc.GetRecordID())
    + "] breached=" + ToString(this.m_sjkiNPCSubnetBreached));
  if this.m_sjkiNPCSubnetBreached { return; }

  CSNL_Log("GetAllChoices: locking unbreached ["
    + TDBID.ToStringDEBUG(npc.GetRecordID()) + "]");


  let i: Int32 = ArraySize(Deref(puppetActions)) - 1;
  while i >= 0 {
    let action: ref<PuppetAction> = Deref(puppetActions)[i];
    if IsDefined(action) && !IsDefined(action as PingSquad) {
      action.SetInactiveWithReason(false, "LocKey#27728");
    };
    i -= 1;
  }
}
