--------------------------
-- Advanced Lightsabers --
--------------------------
------- Ver 1.0.1 --------

function adv_lightsabers.play_sound(player,soundfile)
	minetest.sound_play(soundfile,{
        object = minetest.get_player_by_name(player:get_player_name()),
        gain = 1.0,
        max_hear_distance = 32,
        loop = false,
    })
end

function adv_lightsabers.lightsaber_attack(player,pointed_thing,swing,clash)
    adv_lightsabers.play_sound(player,swing)
    if pointed_thing.type == "object" and pointed_thing.ref:is_player() then
        local pointed_weapon = pointed_thing.ref:get_wielded_item():get_name()
        if minetest.registered_items[pointed_weapon].groups.lightsaber == 1
        and pointed_thing.ref:get_player_control().LMB == true then
            adv_lightsabers.play_sound(player,clash)
        else
            pointed_thing.ref:punch(player,1.0,{full_punch_interval = 0.1,damage_groups = {fleshy = 8}},nil)
            local dir = player:get_look_dir()
            dir.y = dir.y * 1.5
            pointed_thing.ref:add_player_velocity(vector.multiply(dir,5))
        end
    elseif pointed_thing.type == "object" and not pointed_thing.ref:is_player() then
        pointed_thing.ref:punch(player,1.0,{full_punch_interval = 0.1,damage_groups = {fleshy = 8}},nil)
    end
end

colors={"green","blue","red"}

hilts={"single","cross","double"}


for _,color in ipairs(colors) do
    for n,type in ipairs(hilts) do

local function remove_self(self,pos) -- Remove lightsaber
    self.removing = true
    self.object:remove()
    if not self.returned then
        minetest.add_item(pos,"adv_lightsabers:lightsaber_"..type.."_"..color.."_off")
    end
end

local function is_owner_at_pos(self,pos) -- Check if Lightsaber owner is at current position
    for _,player in pairs(minetest.get_objects_inside_radius(pos,1.5)) do
        if player:is_player() and player:get_player_name() == self.owner then
            return true, player
        end
    end
end

local function return_to_owner(self,pos) -- Return to Owner
    local owner = minetest.get_player_by_name(self.owner)
    if not owner or self.owner == nil then remove_self(self,pos) return end
    local owner_pos = owner:get_pos()
    owner_pos.y = owner_pos.y + 1
    local dir = vector.direction(pos,owner_pos)
    for _,entity in pairs(minetest.get_objects_inside_radius(pos,2)) do
        if entity:is_player() and entity:get_player_name() ~= self.owner then -- Punch Player
            entity:punch(self.object,2.0,{full_punch_interval = 0.1,damage_groups = {fleshy = 6}},nil)
        end
        local luaentity = entity:get_luaentity() -- Punch Mob
        if luaentity and not self.removing then
            if luaentity.name ~= self.object:get_luaentity().name then
                if entity:get_armor_groups().fleshy then
                    entity:punch(self.object,2.0,{full_punch_interval = 0.1,damage_groups = {fleshy = 6}},nil)
                end
            end
        end
    end
    self.returning_to_owner = true
    self.object:set_velocity(vector.multiply(dir,15))
    local get_owner, player = is_owner_at_pos(self,pos)
    if get_owner then
        self.removing = true
        if player:get_wielded_item():get_name() == "" then
            player:set_wielded_item("adv_lightsabers:lightsaber_"..type.."_"..color.."_on")
            self.returned = true
            self.object:remove()
        elseif player:get_wielded_item():get_name() ~= "" then
            remove_self(self,pos)
        end
    end
end

local function punch_entities(self,pos) -- Punch Players and Entities
    for _,entity in pairs(minetest.get_objects_inside_radius(pos,2)) do
        if entity:is_player() and entity:get_player_name() ~= self.owner then -- Punch Player
            entity:punch(self.object,2.0,{full_punch_interval = 0.1,damage_groups = {fleshy = 6}},nil)
            return_to_owner(self,pos)
            return
        end
        local luaentity = entity:get_luaentity()
        if luaentity and not self.removing then -- Punch Mob
            if luaentity.name ~= self.object:get_luaentity().name then
                if entity:get_armor_groups().fleshy then
                    entity:punch(self.object,2.0,{full_punch_interval = 0.1,damage_groups = {fleshy = 6}},nil)
                    return_to_owner(self,pos)
                    return
                end
            end
        end
    end
end

minetest.register_entity("adv_lightsabers:lightsaber_"..type.."_"..color.."_ent", { -- Register entity
    physical = false,
    visual = "wielditem",
    visual_size = {x=.25,y=.25,z=.25},
    textures = {"adv_lightsabers:lightsaber_"..type.."_"..color.."_on"},
    collisionbox = {-0.125,-0.125,-0.125,0.125,0.125,0.125},
    glow = 10,
    owner = "",
    timer = 0,
    on_activate = function(self)
        self.object:set_armor_groups({immortal=1})
        local pos = self.object:get_pos()
        for _,player in pairs(minetest.get_objects_inside_radius(pos,1.0)) do
            if player:is_player() then
                local name = player:get_player_name()
                self.owner = name
            end
        end
        local rot = self.object:get_rotation()
        self.object:set_rotation({x=rot.x,y=rot.y,z=-40})
        if self.owner == nil then remove_self(self,pos) return end
    end,
    on_step = function(self)
        local pos = self.object:get_pos()
        self.timer = self.timer + 1
        local rot = self.object:get_rotation()
        self.object:set_rotation({x=rot.x,y=self.timer,z=rot.z})
        if self.owner == nil then remove_self(self,pos) return end
        if self.timer >= 35 and self.owner ~= nil then
            return_to_owner(self,pos)
        end
        punch_entities(self,pos)
        local node = minetest.get_node_or_nil(pos)
        if node and minetest.registered_nodes[node.name].walkable then
            return_to_owner(self,pos)
        end
    end,
})
    end
end

function adv_lightsabers:saber_throw(itemstack,player,type,color)
    local pos = player:get_pos()
	pos.y = pos.y + 1
	local dir = player:get_look_dir()
	local saber = minetest.add_entity(pos,"adv_lightsabers:lightsaber_"..type.."_"..color.."_ent")
	itemstack:take_item(1)
    saber:set_velocity(vector.multiply(dir,20))
    return itemstack
end

function adv_lightsabers:register_lightsaber(type,color)

    -- Single Blade Lightsaber

    if type == "single" then

        minetest.register_craftitem("adv_lightsabers:lightsaber_single_"..color.."_off", {
            description = "Lightsaber",
            inventory_image = "adv_lightsabers_hilt_single_inv.png",
            stack_max = 1,
            on_use = function(itemstack,player,pointed_thing)
                local activate = "adv_lightsabers_activate"
                itemstack:replace("adv_lightsabers:lightsaber_single_"..color.."_on")
                adv_lightsabers.play_sound(player,activate)
                return itemstack
            end,
        })

        minetest.register_craftitem("adv_lightsabers:lightsaber_single_"..color.."_on", {
            description = "Lightsaber",
            inventory_image = "adv_lightsabers_hilt_single_inv.png",
            wield_image = "adv_lightsabers_blade_single_"..color..".png^adv_lightsabers_hilt_single.png",
            wield_scale = {x = 2,y = 2,z = 1},
            stack_max = 1,
            on_use = function(itemstack,player,pointed_thing)
                local swing = "adv_lightsabers_swing"
                local clash = "adv_lightsabers_clash"
                adv_lightsabers.lightsaber_attack(player,pointed_thing,swing,clash)
            end,
            on_secondary_use = function(itemstack,player,pointed_thing)
                if player:get_player_control().sneak == true then
                    local playername = player:get_player_name()
                    if force_ability[playername] == "saber_throw" then
                        adv_lightsabers:saber_throw(itemstack,player,type,color)
                        return itemstack
                    end
                else
                    local deactivate = "adv_lightsabers_deactivate"
                    itemstack:replace("adv_lightsabers:lightsaber_single_"..color.."_off")
                    adv_lightsabers.play_sound(player,deactivate)
                    return itemstack
                end
            end,
            on_place = function(itemstack,player,pointed_thing)
                local deactivate = "adv_lightsabers_deactivate"
                itemstack:replace("adv_lightsabers:lightsaber_single_"..color.."_off")
                adv_lightsabers.play_sound(player,deactivate)
                return itemstack
            end,
            groups = {not_in_creative_inventory=1,lightsaber=1},
        })
    end

    -- Crossguarded Lightsaber

    if type == "cross" then

        minetest.register_craftitem("adv_lightsabers:lightsaber_cross_"..color.."_off", {
            description = "Crossguarded Lightsaber",
            inventory_image = "adv_lightsabers_hilt_cross_inv.png",
            stack_max = 1,
            on_use = function(itemstack,player,pointed_thing)
                local activate = "adv_lightsabers_activate_cross"
                itemstack:replace("adv_lightsabers:lightsaber_cross_"..color.."_on")
                adv_lightsabers.play_sound(player,activate)
                return itemstack
            end,
        })

        minetest.register_craftitem("adv_lightsabers:lightsaber_cross_"..color.."_on", {
            description = "Crossguarded Lightsaber",
            inventory_image = "adv_lightsabers_hilt_cross_inv.png",
            wield_image = "adv_lightsabers_blade_cross_"..color..".png^adv_lightsabers_hilt_cross.png",
            wield_scale = {x = 2,y = 2,z = 1},
            stack_max = 1,
            on_use = function(itemstack,player,pointed_thing)
                local swing = "adv_lightsabers_swing_cross"
                local clash = "adv_lightsabers_clash_cross"
                adv_lightsabers.lightsaber_attack(player,pointed_thing,swing,clash)
            end,
            on_secondary_use = function(itemstack,player,pointed_thing)
                if player:get_player_control().sneak == true then
                    local playername = player:get_player_name()
                    if force_ability[playername] == "saber_throw" then
                        adv_lightsabers:saber_throw(itemstack,player,type,color)
                        return itemstack
                    end
                else
                    local deactivate = "adv_lightsabers_deactivate_cross"
                    itemstack:replace("adv_lightsabers:lightsaber_cross_"..color.."_off")
                    adv_lightsabers.play_sound(player,deactivate)
                    return itemstack
                end
            end,
            on_place = function(itemstack,player,pointed_thing)
                local deactivate = "adv_lightsabers_deactivate_cross"
                itemstack:replace("adv_lightsabers:lightsaber_cross_"..color.."_off")
                adv_lightsabers.play_sound(player,deactivate)
                return itemstack
            end,
            groups = {not_in_creative_inventory=1,lightsaber=1},
        })
    end

    --  Double Bladed Lightsaber

    if type == "double" then

        minetest.register_craftitem("adv_lightsabers:lightsaber_double_"..color.."_off", {
            description = "Double Bladed Lightsaber",
            inventory_image = "adv_lightsabers_hilt_double_inv.png",
            stack_max = 1,
            on_use = function(itemstack,player,pointed_thing)
                local activate = "adv_lightsabers_activate"
                itemstack:replace("adv_lightsabers:lightsaber_double_"..color.."_on")
                adv_lightsabers.play_sound(player,activate)
                return itemstack
            end,
        })

        minetest.register_craftitem("adv_lightsabers:lightsaber_double_"..color.."_on", {
            description = "Lightsaber",
            inventory_image = "adv_lightsabers_hilt_double_inv.png",
            wield_image = "adv_lightsabers_hilt_double.png^adv_lightsabers_blade_double_"..color..".png",
            wield_scale = {x = 4,y = 4,z = 1},
            stack_max = 1,
            on_use = function(itemstack,player,pointed_thing)
                local swing = "adv_lightsabers_swing"
                local clash = "adv_lightsabers_clash"
                adv_lightsabers.lightsaber_attack(player,pointed_thing,swing,clash)
            end,
            on_secondary_use = function(itemstack,player,pointed_thing)
                if player:get_player_control().sneak == true then
                    local playername = player:get_player_name()
                    if force_ability[playername] == "saber_throw" then
                        adv_lightsabers:saber_throw(itemstack,player,type,color)
                        ability_cooldown[playername] = 5
                        return itemstack
                    end
                else
                    local deactivate = "adv_lightsabers_deactivate"
                    itemstack:replace("adv_lightsabers:lightsaber_double_"..color.."_off")
                    adv_lightsabers.play_sound(player,deactivate)
                    return itemstack
                end
            end,
            on_place = function(itemstack,player,pointed_thing)
                local deactivate = "adv_lightsabers_deactivate"
                itemstack:replace("adv_lightsabers:lightsaber_double_"..color.."_off")
                adv_lightsabers.play_sound(player,deactivate)
                return itemstack
            end,
            groups = {not_in_creative_inventory=1,lightsaber=1},
        })
    end
end
