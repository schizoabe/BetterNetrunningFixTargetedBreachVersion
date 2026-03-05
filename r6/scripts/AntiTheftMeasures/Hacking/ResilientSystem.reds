module AntiTheftMeasures.Hacking.ResilientSystem

// -----------------------------------------------------------------------------
// ResilientSystem - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.CounterMeasure.{CounterMeasureSystem}

public class ResilientSystemCallback extends DelayCallback {
    let vehicleComponentPS: ref<VehicleComponentPS>;

    public static func Create(vehicleComponentPS: ref<VehicleComponentPS>) -> ref<ResilientSystemCallback> {
        let callback = new ResilientSystemCallback();
        callback.vehicleComponentPS = vehicleComponentPS;
        return callback;
    }

    public func Call() {
        if !IsDefined(this.vehicleComponentPS) {
            // Vehicle despawned
            return;
        }

        let vehicle = this.vehicleComponentPS.GetOwnerEntity();
        if vehicle.IsDestroyed() {
            // Vehicle destroyed
            return;
        }

        // Security system reboots and applies countermeasures
        let counterMeasureSystem = CounterMeasureSystem.Get();
        counterMeasureSystem.ActivateVehicleCountermeasures(this.vehicleComponentPS);
    }
}

