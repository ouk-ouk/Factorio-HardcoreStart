require("commons")

local function shallowCopy(source)
	local target = {}
	for key, value in pairs(source) do
		target[key] = value
	end
	return target
end

--local function stringify(items)
--	local itemStrings = {}
--	for itemName, amount in pairs(items) do
--		table.insert(itemStrings, itemName .. ":" .. amount)
--	end
--	return "{" .. table.concat(itemStrings, ", ") .. "}"
--end

local function setSpawnItems()
	if remote.interfaces.freeplay and remote.interfaces.freeplay.get_created_items and remote.interfaces.freeplay.set_created_items then
		if global.removedSpawnItems == nil then
			global.removedSpawnItems = {}
		end
		settingValue = settings.global[spawnItemsSettingName].value
		local removedItems = shallowCopy(global.removedSpawnItems)
		local keptItems = remote.call("freeplay", "get_created_items")
		--log("Old kept items: " .. stringify(keptItems))
		--log("Old removed items: " .. stringify(removedItems))
		for itemName, amount in pairs(keptItems) do
			if removedItems[itemName] ~= nil then
				removedItems[itemName] = removedItems[itemName] + amount
			else
				removedItems[itemName] = amount
			end
		end
		--log("All items: " .. stringify(removedItems))
		--log("Setting value: " .. settingValue)
		if settingValue == spawnItemsSetting_nothing then
			keptItems = {}
		elseif settingValue == spawnItemsSetting_noWeapons then
			keptItems = {}
			for itemName, amount in pairs(removedItems) do
				local itemType = game.item_prototypes[itemName].type
				local isWeapon = itemType == "gun" or itemType == "ammo"
				if not isWeapon then
					keptItems[itemName] = amount
				end
			end
			for itemName, amount in pairs(keptItems) do
				removedItems[itemName] = nil
			end
		else
			keptItems = removedItems
			removedItems = {}
		end
		--log("New kept items: " .. stringify(keptItems))
		--log("New removed items: " .. stringify(removedItems))
		global.removedSpawnItems = removedItems
		remote.call("freeplay", "set_created_items", keptItems)
	end
end

script.on_event(defines.events.on_game_created_from_scenario, function(event)
	setSpawnItems()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting == spawnItemsSettingName then
		local playerName = game.get_player(event.player_index).name
		settingValueKey = event.setting .. "-" .. settings.global[event.setting].value
		game.print({"", {"mod-name." .. modName}, ": ", {modName .. "-settingChangedMessage", playerName, {"mod-setting-name." .. event.setting}, {"string-mod-setting." .. settingValueKey}}})
		setSpawnItems()
	end
end)

script.on_configuration_changed(function(data)
	setSpawnItems()
end)
