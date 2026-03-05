module AntiTheftMeasures.Tutorial

// -----------------------------------------------------------------------------
// Tutorial - Anti-Theft Measures
// -----------------------------------------------------------------------------
@if(ModuleExists("DarkFuture.Services"))
import DarkFuture.Services.{DFNotificationService, DFTutorial}

// Uses Dark Future tutorial system
@if(ModuleExists("DarkFuture.Services"))
public class TutorialSystem extends ScriptableSystem {
    private persistent let tutorialDisplayed: Bool = false;

    public func OnAttach() -> Void {
        if !this.tutorialDisplayed {
            this.tutorialDisplayed = true;
            this.DisplayTutorial();
        }
    }

    final func DisplayTutorial() -> Void {
        let tutorial: DFTutorial;
        tutorial.title = GetLocalizedTextByKey(n"ATM.TutorialTitle");
        tutorial.message = GetLocalizedTextByKey(n"ATM.TutorialMessage");
        DFNotificationService.Get().QueueTutorial(tutorial);
    }
}

