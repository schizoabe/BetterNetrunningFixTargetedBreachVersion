module AntiTheftMeasures.Targeting

// -----------------------------------------------------------------------------
// Targeting - AntiTheftMeasures
// -----------------------------------------------------------------------------
public func CanBreach(vehiclePS: ref<VehicleComponentPS>) -> Bool {
    let vehicle = vehiclePS.GetOwnerEntity();
    if !IsDefined(vehicle) {
        return false;
    }

    if vehiclePS.breachAttempted {
        // Already breached
        return false;
    }

    if vehiclePS.GetIsPlayerVehicle() {
        // Player vehicle always go
        return false;
    }

    if vehiclePS.GetHasStateBeenModifiedByQuest() || vehicle.IsQuest() {
        // Quest/gig vehicle
        return false;
    }

    if IsVehicleExcluded(vehicle) {
        // Vehicle excluded
        return false;
    }

    if !vehiclePS.GetIsDestroyed() && !vehiclePS.GetIsSubmerged() {
        // Good to breach
        return true;
    }

    // Not breachable
    return false;
}

// Exclusion list (some vehicles from other mods may come with stolen flags)
private func IsVehicleExcluded(vehicle: wref<VehicleObject>) -> Bool {
    let recordId: TweakDBID = vehicle.GetRecordID();
    let excludedVehicles: array<String>;

    // Truck simulator utility vehicles
    ArrayPush(excludedVehicles, "kaukaz_zeya");
    ArrayPush(excludedVehicles, "kaukaz_bratsk");
    ArrayPush(excludedVehicles, "militech_behemoth");
    ArrayPush(excludedVehicles, "basilisk");

    for excludedVehicle in excludedVehicles {
        if StrContains(StrLower(TDBID.ToStringDEBUG(recordId)), excludedVehicle) {
            return true;
        }
    }

    return false;
}

