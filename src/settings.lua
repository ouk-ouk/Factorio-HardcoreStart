require("commons")

data:extend({
	{
		type = "string-setting",
		allowed_values = spawnItemsSettingValues,
		default_value = defaultSpawnItemsSettingValue,
		name = spawnItemsSettingName,
		setting_type = "runtime-global"
	}
})
