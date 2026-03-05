module AntiTheftMeasures.CounterMeasure.LethalCountermeasures

// -----------------------------------------------------------------------------
// LethalCountermeasures - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}

public func ActivateLethalCountermeasures(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
    let settings = SettingsSystem.Get();

    if !settings.lethalEnabled {
        return false;
    }

    if !vehicleComponentPS.IsCountermeasureApplicable(settings.lethalEconomyCategory) {
        return false;
    }

    if !PassProbabilityCheck(settings.lethalProbability) {
        return false;
    }

    let detonationCallback = DetonationCallback.Create(vehicleComponentPS);

    // Instant (2s) or delayed (4s) detonation
    let player = GetPlayer(GetGameInstance());
    let delaySystem = GameInstance.GetDelaySystem(player.GetGame());
    delaySystem
        .DelayCallback(detonationCallback, settings.lethalInstantDetonation ? 2.0 : 4.0, false);

    return true;
}

