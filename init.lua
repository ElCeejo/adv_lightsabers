--------------------------
-- Advanced Lightsabers --
--------------------------
------- Ver 1.0.1 --------

local modpath = minetest.get_modpath("adv_lightsabers")

adv_lightsabers = {}
force_ability = {}
ability_cooldown = {}

dofile(modpath.."/force_api.lua")
dofile(modpath.."/register_lightsabers.lua")
dofile(modpath.."/lightsabers.lua")
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/ores.lua")


