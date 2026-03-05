module AntiTheftMeasures.Utils.Payment

// -----------------------------------------------------------------------------
// Payment - Anti-Theft Measures
// -----------------------------------------------------------------------------
// Deduct percent base amount of money
public func DeductMoneyInPercents(valueInPercents: Int32) -> Int32 {
    // Setup
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    let playerMoney = transactionSystem.GetItemQuantity(player, MarketSystem.Money());

    if playerMoney <= 0 {
        // Nothing to deduct
        return 0;
    }

    // 1 - valueinPercents
    let randomValueInPercents = RandRange(1, valueInPercents);
    // Calculate value to deduct
    let valueToDeduct = playerMoney * randomValueInPercents / 100;

    // Commit transaction
    transactionSystem.RemoveItem(player, MarketSystem.Money(), valueToDeduct);

    return valueToDeduct;
}

