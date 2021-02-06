require("commons")

data:extend({
	{
		type = "string-setting",
		allowed_values = itemsSettingValues,
		default_value = defaultItemsSettingValue,
		name = spawnItemsSettingName,
		setting_type = "runtime-global",
		order = "a"
	},
	{
		type = "string-setting",
		allowed_values = itemsSettingValues,
		default_value = defaultItemsSettingValue,
		name = respawnItemsSettingName,
		setting_type = "runtime-global",
		order = "b"
	}
})
