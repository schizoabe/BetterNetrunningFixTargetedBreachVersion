module AntiTheftMeasures.CounterMeasure.DeflateTires

// -----------------------------------------------------------------------------
// DeflateTires - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}

public func DeflateTires(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
    let settings = SettingsSystem.Get();

    if !settings.deflateTiresEnabled {
        return false;
    }

    if !vehicleComponentPS.IsCountermeasureApplicable(settings.deflateTiresEconomyCategory) {
        return false;
    }

    if !PassProbabilityCheck(settings.deflateTiresProbability) {
        return false;
    }

    vehicleComponentPS.DeflateTires();
    return true;
}

