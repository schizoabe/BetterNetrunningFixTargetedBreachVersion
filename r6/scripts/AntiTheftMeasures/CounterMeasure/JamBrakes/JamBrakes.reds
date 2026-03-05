module AntiTheftMeasures.CounterMeasure.JamBrakes

// -----------------------------------------------------------------------------
// JamBrakes - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}

public func JamBrakes(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
    // ATM settings
    let settings = SettingsSystem.Get();
    if !settings.jamBrakesEnabled {
        return false;
    }

    if !vehicleComponentPS.IsCountermeasureApplicable(settings.jamBrakesEconomyCategory) {
        return false;
    }

    if !PassProbabilityCheck(settings.jamBrakesProbability) {
        return false;
    }
    let vehicle = vehicleComponentPS.GetOwnerEntity() as VehicleObject;
    if !IsDefined(vehicle) {
        // Vehicle despawned
        return false;
    }

    // Jam brakes for 20 seconds (20 ticks * 1s)
    // ForceBrakesFor feels terrible for this, pretty much petrifies the vehicle
    let delaySystem = GameInstance.GetDelaySystem(vehicle.GetGame());
    delaySystem.DelayCallback(JamBrakesCallback.Create(vehicle, 20), 1, false);

    return true;
}

