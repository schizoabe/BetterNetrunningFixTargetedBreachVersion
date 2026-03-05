module AntiTheftMeasures.CounterMeasure

// -----------------------------------------------------------------------------
// CounterMeasure - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem}
import AntiTheftMeasures.CounterMeasure.GlitchVisionAndHearing.{ActivateGlitchVisionAndHearing}
import AntiTheftMeasures.CounterMeasure.LethalCountermeasures.{ActivateLethalCountermeasures}
import AntiTheftMeasures.CounterMeasure.DeflateTires.*
import AntiTheftMeasures.CounterMeasure.NotifyNcpd.*
import AntiTheftMeasures.CounterMeasure.MoneyCounterhack.*
import AntiTheftMeasures.CounterMeasure.JamBrakes.{JamBrakes}
import AntiTheftMeasures.Sound.{SoundSystem}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}

@if(ModuleExists("DarkFuture.Needs"))
import DarkFuture.Needs.{DFNerveSystem, DFChangeNeedValueProps}

public final class CounterMeasureSystem extends ScriptableSystem {
    public static func Get() -> ref<CounterMeasureSystem> {
        return GameInstance
            .GetScriptableSystemsContainer(GetGameInstance())
            .Get(n"AntiTheftMeasures.CounterMeasure.CounterMeasureSystem") as CounterMeasureSystem;
    }

    // Main vehicle countermeasure activation method
    public func ActivateVehicleCountermeasures(vehicleComponentPS: ref<VehicleComponentPS>) -> Bool {
        if !IsDefined(vehicleComponentPS) {
            // Vehicle despawned
            return false;
        }

        let vehicle = vehicleComponentPS.GetOwnerEntity();
        if vehicle.IsDestroyed() || vehicleComponentPS.GetIsSubmerged() {
            // Vehicle destroyed or submerged
            return false;
        }

        // Deflate tires
        let deflateTiresActivated = DeflateTires(vehicleComponentPS);

        // Notify NCPD
        let notifyNcpdActivated = NotifyNcpd(vehicleComponentPS);

        // Activate money counterhack
        let moneyCounterhackActivated = ActivateMoneyCounterhack(vehicleComponentPS);

        // Activate glitch vision and hearing
        let glitchVisionCounterhackActivated = ActivateGlitchVisionAndHearing(vehicleComponentPS);

        // Jam brakes
        let jamBrakesActivated = JamBrakes(vehicleComponentPS);

        // Detonate explosives
        let detonateExplosivesActivated = ActivateLethalCountermeasures(vehicleComponentPS);

        // Dark Future - Reduce nerve
        this.ReduceNerve();

        return deflateTiresActivated
            || notifyNcpdActivated
            || moneyCounterhackActivated
            || glitchVisionCounterhackActivated
            || jamBrakesActivated
            || detonateExplosivesActivated;
    }

    // Dark Future installed - reduce nerve
    @if(ModuleExists("DarkFuture.Needs"))
    private func ReduceNerve() {
        let settings = SettingsSystem.Get();
        if !settings.nerveLossEnabled {
            return;
        }

        let nerveSystem = DFNerveSystem.Get();
        if IsDefined(nerveSystem) {
            nerveSystem.ChangeNeedValue(-settings.nerveLossValue);
        }
    }

    @if(!ModuleExists("DarkFuture.Needs"))
    private func ReduceNerve() {
    }
}

