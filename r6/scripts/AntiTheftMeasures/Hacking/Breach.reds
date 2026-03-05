module AntiTheftMeasures.Hacking.Breach

// -----------------------------------------------------------------------------
// Breach - Anti-Theft Measures
// -----------------------------------------------------------------------------
import HackingExtensions.*
import HackingExtensions.Programs.*
import AntiTheftMeasures.Targeting.{CanBreach}
import AntiTheftMeasures.Notification.{NotificationSystem}
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.CounterMeasure.{CounterMeasureSystem}
import AntiTheftMeasures.Sound.{SoundSystem}
import AntiTheftMeasures.Sound.Alarm.{AlarmStopCallback}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}
import AntiTheftMeasures.Hacking.ResilientSystem.{ResilientSystemCallback}

public class BreachCallback extends DelayCallback {
    let vehicleComponentPS: ref<VehicleComponentPS>;

    public static func Create(vehicleComponentPS: ref<VehicleComponentPS>) -> ref<BreachCallback> {
        let callback = new BreachCallback();
        callback.vehicleComponentPS = vehicleComponentPS;
        return callback;
    }

    public func Call() {
        let gameInstance = GetGameInstance();
        if !VehicleComponent.IsMountedToVehicle(gameInstance, GetPlayer(gameInstance)) {
            // If player exits the vehicle during hotwire, breach won't happen
            return;
        }

        // Set breach attempted flag
        this.vehicleComponentPS.breachAttempted = true;

        let container: ref<ScriptableSystemsContainer> = GameInstance.GetScriptableSystemsContainer(this.vehicleComponentPS.GetGameInstance());
        let hackingSystem = container.Get(n"HackingExtensions.CustomHackingSystem") as CustomHackingSystem;
        let hackedTarget: ref<IScriptable>;

        hackingSystem
            .StartNewHackInstance(
                "Vehicle hacking instance",
                this.vehicleComponentPS.GetVehicleBreachDifficulty(),
                hackedTarget,
                [this.vehicleComponentPS],
                new OnVehicleHackSucceeded(),
                new OnVehicleHackFailed()
            );
    }
}

public class OnVehicleHackSucceeded extends OnCustomHackingSucceeded {
    // Called when the vehicle hack has succeeded
    public func Execute() -> Void {
        // Notify of vehicle security bypass
        let notificationSystem = NotificationSystem.Get();
        notificationSystem
            .SetMessage(
                GetLocalizedTextByKey(n"ATM.Vehicle.SecurityBypassed"),
                SimpleMessageType.DelamainTaxi
            );

        // Play access granted sound
        SoundSystem.Get().PlayAccessGranted();

        // ATM settings
        let settings = SettingsSystem.Get();

        // Resilient system logic
        let vehicleComponentPS = FromVariant<ref<VehicleComponentPS>>(this.hackInstanceSettings.additionalData[0]);
        if settings.resilientSystemEnabled
            && vehicleComponentPS
                .IsCountermeasureApplicable(settings.resilientSystemEconomyCategory)
            && PassProbabilityCheck(settings.resilientSystemProbability) {
            let vehicleComponentPS = FromVariant<ref<VehicleComponentPS>>(this.hackInstanceSettings.additionalData[0]);

            // Resilient system reboot delay (20s - 300s)
            let randomRebootDelay = Cast<Float>(
                RandRange(
                    settings.resilientSystemRebootMinDurationInSeconds,
                    settings.resilientSystemRebootMaxDurationInSeconds
                )
            );

            // Resilient system reboots
            let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
            delaySystem
                .DelayCallback(
                    ResilientSystemCallback.Create(vehicleComponentPS),
                    randomRebootDelay,
                    false
                );
        }
    }
}

public class OnVehicleHackFailed extends OnCustomHackingFailed {
    // Called when the vehicle hack has failed
    public func Execute() -> Void {
        // ATM settings
        let settings = SettingsSystem.Get();
        // Notification system
        let notificationSystem = NotificationSystem.Get();
        // Sound system
        let soundSystem = SoundSystem.Get();

        // Security malfunction check
        if settings.malfunctionEnabled && PassProbabilityCheck(settings.malfunctionProbability) {
            // Security malfunctioned
            soundSystem.PlayShutdown();
            notificationSystem
                .SetMessage(
                    GetLocalizedTextByKey(n"ATM.Vehicle.SecurityMalfunction"),
                    SimpleMessageType.Neutral
                );
            return;
        }

        let vehicleComponentPS = FromVariant<ref<VehicleComponentPS>>(this.hackInstanceSettings.additionalData[0]);

        // Start short alarm sound (replace this with proper Alarm countermeasure)
        soundSystem.PlayShortAlarm();

        // Activate vehicle security measures
        let counterMeasureSystem = CounterMeasureSystem.Get();
        let anyCountermeasureActivated = counterMeasureSystem.ActivateVehicleCountermeasures(vehicleComponentPS);

        // Notify of vehicle security activation
        let notificationMessage = anyCountermeasureActivated ? GetLocalizedTextByKey(n"ATM.Vehicle.SecurityActivated") : GetLocalizedTextByKey(n"ATM.Vehicle.SecurityInactive");
        let notificationMessageType = anyCountermeasureActivated ? SimpleMessageType.Negative : SimpleMessageType.Neutral;

        notificationSystem.SetMessage(notificationMessage, notificationMessageType);
    }
}

