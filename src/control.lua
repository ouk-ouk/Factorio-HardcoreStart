script.on_event(defines.events.on_cutscene_cancelled, function(event)
  local player = game.players[event.player_index]
  if player.character then
    player.character.clear_items_inside()
  end
end)
