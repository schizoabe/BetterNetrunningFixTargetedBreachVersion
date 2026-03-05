module AntiTheftMeasures.CounterMeasure.JamBrakes

// -----------------------------------------------------------------------------
// JamBrakesCallback - Anti-Theft Measures
// -----------------------------------------------------------------------------
public class JamBrakesCallback extends DelayCallback {
    let vehicle: wref<VehicleObject>;
    let remainingTicks: Int32;

    public static func Create(vehicle: ref<VehicleObject>, ticks: Int32) -> ref<JamBrakesCallback> {
        let callback = new JamBrakesCallback();
        callback.vehicle = vehicle;
        callback.remainingTicks = ticks;
        return callback;
    }

    public func Call() {
        if !IsDefined(this.vehicle) {
            return;
        }

        // This simulates a bumpy ride
        this.vehicle.ForceBrakesUntilStoppedOrFor(0.25);
        this.remainingTicks -= 1;

        if this.remainingTicks > 0 {
            let delaySystem = GameInstance.GetDelaySystem(this.vehicle.GetGame());
            delaySystem
                .DelayCallback(
                    JamBrakesCallback.Create(this.vehicle, this.remainingTicks),
                    1,
                    false
                );
        }
    }
}

