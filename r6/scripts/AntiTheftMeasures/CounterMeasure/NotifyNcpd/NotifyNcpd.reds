module AntiTheftMeasures.CounterMeasure.NotifyNcpd

// -----------------------------------------------------------------------------
// NotifyNcpd - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}

public func NotifyNcpd(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
    let settings = SettingsSystem.Get();

    if !settings.notifyNcpdEnabled {
        return false;
    }

    if !vehicleComponentPS.IsCountermeasureApplicable(settings.notifyNcpdEconomyCategory) {
        return false;
    }

    if !PassProbabilityCheck(settings.notifyNcpdProbability) {
        return false;
    }

    let ps: wref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"PreventionSystem") as PreventionSystem;
    if ps == null {
        return false;
    }

    // Current wanted level
    let currentWantedLevel = ps.GetWantedLevelFact();
    if currentWantedLevel >= settings.notifyNcpdHeatValue {
        // Already on or above wanted level from settings
        return true;
    }

    let setWantedLevel: ref<SetWantedLevel> = new SetWantedLevel();
    setWantedLevel.m_forcePlayerPositionAsLastCrimePoint = true;
    setWantedLevel.m_wantedLevel = GetHeatStage();

    ps.QueueRequest(setWantedLevel);
    return true;
}

private func GetHeatStage() -> EPreventionHeatStage {
    // ATM settings
    let settings = SettingsSystem.Get();

    switch settings.notifyNcpdHeatValue {
        case 1:
            return EPreventionHeatStage.Heat_1;
        case 2:
            return EPreventionHeatStage.Heat_2;
        case 3:
            return EPreventionHeatStage.Heat_3;
        case 4:
            return EPreventionHeatStage.Heat_4;
        case 5:
            return EPreventionHeatStage.Heat_5;
    }

    return EPreventionHeatStage.Heat_0;
}

