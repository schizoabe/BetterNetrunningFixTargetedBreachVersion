module AntiTheftMeasures.CounterMeasure.GlitchVisionAndHearing

// -----------------------------------------------------------------------------
// GlitchVisionAndHearing - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}

public func ActivateGlitchVisionAndHearing(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
    let settings = SettingsSystem.Get();

    if !settings.glitchVisionCounterhackEnabled {
        return false;
    }

    if !vehicleComponentPS
        .IsCountermeasureApplicable(settings.glitchVisionCounterhackEconomyCategory) {
        return false;
    }

    if !PassProbabilityCheck(settings.glitchVisionCounterhackProbability) {
        return false;
    }

    let player = GetPlayer(GetGameInstance());

    // Determine delay
    let glitchVisionDelayDuration = Cast<Float>(RandRange(1, settings.glitchVisionCounterhackValue));

    // Start the wave of blind effects with the determined delay
    let delaySystem = GameInstance.GetDelaySystem(player.GetGame());
    delaySystem
        .DelayCallback(GlitchVisionCallback.Create(player), glitchVisionDelayDuration, false);
    delaySystem
        .DelayCallback(
            GlitchVisionCallback.Create(player),
            glitchVisionDelayDuration + 10.0,
            false
        );
    delaySystem
        .DelayCallback(
            GlitchVisionCallback.Create(player),
            glitchVisionDelayDuration + 20.0,
            false
        );
    delaySystem
        .DelayCallback(
            GlitchVisionCallback.Create(player),
            glitchVisionDelayDuration + 30.0,
            false
        );
    delaySystem
        .DelayCallback(
            GlitchVisionCallback.Create(player),
            glitchVisionDelayDuration + 40.0,
            false
        );

    return true;
}

