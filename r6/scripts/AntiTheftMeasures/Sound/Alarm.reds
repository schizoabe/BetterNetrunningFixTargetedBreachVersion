module AntiTheftMeasures.Sound.Alarm

// -----------------------------------------------------------------------------
// Alarm - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Sound.{SoundSystem}

public class AlarmStopCallback extends DelayCallback {
    let vehicleObject: wref<VehicleObject>;

    public static func Create(vehicleObject: wref<VehicleObject>) -> ref<AlarmStopCallback> {
        let callback = new AlarmStopCallback();
        callback.vehicleObject = vehicleObject;
        return callback;
    }

    public func Call() {
        // TODO
    }
}

