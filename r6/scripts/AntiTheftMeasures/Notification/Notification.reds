module AntiTheftMeasures.Notification

// -----------------------------------------------------------------------------
// Notification - Anti-Theft Measures
// -----------------------------------------------------------------------------
public final class NotificationSystem extends ScriptableSystem {
    public static func Get() -> ref<NotificationSystem> {
        return GameInstance
            .GetScriptableSystemsContainer(GetGameInstance())
            .Get(n"AntiTheftMeasures.Notification.NotificationSystem") as NotificationSystem;
    }

    public final func SetMessage(const message: script_ref<String>, msgType: SimpleMessageType, opt duration: Float) -> Void {
        let warningMsg: SimpleScreenMessage;
        warningMsg.isShown = true;

        // Message duration
        if duration > 0.0 {
            warningMsg.duration = duration;
        } else {
            warningMsg.duration = 5.0;
        }

        warningMsg.message = Deref(message);

        // Set message type
        if NotEquals(msgType, SimpleMessageType.Undefined) {
            warningMsg.type = msgType;
        }

        // Send message using blackboard
        GameInstance
            .GetBlackboardSystem(GetGameInstance())
            .Get(GetAllBlackboardDefs().UI_Notifications)
            .SetVariant(
                GetAllBlackboardDefs().UI_Notifications.WarningMessage,
                ToVariant(warningMsg),
                true
            );
    }
}

