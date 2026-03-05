module AntiTheftMeasures.Hacking

// -----------------------------------------------------------------------------
// VehicleHackRegistration - Anti-Theft Measures
// -----------------------------------------------------------------------------
import HackingExtensions.*
import HackingExtensions.Programs.*
import AntiTheftMeasures.Targeting.{CanBreach}
import AntiTheftMeasures.Settings.{SettingsSystem}
import AntiTheftMeasures.Sound.{SoundSystem}
import AntiTheftMeasures.Utils.{PassProbabilityCheck}
import AntiTheftMeasures.Hacking.Breach.{BreachCallback}
import AntiTheftMeasures.Hacking.HotwireEngineKill.{HotwireEngineKillCallback}

@wrapMethod(VehicleComponent)
protected cb func OnVehicleFinishedMountingEvent(evt: ref<VehicleFinishedMountingEvent>) -> Bool {
    let eventResult: Bool = wrappedMethod(evt);

    // Event check
    if evt == null || !evt.isMounting {
        return eventResult;
    }

    // ATM settings
    let settings = SettingsSystem.Get();

    // Vehicle reference
    let vehicle: wref<VehicleObject> = this.GetVehicle();
    if !IsDefined(vehicle) {
        return eventResult;
    }
    let vehicleComponentPS: ref<VehicleComponentPS> = vehicle.GetVehicleComponent().GetPS();

    // Vehicle security system deployed check
    if !PassProbabilityCheck(settings.securityDeployedProbability) {
        // No security deployed
        vehicleComponentPS.breachAttempted = true;
        return eventResult;
    }

    let gameInstance: GameInstance = vehicle.GetGame();

    // Player check
    let player: wref<GameObject> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerControlledGameObject();
    if !IsDefined(player)
        || !IsDefined(evt.character)
        || !Equals(evt.character.GetEntityID(), player.GetEntityID()) {
        return eventResult;
    }

    // Driver seat only
    if !VehicleComponent.IsDriverSlot(evt.slotID) {
        return eventResult;
    }

    // Check if ATM  is enabled
    if !settings.systemEnabled {
        return eventResult;
    }

    // Commence breaching
    if CanBreach(vehicleComponentPS) {
        // Hotwire begins
        let soundSystem = SoundSystem.Get();
        soundSystem.PlayHotwire();

        // Hotwire duration in seconds
        let hotwireDuration = settings.hotwireDuration;
        // Hotwire ticks
        let hotwireTicks = CeilF(hotwireDuration / 0.25);
        // Kill the engine during hotwire
        vehicle.TurnEngineOn(false);
        // Make the vehicle immobile during hotwire
        vehicle.ForceBrakesFor(hotwireDuration);
        // Hotwire callbacks
        let delaySystem = GameInstance.GetDelaySystem(GetGameInstance());
        delaySystem
            .DelayCallback(HotwireEngineKillCallback.Create(vehicle, hotwireTicks), 0.25, false);

        // Schedule breach to fire right after hotwire
        delaySystem
            .DelayCallback(BreachCallback.Create(vehicleComponentPS), hotwireDuration, false);
    }

    return eventResult;
}

