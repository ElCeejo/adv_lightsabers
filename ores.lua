--------------------------
-- Advanced Lightsabers --
--------------------------
-------- Ver 1.0 ---------

local modpath, modname = ...

minetest.register_node("adv_lightsabers:kyber_ore", {
	description = "Kyber Ore",
	tiles = {"default_stone.png^adv_lightsabers_kyber_ore.png"},
	paramtype = "light",
	groups = {cracky = 1,level = 2},
	drop = "adv_lightsabers:kyber_crystal",
	sounds = default.node_sound_stone_defaults(),
	light_source = 3,
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "adv_lightsabers:kyber_ore",
	wherein        = "default:stone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 1,
	clust_size     = 1,
	y_max          = 64,
	y_min          = -1024,
})
