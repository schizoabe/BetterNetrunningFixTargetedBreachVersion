module AntiTheftMeasures.Settings

// -----------------------------------------------------------------------------
// Enums
// -----------------------------------------------------------------------------
public enum ATMEconomyCategory {
    Economy = 0,
    Standard = 1,
    Premium = 2,
    Luxury = 3,
}

// -----------------------------------------------------------------------------
// Settings - Anti-Theft Measures
// -----------------------------------------------------------------------------
@if(ModuleExists("ModSettingsModule"))
public func RegisterSettingsListener(listener: ref<IScriptable>) {
    ModSettings.RegisterListenerToClass(listener);
    ModSettings.RegisterListenerToModifications(listener);
}

@if(ModuleExists("ModSettingsModule"))
public func UnregisterSettingsListener(listener: ref<IScriptable>) {
    ModSettings.UnregisterListenerToClass(listener);
    ModSettings.UnregisterListenerToModifications(listener);
}

public final class SettingsSystem extends ScriptableSystem {
    func OnAttach() {
        RegisterSettingsListener(this);
    }

    func OnDetach() {
        UnregisterSettingsListener(this);
    }

    public static func Get() -> ref<SettingsSystem> {
        return GameInstance
            .GetScriptableSystemsContainer(GetGameInstance())
            .Get(n"AntiTheftMeasures.Settings.SettingsSystem") as SettingsSystem;
    }

    // ------------------------------- Mod constants that are not user configurable --------------------------------------------
    public const let resilientSystemRebootMinDurationInSeconds: Int32 = 20;
    public const let resilientSystemRebootMaxDurationInSeconds: Int32 = 300;

    // ------------------------------- SETTINGS --------------------------------------------
    // System
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.System.Category")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.Enabled.Description")
    public let systemEnabled: Bool = true;

    // Security deployed probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.System.Category")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.SecurityDeployed.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.SecurityDeployed.Probability.Description")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let securityDeployedProbability: Int32 = 100;

    // Hotwire duration
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.System.Category")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.HotwireDuration")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.HotwireDuration.Description")
    @runtimeProperty("ModSettings.step", "0.5")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "5.0")
    public let hotwireDuration: Float = 3.0;

    // Malfunction
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.System.Category")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.Malfunction.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.Malfunction.Enabled.Description")
    public let malfunctionEnabled: Bool = false;

    // Malfunction probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.System.Category")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.Malfunction.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.Malfunction.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "malfunctionEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let malfunctionProbability: Int32 = 10;

    // Random hacking difficulty
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.System.Category")
    @runtimeProperty("ModSettings.category.order", "0")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.RandomHackingDifficulty.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.RandomHackingDifficulty.Enabled.Description")
    public let randomHackingDifficultyEnabled: Bool = false;

    // ------------------------------- Jam brakes --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.JamBrakes.Category")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.JamBrakes.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.JamBrakes.Enabled.Description")
    public let jamBrakesEnabled: Bool = true;

    // Jam brakes economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.JamBrakes.Category")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.JamBrakes.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.JamBrakes.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "jamBrakesEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let jamBrakesEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Economy;

    // Jam brakes probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.JamBrakes.Category")
    @runtimeProperty("ModSettings.category.order", "10")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.JamBrakes.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.JamBrakes.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "jamBrakesEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let jamBrakesProbability: Int32 = 100;

    // ------------------------------- Deflate tires --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.DeflateTires.Category")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.DeflateTires.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.DeflateTires.Enabled.Description")
    public let deflateTiresEnabled: Bool = true;

    // Deflate tires economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.DeflateTires.Category")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.DeflateTires.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.DeflateTires.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "deflateTiresEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let deflateTiresEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Standard;

    // Deflate tires probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.DeflateTires.Category")
    @runtimeProperty("ModSettings.category.order", "20")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.DeflateTires.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.DeflateTires.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "deflateTiresEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let deflateTiresProbability: Int32 = 90;

    // ------------------------------- Lethal countermeasures --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.Lethal.Category")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.Lethal.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.Lethal.Enabled.Description")
    public let lethalEnabled: Bool = false;

    // Lethal economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.Lethal.Category")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.Lethal.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.Lethal.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "lethalEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let lethalEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Standard;

    // Lethal countermeasures probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.Lethal.Category")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.Lethal.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.Lethal.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "lethalEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let lethalProbability: Int32 = 5;

    // Lethal countermeasures instant detonation
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.Lethal.Category")
    @runtimeProperty("ModSettings.category.order", "30")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.Lethal.InstantDetonation")
    @runtimeProperty("ModSettings.description", "ATM.Settings.Lethal.InstantDetonation.Description")
    @runtimeProperty("ModSettings.dependency", "lethalEnabled")
    public let lethalInstantDetonation: Bool = false;

    // ------------------------------- Notify NCPD --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.NotifyNcpd.Category")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.NotifyNcpd.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.NotifyNcpd.Enabled.Description")
    public let notifyNcpdEnabled: Bool = true;

    // Notify NCPD economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.NotifyNcpd.Category")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.NotifyNcpd.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.NotifyNcpd.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "notifyNcpdEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let notifyNcpdEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Premium;

    // Notify NCPD probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.NotifyNcpd.Category")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.NotifyNcpd.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.NotifyNcpd.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "notifyNcpdEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let notifyNcpdProbability: Int32 = 100;

    // Notify NCPD heat value
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.NotifyNcpd.Category")
    @runtimeProperty("ModSettings.category.order", "40")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.NotifyNcpd.HeatValue")
    @runtimeProperty("ModSettings.description", "ATM.Settings.NotifyNcpd.HeatValue.Description")
    @runtimeProperty("ModSettings.dependency", "notifyNcpdEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "5")
    public let notifyNcpdHeatValue: Int32 = 1;

    // ------------------------------- Money counterhack --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.MoneyCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.MoneyCounterhack.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.MoneyCounterhack.Enabled.Description")
    public let moneyCounterhackEnabled: Bool = true;

    // Money counterhack economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.MoneyCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.MoneyCounterhack.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.MoneyCounterhack.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "moneyCounterhackEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let moneyCounterhackEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Premium;

    // Money counterhack probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.MoneyCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.MoneyCounterhack.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.MoneyCounterhack.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "moneyCounterhackEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let moneyCounterhackProbability: Int32 = 50;

    // Money counterhack value in percents
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.MoneyCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "50")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.MoneyCounterhack.Value")
    @runtimeProperty("ModSettings.description", "ATM.Settings.MoneyCounterhack.Value.Description")
    @runtimeProperty("ModSettings.dependency", "moneyCounterhackEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let moneyCounterhackValue: Int32 = 20;

    // ------------------------------- Glitch vision and hearing --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.GlitchVisionCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "60")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.GlitchVisionCounterhack.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.GlitchVisionCounterhack.Enabled.Description")
    public let glitchVisionCounterhackEnabled: Bool = true;

    // Glitch vision economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.GlitchVisionCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "60")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.GlitchVisionCounterhack.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.GlitchVisionCounterhack.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "glitchVisionCounterhackEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let glitchVisionCounterhackEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Luxury;

    // Glitch vision and hearing counterhack probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.GlitchVisionCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "60")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.GlitchVisionCounterhack.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.GlitchVisionCounterhack.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "glitchVisionCounterhackEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let glitchVisionCounterhackProbability: Int32 = 90;

    // Glitch vision and hearing counterhack value in seconds
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.GlitchVisionCounterhack.Category")
    @runtimeProperty("ModSettings.category.order", "60")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.GlitchVisionCounterhack.Value")
    @runtimeProperty("ModSettings.description", "ATM.Settings.GlitchVisionCounterhack.Value.Description")
    @runtimeProperty("ModSettings.dependency", "glitchVisionCounterhackEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "5")
    @runtimeProperty("ModSettings.max", "60")
    public let glitchVisionCounterhackValue: Int32 = 10;

    // ------------------------------- Resilient system --------------------------------------------
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.ResilientSystem.Category")
    @runtimeProperty("ModSettings.category.order", "70")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.ResilientSystem.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.ResilientSystem.Enabled.Description")
    public let resilientSystemEnabled: Bool = true;

    // Resilient system economy category
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.ResilientSystem.Category")
    @runtimeProperty("ModSettings.category.order", "70")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.ResilientSystem.EconomyCategory")
    @runtimeProperty("ModSettings.description", "ATM.Settings.ResilientSystem.EconomyCategory.Description")
    @runtimeProperty("ModSettings.dependency", "resilientSystemEnabled")
    @runtimeProperty("ModSettings.displayValues.Economy", "ATM.Settings.EconomyCategory.Economy")
    @runtimeProperty("ModSettings.displayValues.Standard", "ATM.Settings.EconomyCategory.Standard")
    @runtimeProperty("ModSettings.displayValues.Premium", "ATM.Settings.EconomyCategory.Premium")
    @runtimeProperty("ModSettings.displayValues.Luxury", "ATM.Settings.EconomyCategory.Luxury")
    public let resilientSystemEconomyCategory: ATMEconomyCategory = ATMEconomyCategory.Luxury;

    // Resilient system probability
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.ResilientSystem.Category")
    @runtimeProperty("ModSettings.category.order", "70")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.System.ResilientSystem.Probability")
    @runtimeProperty("ModSettings.description", "ATM.Settings.System.ResilientSystem.Probability.Description")
    @runtimeProperty("ModSettings.dependency", "resilientSystemEnabled")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "1")
    @runtimeProperty("ModSettings.max", "100")
    public let resilientSystemProbability: Int32 = 50;

    // -----------------------------------------------------------------------------
    // Dark Future category (not countermeasure)
    // -----------------------------------------------------------------------------
    // Nerve
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.DarkFuture.Category")
    @runtimeProperty("ModSettings.category.order", "80")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.Nerve.Enabled")
    @runtimeProperty("ModSettings.description", "ATM.Settings.Nerve.Enabled.Description")
    public let nerveLossEnabled: Bool = true;

    // Nerve loss value
    @runtimeProperty("ModSettings.mod", "ATM.Settings.System.Name")
    @runtimeProperty("ModSettings.category", "ATM.Settings.DarkFuture.Category")
    @runtimeProperty("ModSettings.category.order", "80")
    @runtimeProperty("ModSettings.displayName", "ATM.Settings.Nerve.LossValue")
    @runtimeProperty("ModSettings.description", "ATM.Settings.Nerve.LossValue.Description")
    @runtimeProperty("ModSettings.dependency", "nerveLossEnabled")
    @runtimeProperty("ModSettings.step", "1.0")
    @runtimeProperty("ModSettings.min", "0.0")
    @runtimeProperty("ModSettings.max", "100.0")
    public let nerveLossValue: Float = 10;
}

