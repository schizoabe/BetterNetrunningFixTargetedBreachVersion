module AntiTheftMeasures.Utils

// -----------------------------------------------------------------------------
// Utils - Anti-Theft Measures
// -----------------------------------------------------------------------------
import AntiTheftMeasures.Extensions.{EVehicleHackLevel}
import AntiTheftMeasures.Settings.{ATMEconomyCategory}

// Performs a percent based probability check against input value
public func PassProbabilityCheck(valueToCheckAgainst: Int32) -> Bool {
    return RandRange(1, 100) <= valueToCheckAgainst;
}

// Converts level to economy category
public func ToEconomyCategory(hackLevel: EVehicleHackLevel) -> ATMEconomyCategory {
    switch hackLevel {
        case EVehicleHackLevel.None:
        case EVehicleHackLevel.Easy:
            return ATMEconomyCategory.Economy;
        case EVehicleHackLevel.Medium:
            return ATMEconomyCategory.Standard;
        case EVehicleHackLevel.Hard:
            return ATMEconomyCategory.Premium;
        case EVehicleHackLevel.VeryHard:
            return ATMEconomyCategory.Luxury;
    }
}

