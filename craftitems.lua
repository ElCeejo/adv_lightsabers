--------------------------
-- Advanced Lightsabers --
--------------------------
------- Ver 1.0.1 --------

colors={"green","blue","red"}

hilts={"single","cross","double"}

minetest.register_craftitem("adv_lightsabers:lightsaber_internals", { -- Lightsaber Internals
    description = "Lightsaber Internals",
    inventory_image = "adv_lightsabers_lightsaber_internals.png"
})

minetest.register_craftitem("adv_lightsabers:kyber_crystal", { -- Uncolored Lightsaber Crystal
    description = "Kyber Crystal",
	inventory_image = "adv_lightsabers_kyber_crystal.png",
	stack_max = 1,
})

for _,color in ipairs(colors) do
    for n,hilt in ipairs(hilts) do
minetest.register_craftitem("adv_lightsabers:kyber_crystal_"..color, { -- Colored Kyber Crystal
    description = "Kyber Crystal",
    inventory_image = "adv_lightsabers_kyber_crystal_"..color..".png"
})

minetest.register_craftitem("adv_lightsabers:lightsaber_hilt_"..hilt, { -- Lightsaber Hilt
    description = "Lightsaber Hilt",
    inventory_image = "adv_lightsabers_hilt_"..hilt.."_inv.png"
})

minetest.register_craft({ -- Lightsaber Crafting Recipe
	output = "adv_lightsabers:lightsaber_"..hilt.."_"..color.."_off",
	recipe = {
		{"adv_lightsabers:lightsaber_hilt_"..hilt,"",""},
		{"adv_lightsabers:lightsaber_internals","adv_lightsabers:kyber_crystal_"..color,""},
		{"","",""}
	}
})
    end
end

minetest.register_craft({ -- Lightsaber Internals Crafting Recipe
	output = "adv_lightsabers:lightsaber_internals",
	recipe = {
		{"default:steelblock","default:steel_ingot","default:steel_ingot"},
		{"default:diamondblock","default:mese_crystal","default:steel_ingot"},
		{"default:steelblock","default:steel_ingot","default:steel_ingot"}
	}
})

minetest.register_craft({ -- Lightsaber Hilt (Single) Crafting Recipe
	output = "adv_lightsabers:lightsaber_hilt_single",
	recipe = {
		{"default:steel_ingot"},
		{"default:diamond"},
		{"default:steel_ingot"}
	}
})

minetest.register_craft({ -- Lightsaber Hilt (Cross) Crafting Recipe
	output = "adv_lightsabers:lightsaber_hilt_cross",
	recipe = {
		{"default:bronze_ingot","default:steel_ingot","default:bronze_ingot"},
		{"","default:diamond",""},
		{"","default:steel_ingot",""}
	}
})

minetest.register_craft({ -- Lightsaber Hilt (Double) Crafting Recipe
	output = "adv_lightsabers:lightsaber_hilt_double",
	recipe = {
		{"default:steelblock"},
		{"default:diamond"},
		{"default:steelblock"}
	}
})