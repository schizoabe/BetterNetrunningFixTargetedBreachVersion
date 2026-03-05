module RadialBreach.Config

public class RadialBreachSettings {

  @runtimeProperty("ModSettings.mod", "Radial Breach")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Enabled")
  @runtimeProperty("ModSettings.description", "")
  let enabled: Bool = true;
  
  @runtimeProperty("ModSettings.mod", "Radial Breach")
  @runtimeProperty("ModSettings.category", "")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.displayName", "Breach range")
  @runtimeProperty("ModSettings.description", "Size of the area, inside which everything will be breached.")
  @runtimeProperty("ModSettings.step", "1.0")
  @runtimeProperty("ModSettings.min", "10.0")
  @runtimeProperty("ModSettings.max", "50.0")
  @runtimeProperty("ModSettings.dependency", "enabled")
  let breachRange: Float = 25.0;
  
}