local GameLocale = require("external/GameLocale")

local settings = {
    ReinitializeAccessPoints = true,
    HackthePlanet = true,
    EnableDebugLog = false
}

registerForEvent("onInit", function()
    languageText = loadLanguageFile()
    local nativeSettings = GetMod("nativeSettings")
    if not nativeSettings then
		print("NativeSettings not loaded. Continuing with settings from config file.")
		return
	end
    LoadSettings()
    BuildSettingsMenu(nativeSettings)
    OverrideConfigFunctions()
end)

registerForEvent("onShutdown", function()
    SaveSettings()
end)

function loadLanguageFile()
    local localLang = Game.NameToString(Game.GetSettingsSystem():GetVar("/language", "OnScreen"):GetValue())
    local file = io.open("languages/"..localLang..".json", "r")
    local lang = json.decode(file:read("*a"))
    file:close()
    return lang
end

function BuildSettingsMenu(nativeSettings)
    if not nativeSettings.pathExists("/PierreMods") then
        nativeSettings.addTab("/PierreMods", "Pierre Mods")
    end

    if nativeSettings.pathExists("/PierreMods/HackthePlanetForReal") then
        nativeSettings.removeSubcategory("/PierreMods/HackthePlanetForReal")
    end
    nativeSettings.addSubcategory("/PierreMods/HackthePlanetForReal", languageText.HackthePlanetForReal)

    nativeSettings.addSwitch("/PierreMods/HackthePlanetForReal", languageText.Reinitialize, languageText.ReinitializeDesc, settings.ReinitializeAccessPoints, true, function(state)
        settings.ReinitializeAccessPoints = state
    end)
    nativeSettings.addSwitch("/PierreMods/HackthePlanetForReal", languageText.HackthePlanet, languageText.HackthePlanetDesc, settings.HackthePlanet, true, function(state)
        settings.HackthePlanet = state
    end)
    nativeSettings.addSwitch("/PierreMods/HackthePlanetForReal", languageText.EnableDebugLog, languageText.EnableDebugLogDesc, settings.EnableDebugLog, false, function(state)
        settings.EnableDebugLog = state
    end)
end

function SaveSettings() 
	local validJson, contents = pcall(function() return json.encode(settings) end)
	
	if validJson and contents ~= nil then
		local updatedFile = io.open("settings-HackthePlanetForReal.json", "w+");
		updatedFile:write(contents);
		updatedFile:close();
	end
end

function LoadSettings() 
	local file = io.open("settings-HackthePlanetForReal.json", "r")
	if file ~= nil then
		local contents = file:read("*a")
		local validJson, savedState = pcall(function() return json.decode(contents) end)
		
		if validJson then
			file:close();
			for key, _ in pairs(settings) do
				if savedState[key] ~= nil then
					settings[key] = savedState[key]
				end
			end
		end
	end
end

function OverrideConfigFunctions()
    Override("HackthePlanetForRealConfig.HackthePlanetForRealSettings", "ReinitializeAccessPoints;", function() return settings.ReinitializeAccessPoints end)
    Override("HackthePlanetForRealConfig.HackthePlanetForRealSettings", "HackthePlanet;", function() return settings.HackthePlanet end)
    Override("HackthePlanetForRealConfig.HackthePlanetForRealSettings", "EnableDebugLog;", function() return settings.EnableDebugLog end)
end
