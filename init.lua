minetest.register_craftitem("regurgitate:regurgitated_food", {
    description = "Regurgitated Food",
    inventory_image = "regurgitate_regurgitated_food.png",
    on_use = function(itemstack, user, pointed_thing)
        minetest.do_item_eat(7, ItemStack(""), itemstack, user, pointed_thing)
    end
})

minetest.register_node("regurgitate:regurgitated_food_block", {
    description = "Regurgitated Food Block",
    tiles = { "regurgitate_regurgitated_food_block.png" },
    groups = { oddly_breakable_by_hand=3 }
})

minetest.register_node("regurgitate:regurgitated_food_block_dried", {
    description = "Regurgitated Food Block (Dried)",
    tiles = { "regurgitate_regurgitated_food_block_dried.png" },
    groups = { crumbly=2 }
})

minetest.register_craft({
    type = "shapeless",
    output = "regurgitate:regurgitated_food_block",
    recipe = {
        "regurgitate:regurgitated_food",
        "regurgitate:regurgitated_food",
        "regurgitate:regurgitated_food",
        "regurgitate:regurgitated_food"
    }
})

minetest.register_craft({
    type = "shapeless",
    output = "regurgitate:regurgitated_food 4",
    recipe = {
        "regurgitate:regurgitated_food_block"
    }
})

minetest.register_abm({
    label = "Regurgitated food drying",
	nodenames = {"regurgitate:regurgitated_food_block"},
	interval = 57,
	chance = 4,
	action = function(pos, node)
        minetest.set_node(pos, {name="regurgitate:regurgitated_food_block_dried"})
	end,
})

minetest.register_abm({
    label = "Dried regurgitated food",
	nodenames = {"regurgitate:regurgitated_food_block_dried"},
	interval = 2,
	chance = 8,
	action = function(pos, node)
        for _, obj in pairs(minetest.get_objects_inside_radius(pos, 5)) do
            obj:punch(obj, 0.1, {damage_groups={fleshy=7}})
            if obj:is_player() then
                local msg = "Oooh that stinks. That is repulsive. So repulsive it can kill you. Get away from it."
                minetest.chat_send_player(obj:get_player_name(), msg)
            end
        end
	end,
})

local last_eaten = {}
minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, user, pointed_thing)
    if itemstack:get_name() == "regurgitate:regurgitated_food" then
        return
    end
    local name = user:get_player_name()
    last_eaten[name] = {
        name = itemstack:get_name(),
        hp_change = hp_change
    }
end)

minetest.register_chatcommand("barf", {
    description = "Regurgitates the last food a player has eaten.",
    func = function(name)
        local le = last_eaten[name]
        if not le then
            return false, "You need to eat something to regurgitate."
        end
        local player = minetest.get_player_by_name(name)
        local inv = player:get_inventory()
        local le_def = minetest.registered_items[le.name]
        local stack = ItemStack("regurgitate:regurgitated_food")
        stack:get_meta():set_string("description", "Regurgitated "..(le_def.description or le.name))
        if inv:room_for_item("main", stack) then
            inv:add_item("main", stack)
        else
            minetest.item_drop(stack, player, player:get_pos())
        end
        last_eaten[name] = nil
    end
})


