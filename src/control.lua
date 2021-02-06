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

local function setItems(settingValue, getRemovedItems, setRemovedItems, getKeptItems, setKeptItems)
	local removedItems = shallowCopy(getRemovedItems())
	local keptItems = getKeptItems()
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
	if settingValue == itemsSetting_nothing then
		keptItems = {}
	elseif settingValue == itemsSetting_noWeapons then
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
	setRemovedItems(removedItems)
	setKeptItems(keptItems)
end

local function setSpawnItems()
	if remote.interfaces.freeplay and remote.interfaces.freeplay.get_created_items and remote.interfaces.freeplay.set_created_items then
		--log("Set spawn items")
		if global.removedSpawnItems == nil then
			global.removedSpawnItems = {}
		end
		local settingValue = settings.global[spawnItemsSettingName].value
		setItems(
			settingValue,
			function() return global.removedSpawnItems end,
			function(newItems) global.removedSpawnItems = newItems end,
			function() return remote.call("freeplay", "get_created_items") end,
			function(newItems) remote.call("freeplay", "set_created_items", newItems) end
		)
	end
end

local function setRespawnItems()
	if remote.interfaces.freeplay and remote.interfaces.freeplay.get_respawn_items and remote.interfaces.freeplay.set_respawn_items then
		--log("Set respawn items")
		if global.removedRespawnItems == nil then
			global.removedRespawnItems = {}
		end
		local settingValue = settings.global[respawnItemsSettingName].value
		setItems(
			settingValue,
			function() return global.removedRespawnItems end,
			function(newItems) global.removedRespawnItems = newItems end,
			function() return remote.call("freeplay", "get_respawn_items") end,
			function(newItems) remote.call("freeplay", "set_respawn_items", newItems) end
		)
	end
end

script.on_event(defines.events.on_game_created_from_scenario, function(event)
	setSpawnItems()
	setRespawnItems()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting:sub(1, #modName + 1) == modName .. "-" then
		local playerName = game.get_player(event.player_index).name
		settingValueKey = event.setting .. "-" .. settings.global[event.setting].value
		game.print({"", {"mod-name." .. modName}, ": ", {modName .. "-settingChangedMessage", playerName, {"mod-setting-name." .. event.setting}, {"string-mod-setting." .. settingValueKey}}})
		if event.setting == spawnItemsSettingName then
			setSpawnItems()
		elseif event.setting == respawnItemsSettingName then
			setRespawnItems()
		else
			error("Unknown setting: \"" .. event.setting .. "\"")
		end
	end
end)

script.on_configuration_changed(function(data)
	setSpawnItems()
	setRespawnItems()
end)
