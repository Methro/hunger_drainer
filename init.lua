-- Cooldown time in seconds
local cooldown_time = 480
local cooldown_messages = {} 

local function format_time(seconds)
    local minutes = math.floor(seconds / 60)
    local remaining_seconds = seconds % 60
    local time_str = ""

    if minutes > 0 then
        time_str = minutes .. " minute"
        if minutes > 1 then
            time_str = time_str .. "s"
        end

        if remaining_seconds > 0 then
            time_str = time_str .. " and " .. remaining_seconds .. " second"
            if remaining_seconds > 1 then
                time_str = time_str .. "s"
            end
        end
    else
        time_str = remaining_seconds .. " second"
        if remaining_seconds > 1 then
            time_str = time_str .. "s"
        end
    end

    return time_str
end

minetest.register_craftitem("hunger:hunger_drainer", {
    description = "Hunger Drainer",
    inventory_image = "hunger_drainer.png",
    stack_max = 64,
    _tt_help = "Hit a player with this item to instantly drain their hunger.",
    on_use = function(itemstack, user, pointed_thing)
        if not user or not user:is_player() then
            return itemstack
        end

        local player_name = user:get_player_name()

        -- Check if the player is on cooldown
        local last_use_time = cooldown_messages[player_name] or 0
        local current_time = os.time()
        local time_passed = current_time - last_use_time

        if time_passed < cooldown_time then
            local remaining_time = cooldown_time - time_passed
            minetest.chat_send_player(player_name, minetest.colorize("#F08630", "Hunger Drainer is on cooldown. You must wait ") ..
                minetest.colorize("#00FF00", format_time(remaining_time)) ..
                minetest.colorize("#F08630", " to use it again."))
            return itemstack
        end

        if pointed_thing.type == "object" and pointed_thing.ref:is_player() then
            local target_player = pointed_thing.ref

            -- Drain the hunger 
            mcl_hunger.set_hunger(target_player, 0, true)

            -- Send a message to the target player
            minetest.chat_send_player(target_player:get_player_name(), minetest.colorize("#4C4D4F", player_name) ..
                minetest.colorize("#417EE8", " has drained all your hunger!"))

            -- Send a message to the player who used the item
            minetest.chat_send_player(player_name, minetest.colorize("#417EE8", "You have drained all the hunger of ") ..
                minetest.colorize("#4C4D4F", target_player:get_player_name()))

            -- Set the last use time for the player who used the item
            cooldown_messages[player_name] = current_time

            itemstack:take_item()
        end

        return itemstack
    end,
})


minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    cooldown_messages[name] = nil
    
end)
