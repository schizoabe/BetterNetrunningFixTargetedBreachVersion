module AntiTheftMeasures.CounterMeasure.LethalCountermeasures

// -----------------------------------------------------------------------------
// DetonationCallback - Anti-Theft Measures
// -----------------------------------------------------------------------------
public class DetonationCallback extends DelayCallback {
    let vehicleComponentPS: ref<VehicleComponentPS>;

    public static func Create(vehicleComponentPS: ref<VehicleComponentPS>) -> ref<DetonationCallback> {
        let callback = new DetonationCallback();
        callback.vehicleComponentPS = vehicleComponentPS;
        return callback;
    }

    public func Call() {
        let vehicleExplodeEvent = new VehicleExplodeEvent();
        this.vehicleComponentPS.GetOwnerEntity().QueueEvent(vehicleExplodeEvent);
    }
}

