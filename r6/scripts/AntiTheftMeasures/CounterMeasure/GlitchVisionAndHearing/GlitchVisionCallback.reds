module AntiTheftMeasures.CounterMeasure.GlitchVisionAndHearing

// -----------------------------------------------------------------------------
// GlitchVisionCallback - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Sound.{SoundSystem}

public class GlitchVisionCallback extends DelayCallback {
    let player: wref<PlayerPuppet>;

    public static func Create(player: ref<PlayerPuppet>) -> ref<GlitchVisionCallback> {
        let callback = new GlitchVisionCallback();
        callback.player = player;
        return callback;
    }

    public func Call() {
        SoundSystem.Get().PlayGlitch();
        StatusEffectHelper.ApplyStatusEffect(this.player, t"BaseStatusEffect.Blind");
    }
}

