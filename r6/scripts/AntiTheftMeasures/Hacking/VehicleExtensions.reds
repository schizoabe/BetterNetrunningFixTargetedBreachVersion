module AntiTheftMeasures.Extensions

// -----------------------------------------------------------------------------
// VehicleExtensions - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Settings.{SettingsSystem, ATMEconomyCategory}
import AntiTheftMeasures.Utils.{ToEconomyCategory}

// Hack level of a given vehicle, extracted from the following TweakDBID strings: ("EASY","MEDIUM","HARD","IMPOSSIBLE")
// with "None" added in case we don't want any hack on vehicles
public enum EVehicleHackLevel {
    None = 0,
    Easy = 1,
    Medium = 2,
    Hard = 3,
    VeryHard = 4,
}

@addMethod(WheeledObject)
public func GetWheelCount() -> Uint32 {
    let wheelSetup: ref<VehicleWheelDrivingSetup_Record> = TweakDBInterface
        .GetVehicleRecord(this.GetRecordID())
        .VehDriveModelData()
        .WheelSetup();

    if wheelSetup.IsExactlyA(n"gamedataVehicleWheelDrivingSetup_2_Record") {
        return 2u;
    }

    if wheelSetup.IsExactlyA(n"gamedataVehicleWheelDrivingSetup_4_Record") {
        return 4u;
    }

    // In case of custom vehicles or other unsupported records
    return 0u;
}

@addField(VehicleComponentPS)
public persistent let breachAttempted: Bool;

@addMethod(VehicleComponentPS)
public func DeflateTires() -> Bool {
    let vehicleObject = this.GetOwnerEntity();
    if IsDefined(vehicleObject) {
        let wheeledObject: ref<WheeledObject> = vehicleObject as WheeledObject;
        let i: Uint32 = 0u;
        while i < wheeledObject.GetWheelCount() {
            let event: ref<VehicleToggleBrokenTireEvent> = new VehicleToggleBrokenTireEvent();
            event.tireIndex = i;
            event.toggle = true;
            this.QueuePSEvent(this, event);
            wheeledObject.ToggleBrokenTire(event.tireIndex, event.toggle);
            i += 1u;
        }
    }
}

@addMethod(VehicleComponentPS)
public func GetHackLevel() -> EVehicleHackLevel {
    // Get the record of the vehicle
    let record: TweakDBID = this
        .GetOwnerEntity()
        .GetRecord()
        .GetID();

    // Get the flat ("variable") that corresponds to the cracklock difficulty
    let crackLockDifficulty: Variant = TweakDBInterface.GetFlat(record + t".crackLockDifficulty");

    let crackLockDifficultyAsString: String = ToString(crackLockDifficulty);

    if Equals(crackLockDifficultyAsString, "MEDIUM") {
        return EVehicleHackLevel.Medium;
    }

    if Equals(crackLockDifficultyAsString, "HARD") {
        return EVehicleHackLevel.Hard;
    }

    if Equals(crackLockDifficultyAsString, "IMPOSSIBLE") {
        return EVehicleHackLevel.VeryHard;
    }

    return EVehicleHackLevel.Easy;
}

// Returns the tweakDBID path of the minigame used to unlock the vehicle
@addMethod(VehicleComponentPS)
public func GetVehicleBreachDifficulty() -> TweakDBID {
    let settings = SettingsSystem.Get();
    if settings.randomHackingDifficultyEnabled {
        // Random hacking difficulty enabled
        let randomValue: Int32 = RandRange(1, 4);
        switch randomValue {
            case 1:
                return t"CustomHackingSystemMinigame.UnlockVehicleEasy";
            case 2:
                return t"CustomHackingSystemMinigame.UnlockVehicleMedium";
            case 3:
                return t"CustomHackingSystemMinigame.UnlockVehicleHard";
            case 4:
                return t"CustomHackingSystemMinigame.UnlockVehicleImpossible";
        }
    }

    let hackLevel: EVehicleHackLevel = this.GetHackLevel();
    switch hackLevel {
        case EVehicleHackLevel.None:
        case EVehicleHackLevel.Easy:
            return t"CustomHackingSystemMinigame.UnlockVehicleEasy";
        case EVehicleHackLevel.Medium:
            return t"CustomHackingSystemMinigame.UnlockVehicleMedium";
        case EVehicleHackLevel.Hard:
            return t"CustomHackingSystemMinigame.UnlockVehicleHard";
        case EVehicleHackLevel.VeryHard:
            return t"CustomHackingSystemMinigame.UnlockVehicleImpossible";
    }
}

@addMethod(VehicleComponentPS)
public func IsCountermeasureApplicable(economyCategoryToCheckAgainst: ATMEconomyCategory) -> Bool {
    let vehicleEconomyCategory = ToEconomyCategory(this.GetHackLevel());

    let vehicleEconomyCategoryInt = EnumInt(vehicleEconomyCategory);
    let economyCategoryToCheckAgainstInt = EnumInt(economyCategoryToCheckAgainst);

    return vehicleEconomyCategoryInt >= economyCategoryToCheckAgainstInt;
}

