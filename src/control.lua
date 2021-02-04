script.on_event(defines.events.on_game_created_from_scenario, function(event)
	if remote.interfaces.freeplay and remote.interfaces.freeplay.set_created_items then
		remote.call("freeplay", "set_created_items", {})
	end
end)
