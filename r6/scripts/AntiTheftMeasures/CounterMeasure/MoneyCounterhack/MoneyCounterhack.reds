module AntiTheftMeasures.CounterMeasure.MoneyCounterhack

// -----------------------------------------------------------------------------
// MoneyCounterhack - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Sound.{SoundSystem}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}
import AntiTheftMeasures.Utils.Payment.{DeductMoneyInPercents}

// Money counterhack
public func ActivateMoneyCounterhack(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
    let settings = SettingsSystem.Get();

    if !settings.moneyCounterhackEnabled {
        return false;
    }

    if !vehicleComponentPS.IsCountermeasureApplicable(settings.moneyCounterhackEconomyCategory) {
        return false;
    }

    if !PassProbabilityCheck(settings.moneyCounterhackProbability) {
        return false;
    }

    let moneyCounterhackValue = settings.moneyCounterhackValue;
    let deductedMoney = DeductMoneyInPercents(moneyCounterhackValue);
    let moneyDeducted = deductedMoney > 0;

    if moneyDeducted {
        // Play sound effect
        SoundSystem.Get().PlayMoneyTransfer();
    }

    return moneyDeducted;
}

