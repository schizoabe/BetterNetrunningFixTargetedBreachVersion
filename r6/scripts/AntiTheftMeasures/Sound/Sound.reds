module AntiTheftMeasures.Sound

// -----------------------------------------------------------------------------
// Sound - Anti-Theft Measures
// -----------------------------------------------------------------------------
public final class SoundSystem extends ScriptableSystem {
    public static func Get() -> ref<SoundSystem> {
        return GameInstance
            .GetScriptableSystemsContainer(GetGameInstance())
            .Get(n"AntiTheftMeasures.Sound.SoundSystem") as SoundSystem;
    }

    public func PlayAccessGranted() -> Void {
        this.PlaySound(n"ui_hacking_access_panel");
    }

    public func PlayShortAlarm() -> Void {
        this.PlaySound(n"sq012_sc_02a_alarm");
    }

    public func PlayAlarm(gameObject: ref<GameObject>) -> Void {
        this.PlaySound(n"q304_sc_04_car_alarm_loop_start", gameObject);
    }

    public func PlayGlitch() -> Void {
        this.PlaySound(n"q305_blackwall_brooklyn_transition_start_glitch_01");
    }

    public func PlayMoneyTransfer() -> Void {
        this.PlaySound(n"ui_jingle_money");
    }

    public func PlayShutdown() -> Void {
        this.PlaySound(n"sq025_core_reset_shutdown");
    }

    public func PlayHotwire() -> Void {
        this.PlaySound(n"q003_sc_03_deal_sparks");
    }

    private func PlaySound(soundEvent: CName, opt gameObject: ref<GameObject>) -> Void {
        let target = IsDefined(gameObject) ? gameObject : GetPlayer(GetGameInstance());
        GameObject.PlaySoundEvent(target, soundEvent);
    }
}

