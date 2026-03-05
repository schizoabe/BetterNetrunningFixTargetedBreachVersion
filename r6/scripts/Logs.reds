// Native logging function declarations for Cyberpunk >= 2.01
// Place in r6\scripts\ — do NOT package with your final mod release
// (other mods may provide this same file and it would conflict).
// See: https://wiki.redmodding.org/cyberpunk-2077-modding/for-mod-creators/modding-guides/scripting/logging

native func Log(const text: script_ref<String>) -> Void
native func LogWarning(const text: script_ref<String>) -> Void
native func LogError(const text: script_ref<String>) -> Void

native func LogChannel(channel: CName, const text: script_ref<String>) -> Void
native func LogChannelWarning(channel: CName, const text: script_ref<String>) -> Void
native func LogChannelError(channel: CName, const text: script_ref<String>) -> Void

native func FTLog(const value: script_ref<String>) -> Void
native func FTLogWarning(const value: script_ref<String>) -> Void
native func FTLogError(const value: script_ref<String>) -> Void

native func Trace() -> Void
native func TraceToString() -> String
