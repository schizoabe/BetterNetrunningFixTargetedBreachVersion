module AntiTheftMeasures.Hacking.HotwireEngineKill

// -----------------------------------------------------------------------------
// HotwireEngineKillCallback - Anti-Theft Measures
// -----------------------------------------------------------------------------
public class HotwireEngineKillCallback extends DelayCallback {
    let vehicle: wref<VehicleObject>;
    let remainingTicks: Int32;

    public static func Create(vehicle: ref<VehicleObject>, ticks: Int32) -> ref<HotwireEngineKillCallback> {
        let callback = new HotwireEngineKillCallback();
        callback.vehicle = vehicle;
        callback.remainingTicks = ticks;
        return callback;
    }

    public func Call() {
        if !IsDefined(this.vehicle) {
            return;
        }

        // Makeshift hotwire effect
        let isOddTick = this.remainingTicks % 2 == 1;
        this.vehicle.TurnVehicleOn(isOddTick);
        this.remainingTicks -= 1;

        if this.remainingTicks > 0 {
            let delaySystem = GameInstance.GetDelaySystem(this.vehicle.GetGame());
            delaySystem
                .DelayCallback(
                    HotwireEngineKillCallback.Create(this.vehicle, this.remainingTicks),
                    0.25,
                    false
                );
            return;
        }

        // Last tick - turn it on
        this.vehicle.TurnVehicleOn(true);
        this.vehicle.TurnEngineOn(true);
    }
}

