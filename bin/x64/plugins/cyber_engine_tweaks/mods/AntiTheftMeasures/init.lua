DarkFutureAddonCarjacking = {
    description = "Enhances the Security of civilian vehicles. Template for the Custom Hacking System",
}

function DarkFutureAddonCarjacking:new()

	registerForEvent("onInit", function()

		local CustomHackingSystem = GetMod("CustomHackingSystem")

		if CustomHackingSystem == nil then
			print("[DarkFutureAddonCarjacking] Custom Hacking System Mod not found")
		end

		local hacks = require("Modules/Hack.lua")
		hacks.Generate()
	end)

end

return DarkFutureAddonCarjacking:new()
