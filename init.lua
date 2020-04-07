--------------------------
-- Advanced Lightsabers --
--------------------------
-------- Ver 1.0 ---------

adv_lightsabers = {}

local modname = "adv_lightsabers"
local modpath = minetest.get_modpath(modname)

assert(loadfile(modpath .. "/force_api.lua"))(modpath, modname)
assert(loadfile(modpath .. "/register_lightsabers.lua"))(modpath, modname)
assert(loadfile(modpath .. "/lightsabers.lua"))(modpath, modname)
assert(loadfile(modpath .. "/craftitems.lua"))(modpath, modname)
assert(loadfile(modpath .. "/ores.lua"))(modpath, modname)


