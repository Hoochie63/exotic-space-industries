local model = {}

-- DOC

-- Charger gets registered when placed
-- Charger properties: Has x-tiles range, consumes energy proportional to rails in range
-- charger range can be increased by research
-- trains in range get charged with fuel that has certain acc and max speed buffs
-- those buffs can be increased by research
-- clicking on a charger shows a gui that displays the current stats and rails it charges

--====================================================================================================
--MAIN
--====================================================================================================

model.trains = {
    ["ei_em-locomotive"] = true
}

model.techs = {
    ["ei_eff"] = "eff",
    ["ei_acc"] = "acc",
    ["ei_spd"] = "spd"
}

--UTIL
------------------------------------------------------------------------------------------------------

function model.entity_check(entity)

    if entity == nil then
        return false
    end

    if not entity.valid then
        return false
    end

    return true
end


function model.check_global()

    if not storage.ei_emt then
        storage.ei_emt = {}
    end

    -- [charger_id] = {entity, rail_count, surface}
    if not storage.ei_emt.chargers then
        storage.ei_emt.chargers = {}
    end

    -- [train_id] = {entity, surface}
    if not storage.ei_emt.trains then
        storage.ei_emt.trains = {}
    end

    -- trains that are not in update cycle
    if not storage.ei_emt.trains_register then
        storage.ei_emt.trains_register = {}
    end

    -- list of trains in update cycle, first element gets updated next
    if not storage.ei_emt.trains_que then
        storage.ei_emt.trains_que = {}
    end

    if not storage.ei_emt.gui then
        storage.ei_emt.gui = {}
    end

    if not storage.ei_emt.buffs then
        storage.ei_emt.buffs = {
            charger_range = 96, -- max: 512
            charger_efficiency = 0.1, -- max: 1
            
            acc_level = 0,
            speed_level = 0
        }
    end

    -- here the power draw for each rail in charger range is calculated
    -- from ~eff*(acc_level + max_speed_level)

end


--UPDATE
------------------------------------------------------------------------------------------------------

function model.apply_buffs(buff, level)
    level = tonumber(level)
    -- game.print(buff .. " - " .. level)

    -- level = 15 -- debug

    if buff == "eff" then
        storage.ei_emt.buffs.charger_efficiency = 0.1 + 0.17 * level

        for i,v in pairs(storage.ei_emt.chargers) do
            -- model.make_rings(v.entity, storage.ei_emt.buffs.charger_range, 0.5)
            model.update_charger(v.entity)
        end
    end

    if buff == "acc" then
        storage.ei_emt.buffs.acc_level = level
        -- game.print(buff .. " - " .. storage.ei_emt.buffs.acc_level)
        for i,v in pairs(storage.ei_emt.trains) do
            -- model.make_rings(v.entity, 1+level, 0.75)
        end
    end

    if buff == "spd" then
        storage.ei_emt.buffs.speed_level = level
        -- game.print(buff .. " - " .. storage.ei_emt.buffs.speed_level)

        for i,v in pairs(storage.ei_emt.trains) do
            -- model.make_rings(v.entity, 1+level, 0.75)
        end
    end
end


function model.register_que_train(train)
    table.insert(storage.ei_emt.trains_register, train)
end


function model.que_train(train)

    if not model.entity_check(train) then
        return
    end

    model.check_global()
    table.insert(storage.ei_emt.trains_que, train)

end


function model.update_trains()

    -- update logic: cycle through train updates
    -- every train has a 1MW acc power, fuel always has 1GJ fuel == 1000s
    -- enough to update trains after n-ticks

    model.check_global()

    -- first add new registries
    for i,v in ipairs(storage.ei_emt.trains_register) do
        if model.entity_check(v) then model.que_train(v) end
    end
    storage.ei_emt.trains_register = {}

    if #storage.ei_emt.trains_que == 0 then return end

    -- update and reque first element
    local train = storage.ei_emt.trains_que[1]
    
    model.update_train(train)
    model.que_train(train)
    table.remove(storage.ei_emt.trains_que,1) -- very costly

end


function model.update_train(train, visual)

    visual = visual or false
    if not model.entity_check(train) then
        return
    end

    --[[
    rendering.draw_circle{
        color = {r = 0.1, g = 0.83, b = 0.87},
        radius = 1,
        width = 8,
        filled = false,
        target = train,
        surface = train.surface,
        time_to_live = 5
    }
    ]]

    model.set_burner(train, model.find_charger(train))

end


function model.make_rings(entity, radius, animation_time_per_segment)

    local width = 8
    local segments = math.floor(radius*32 / width)

    for i=1, segments do
        local color = {
        r = 0.1 + (0.7-0.1) * (i/segments),
        g = 0.36,
        b = 0.45,
        a = 0.1
        }

        rendering.draw_circle{
            color = color,
            radius = i * width / 32,
            width = width,
            filled = false,
            target = entity,
            surface = entity.surface,
            time_to_live = math.floor(1 + animation_time_per_segment * i),
            draw_on_ground = true
        }
    end
end


function model.set_burner(train, state)

    if state == 0 then train.burner.remaining_burning_fuel = 0 return end

    local acc = storage.ei_emt.buffs.acc_level or 0
    local speed = storage.ei_emt.buffs.speed_level or 0

    train.burner.currently_burning = prototypes.item["ei_emt-fuel_"..tostring(acc).."_"..tostring(speed)]
    -- error(serpent.block(train.burner.currently_burning.name.fuel_value))
    -- game.print("currently_burning: " .. serpent.line(train.burner.currently_burning.fuel_value))
    train.burner.remaining_burning_fuel = train.burner.currently_burning.name.fuel_value*state
    -- turn this into double, as its may be smthing like 0.534343 -> 0.5
    train.burner.remaining_burning_fuel = train.burner.currently_burning.name.fuel_value*state

end


function model.has_enough_energy(charger, train)

    if not model.entity_check(charger) then
        return false
    end

    local energy = charger.energy
    local total_needed = (1 - storage.ei_emt.buffs.charger_efficiency) * (1 + 0.1*storage.ei_emt.buffs.acc_level) * (1 + 0.1*storage.ei_emt.buffs.speed_level) *1000*1000*100 -- in MJ, up to 400 MJ

    --game.print(total_needed)

    local left = 0
    if train.burner.currently_burning and train.burner.currently_burning.name then
        left = train.burner.remaining_burning_fuel/train.burner.currently_burning.name.fuel_value
    end

    total_needed = total_needed*(1 - left)
    --game.print(total_needed)

    -- TODO only charge when is over 50% full

    if energy == 0 then return 0 end

    if energy >= total_needed then
        charger.energy = charger.energy - total_needed
        --game.print("dec")
        return 1
    end

    -- only charge partially
    charger.energy = charger.energy/2
    return (energy/2)/total_needed

end


function model.find_charger(train)

    local t_pos = {["x"] = train.position.x, ["y"] = train.position.y} -- avoid issues with shorthand notation, might be obsolete
    local surface = train.surface
    local max_range_sqr = storage.ei_emt.buffs.charger_range*storage.ei_emt.buffs.charger_range
    local parts = 0

    for i,v in pairs(storage.ei_emt.chargers) do
        if model.entity_check(v.entity) then

            if v.entity.surface == surface then

                local c_pos = {["x"] = v.entity.position.x, ["y"] = v.entity.position.y}
                if ((t_pos.x - c_pos.x)*(t_pos.x - c_pos.x) + (t_pos.y - c_pos.y)*(t_pos.y - c_pos.y)) <= max_range_sqr then
                    
                    parts = parts + model.has_enough_energy(v.entity, train)
                    if parts >= 1 then return 1 end

                end

            end

        end
    end

    return parts

end


function model.update_charger_from_rail(rail, sign)

    if not model.entity_check(rail) then
        return
    end

    local radius = storage.ei_emt.buffs.charger_range
    local chargers = rail.surface.find_entities_filtered({
        position = rail.position,
        radius = radius,
        name = "ei_charger"
    })

    for _, charger in ipairs(chargers) do
        -- only update rail count
        local charger_id = charger.unit_number
        storage.ei_emt.chargers[charger_id].rail_count = storage.ei_emt.chargers[charger_id].rail_count + sign

        -- adjust its power usage
        charger.power_usage = (storage.ei_emt.chargers[charger_id].rail_count *250*1000 + 10*1000*1000) * (1-storage.ei_emt.buffs.charger_efficiency) / 60  -- 250W per rail + 10MW idle
    end

end


function model.update_charger(charger)

    visual = visual or false -- should highlight counted rails?

    -- charger stil exists/vaild?
    if not model.entity_check(charger) then
        model.unregister_charger(charger) return
    end

    local radius = storage.ei_emt.buffs.charger_range
    local rail_count = charger.surface.count_entities_filtered({
        position = charger.position,
        radius = radius,
        type = {"straight-rail", "curved-rail"}
    })

    local charger_id = charger.unit_number
    storage.ei_emt.chargers[charger_id].rail_count = rail_count

    charger.power_usage = (rail_count *250*1000 + 10*1000*1000) * (1-storage.ei_emt.buffs.charger_efficiency) / 60  -- 250W per rail + 10MW idle

end


function model.animate_range(charger, fade, player)

    fade = fade or false
    player = {player} or nil

    if not model.entity_check(charger) then
        return
    end

    local radius = storage.ei_emt.buffs.charger_range

    if not fade then
        --[[
        return rendering.draw_circle{
            color = {r = 0.1, g = 0.83, b = 0.87},
            radius = radius,
            width = 8,
            filled = false,
            target = charger,
            surface = charger.surface,
            draw_on_ground = true,
        }
        ]]

        return rendering.draw_sprite{
            sprite = "ei_emt-radius_big",
            x_scale = radius / 16,
            y_scale = radius / 16,
            target = charger,
            surface = charger.surface,
            draw_on_ground = true,
            players = player
        }
    end

    --[[
    rendering.draw_circle{
        color = {r = 0.1, g = 0.83, b = 0.87},
        radius = radius+1,
        width = 8,
        filled = false,
        target = charger,
        surface = charger.surface,
        time_to_live = 60
    }
    ]]

    -- 1 tile == 32 pixels
    -- make circles with 8 pixel width, and color fade
    -- {r = 0.1, g = 0.83, b = 0.87} -> r = 0.7

    model.make_rings(charger, radius, 0.5)

end

--REGISTER
------------------------------------------------------------------------------------------------------

function model.register_charger(entity)

    model.check_global()

    local charger_id = entity.unit_number
    storage.ei_emt.chargers[charger_id] = {
        entity = entity,
        rail_count = 0,
        surface = entity.surface
    }

    -- set energy to max so that it does not need the full charge
    entity.energy = entity.prototype.electric_energy_source_prototype.buffer_capacity

    model.update_charger(entity, true)

end


function model.unregister_charger(entity)

    model.check_global()

    local charger_id = entity.unit_number
    storage.ei_emt.chargers[charger_id] = nil

end


function model.register_train(entity)

    model.check_global()

    local train_id = entity.unit_number
    storage.ei_emt.trains[train_id] = {
        entity = entity,
        surface = entity.surface
    }

    model.register_que_train(entity)

end


function model.unregister_train(entity)

    model.check_global()

    local train_id = entity.unit_number
    storage.ei_emt.trains[train_id] = nil

end


--GUI RELATED
------------------------------------------------------------------------------------------------------

function model.fix_toggle_range()

    for _, player in pairs(game.players) do
        
        local player_index = player.index
        if storage.ei_emt.gui[player_index] then
            model.toggle_range_highlight(player) -- remove all
            model.toggle_range_highlight(player) -- draw new
        end

    end

end


function model.toggle_range_highlight(player)

    model.check_global()

    local player_index = player.index

    if storage.ei_emt.gui[player_index] then
        
        -- remove all renderings
        for key,_ in pairs(storage.ei_emt.gui[player_index]) do
            rendering.destroy(key)
        end

        storage.ei_emt.gui[player_index] = nil
        return
    end

    storage.ei_emt.gui[player_index] = {}

    for id,charger in pairs(storage.ei_emt.chargers) do
        local render_id = model.animate_range(charger.entity, false, player)
        if render_id then storage.ei_emt.gui[player_index][render_id] = true end
    end

end

--HANDLERS 
------------------------------------------------------------------------------------------------------

function model.updater()
    model.update_trains()
    
    -- game.print("em trains update")
    for tier=1,20 do 
      if game.players[1].force.technologies["ei_acc_"..tier].researched then 
        storage.ei_emt.buffs.acc_level = tier
      end 

      if game.players[1].force.technologies["ei_spd_"..tier].researched then 
        storage.ei_emt.buffs.speed_level = tier
      end    
    end

end


function model.on_research_finished(event)

    local name = event.research.name

    -- name starts with "ei_" and ends with a number
    if not string.match(name, "^ei_") then return end
    if not string.match(name, "%d$") then return end

    -- first always ei_xxx_ so 7 digits, where 7th is _, cut those
    local lenght = string.len(name)
    if lenght < 8 then return end

    -- only last digit is relevant
    local short_name = string.sub(name, 1, 6)

    tier = tonumber(string.sub(name, -2))
    
    if not tier then 
      tier = tonumber(string.sub(name, -1))
    end 

    if not tier then error("Can not get tier for tech "..name) end 

    if model.techs[short_name] then
      -- game.print(short_name .. " - " .. tier)
      model.apply_buffs(model.techs[short_name], tonumber(tier))
    end

end


function model.on_built_entity(entity)

    if not model.entity_check(entity) then
        return
    end

    if entity.name == "ei_charger" then
        model.register_charger(entity)
        model.animate_range(entity, true, nil)
        model.fix_toggle_range()
        em_trains_gui.mark_dirty()
    end

    if entity.name == "straight-rail" or entity.name == "curved-rail" then
        model.update_charger_from_rail(entity, 1)
        em_trains_gui.mark_dirty()
    end

    if model.trains[entity.name] then
        model.register_train(entity)
        em_trains_gui.mark_dirty()
    end

end


function model.on_destroyed_entity(entity)

    if not model.entity_check(entity) then
        return
    end

    if entity.name == "ei_charger" then
        model.unregister_charger(entity)
        em_trains_gui.mark_dirty()
    end

    if entity.name == "straight-rail" or entity.name == "curved-rail" then
        model.update_charger_from_rail(entity, -1)
        em_trains_gui.mark_dirty()
    end

    if model.trains[entity.name] then
        model.unregister_train(entity)
        em_trains_gui.mark_dirty()
    end

end


return model