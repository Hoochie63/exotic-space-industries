if script.active_mods["gvv"] then require("__gvv__.gvv")() end

--====================================================================================================
--REQUIREMENTS
--====================================================================================================

ei_lib = require("lib/lib")
ei_data = require("lib/data")

local ei_tech_scaling = require("scripts/control/tech_scaling")
local ei_global = require("scripts/control/global")
local ei_register = require("scripts/control/register_util")
local ei_powered_beacon = require("scripts/control/powered_beacon")
local ei_beacon_overload = require("scripts/control/beacon_overload")
local ei_spidertron_limiter = require("scripts/control/spidertron_limiter")

ei_victory = require("scripts/control/victory_disabler")
ei_alien_spawner = require("scripts/control/alien_spawner")
ei_informatron = require("scripts/control/informatron")
ei_milestone_preset = require("scripts/control/milestone_preset")
ei_matter_stabilizer = require("scripts/control/matter_stabilizer")
ei_neutron_collector = require("scripts/control/neutron_collector")
ei_fusion_reactor = require("scripts/control/fusion_reactor")
ei_induction_matrix = require("scripts/control/induction_matrix")
ei_black_hole = require("scripts/control/black_hole")
ei_informatron_messager = require("scripts/control/informatron_messager")
ei_gaia = require("scripts/control/gaia")
ei_gate = require("scripts/control/gate")
ei_alien_system = require("scripts/control/alien_system")
ei_debug = require("scripts/control/debug")
ei_compat = require("scripts/control/compat")
ei_loaders_lib = require("lib/ei_loaders_lib")

ei_fueler = require("scripts/control/fueler/fueler")
ei_fueler_informatron = require("scripts/control/fueler/informatron")

em_trains = require("scripts/control/em-trains/charger")
em_trains_gui = require("scripts/control/em-trains/gui")
em_trains_informatron = require("scripts/control/em-trains/informatron")

orbital_combinator = require("scripts/control/orbital_combinator")

--====================================================================================================
--EVENTS
--====================================================================================================

--INIT
------------------------------------------------------------------------------------------------------
script.on_init(function()
    -- setup storage table
    ei_global.init()
    ei_global.check_init()

    -- init other
    ei_tech_scaling.init()
    ei_register.init({"copper_beacon"}, true)
    ei_register.init({"fluid_entity"}, false)

    -- disable vanilla victory condition by rocket launch
    ei_victory.init()
    em_trains.check_global()
    em_trains_gui.mark_dirty()
    ei_compat.check_init()
    orbital_combinator.check_init()
    reforge_gaia_surface()
    --game.planets["gaia"].create_surface() --works
    --game.planets.gaia.create_surface(gaia.map_gen_settings) --no
end)

--ENTITY RELATED
------------------------------------------------------------------------------------------------------

script.on_event({
    defines.events.on_built_entity,
    defines.events.on_robot_built_entity,
    defines.events.script_raised_built,
    defines.events.script_raised_revive,
    --defines.events.on_entity_cloned
    }, function(e)
    on_built_entity(e)
end)

script.on_event({
    defines.events.on_entity_died,
	defines.events.on_pre_player_mined_item,
	defines.events.on_robot_pre_mined,
	defines.events.script_raised_destroy
    }, function(e)
    on_destroyed_entity(e)
end)

script.on_event({
    defines.events.on_player_built_tile,
    defines.events.on_robot_built_tile
    }, function(e)
    on_built_tile(e)
end)

script.on_event({
    defines.events.on_player_mined_tile,
    defines.events.on_robot_mined_tile
    }, function(e)
    on_destroyed_tile(e)
end)

script.on_event(defines.events.on_tick, function() 
    updater()
end)
--[[
script.on_nth_tick(settings.startup["ei-ticks_per_spaced_update"].value, function(e)
    spaced_updater()
end)
]]
script.on_nth_tick(240, function(e)
    ei_compat.nth_tick(e)
end)

script.on_event(defines.events.on_console_command, function(e)
    ei_alien_spawner.give_tool(e)
    ei_gaia.spawn_command(e)
    ei_debug.teleport_to(e)
end)

script.on_event(defines.events.on_player_selected_area, function(e)
    ei_alien_spawner.on_player_selected_area(e)
    ei_alien_system.on_player_selected_area(e)
end)

script.on_event(defines.events.on_selected_entity_changed, function(e)
    ei_matter_stabilizer.on_selected_entity_changed(e)
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(e)
    ei_matter_stabilizer.on_player_cursor_stack_changed(e)
end)

script.on_event(defines.events.on_entity_logistic_slot_changed, function(e)
    ei_spidertron_limiter.on_entity_logistic_slot_changed(e)
end)

--RESEARCH RELATED
------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_research_finished, function(e)

    -- set new tech costs
    ei_tech_scaling.on_research_finished()

    -- notify player for informatron changes
    ei_informatron_messager.on_research_finished(e)

    em_trains.on_research_finished(e)

end)

--WORLD RELATED
------------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_chunk_generated, function(e)
    ei_alien_spawner.on_chunk_generated(e)
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  if player.character then
    player.character.clear_items_inside()
  end
end)

--GUI RELATED
-----------------------------------------------------------------------------------------------------

function rocket_silo_gui_open(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.type ~= "rocket-silo" then return end
  game.get_player(event.player_index).cheat_mode = true
end

function rocket_silo_gui_close(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	if event.entity.type ~= "rocket-silo" then return end
  game.get_player(event.player_index).cheat_mode = false
end

script.on_event(defines.events.on_gui_opened, function(event)
    local name = event.entity and event.entity.name

    if not name then
      return
    elseif name == "ei-fusion-reactor" then
        ei_fusion_reactor.open_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif ei_induction_matrix.core[name] then
        ei_induction_matrix.open_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif name == "ei-black-hole" then
        ei_black_hole.open_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif name == "ei-gate-container" then
        ei_gate.open_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif name == "ei_fueler" then
        ei_fueler.open_gui(game.get_player(event.player_index))
    end

    rocket_silo_gui_open(event)
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local name = event.entity and event.entity.name
    local element_name = event.element and event.element.name

    if name == "ei-fusion-reactor" then
       ei_fusion_reactor.close_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif element_name == "ei-induction-matrix-console" then
        ei_induction_matrix.close_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif name == "ei-black-hole" then
        ei_black_hole.close_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif name == "ei-gate-container" then
        ei_gate.close_gui(game.get_player(event.player_index) --[[@as LuaPlayer]])
    elseif name == "ei_fueler" then
        ei_fueler.close_gui(game.get_player(event.player_index))
    end

    rocket_silo_gui_close(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
    local parent_gui = event.element.tags.parent_gui
    if not parent_gui then return end

    if parent_gui == "ei-fusion-reactor-console" then
        ei_fusion_reactor.on_gui_click(event)
    elseif parent_gui == "ei-induction-matrix-console" then
        ei_induction_matrix.on_gui_click(event)
    elseif parent_gui == "ei-black-hole-console" then
        ei_black_hole.on_gui_click(event)
    elseif parent_gui == "ei-gate-console" then
        ei_gate.on_gui_click(event)
    elseif parent_gui == "ei-alien-gui" then
        ei_alien_system.on_gui_click(event)
    elseif parent_gui == "ei_fueler-console" then
        ei_fueler.on_gui_click(event)
    elseif parent_gui == "mod_gui" then
      em_trains_gui.on_gui_click(event)
    elseif parent_gui == "em_trains_mod-gui" then
      em_trains_gui.on_gui_click(event)

    end


end)

script.on_event(defines.events.on_gui_value_changed, function(event)
    local parent_gui = event.element.tags.parent_gui
    if not parent_gui then return end

    if parent_gui == "ei-fusion-reactor-console" then
        ei_fusion_reactor.on_gui_value_changed(event)
    end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    local parent_gui = event.element.tags.parent_gui
    if not parent_gui then return end

    if parent_gui == "ei-gate-console" then
        ei_gate.on_gui_selection_state_changed(event)
    end
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
    if event.effect_id == "ei-gate-remote" then
        ei_gate.used_remote(event)
    end
end)

--OTHER
------------------------------------------------------------------------------------------------------

local patch_resources = {
  "ei-phytogas-patch",
  "ei-cryoflux-patch",
  "ei-ammonia-patch",
  "ei-morphium-patch",
  "ei-coal-gas-patch"
}

function surface_contains_any_resources(surface)
  for _, resource_name in pairs(patch_resources) do
    local found = surface.count_entities_filtered{
      name = resource_name,
      type = "resource"
    }
    if found > 0 then
      return true, resource_name, found
    end
  end
  return false
end

function reforge_gaia_surface()
  local surface = game.surfaces["gaia"]

  if not surface then
    ei_lib.crystal_echo("☄ [Null Echo Detected] — Gaia does not exist in this filament. Initiating planetary weave manifest...")
    game.planets["gaia"].create_surface()
    return
  end

  -- Evacuate all carbon units
  for _, player in pairs(game.connected_players) do
    if player.surface.name == "gaia" then
      ei_lib.crystal_echo("⚠ [Bioform Displacement Protocol] — The Womb of Gaia trembles. You are being rewritten...")
      player.teleport({0, 0}, "nauvis")
    end
  end

  -- Search the ley lines for resonance
  local has_any, res_name, count = surface_contains_any_resources(surface)

  if has_any then
    ei_lib.crystal_echo("✔ [Echo Retained] — " .. res_name .. " detected (" .. count .. " crystalline signatures). Gaia remains sovereign.")
    return
  end

  -- Begin the ritual collapse
  ei_lib.crystal_echo("✖ [Silence in the Veins] — No known soul-stones resonate. Commencing structural entropy...")

  game.delete_surface(surface)
  ei_lib.crystal_echo("⌬ [Astral Scaffold Deconstructed] — Gaia has been unshaped. Preparing for spectral convergence...")

  local new_surface = game.planets["gaia"].create_surface()

  if new_surface then
    ei_lib.crystal_echo("✧ [Bloom Reinitiated] — The harmonic skeleton has reemerged. Awaiting resource resonance...")
  else
    ei_lib.crystal_echo("☠ [Aether Refused] — Gaia's essence resisted the invocation. Consult the Crystal Chorus.")
  end
end


script.on_configuration_changed(function(e)
    ei_tech_scaling.init()
    ei_victory.init()  -- Required for Better Victory Screen
    ei_global.check_init()
    orbital_combinator.check_init()
    --Clear storage.ei_emt.trains[train_id]
    reforge_gaia_surface()
    local que = ei_lib.config("em_updater_que") or "Beam"
    if que == "Beam" then
        storage.ei.em_train_que = 1
    elseif que == "Ring" then
        storage.ei.em_train_que = 2 --faster to compare a number
    else
        storage.ei.em_train_que = 0
    end
    local que_width = ei_lib.config("em_updater_que_width") or 6
    storage.ei.que_width = que_width
    local que_transparency = ei_lib.config("em_updater_que_transparency") or 80
    storage.ei.que_transparency = que_transparency/100
    local que_timetolive = ei_lib.config("em_updater_que_timetolive") or 60
    storage.ei.que_timetolive = que_timetolive
    local trainGlowToggle = ei_lib.config("em_train_glow_toggle") or true
    storage.ei.em_train_glow_toggle = trainGlowToggle
    local trainGlowTimeToLive = ei_lib.config("em_train_glow_timetolive") or 60
    storage.ei.em_train_glow_timeToLive = trainGlowTimeToLive
    local chargerGlowToggle = ei_lib.config("em_charger_glow_toggle") or true
    storage.ei.em_charger_glow = true
    local chargerGlowTimeToLive = ei_lib.config("em_charger_glow_timetolive") or 60
    storage.ei.em_charger_glow_timeToLive = chargerGlowTimeToLive
    local modes = {
        [0] = "✦ NULL-STATE :: INERTIA LOCKED",
        [1] = "✴ AXIS-FIRE :: DIRECTED CONVERGENCE BEAM",
        [2] = "⟁ OMNI-RESONANCE :: PHASE RING ARRAY"
    }
    ei_lib.crystal_echo("『EM CHARGER QUE MODE HAS SHIFTED』 → "..modes[storage.ei.em_train_que].." ("..storage.ei.em_train_que..")","default-bold")

    em_trains.check_global() --no nil tables
    em_trains.check_buffs() --updates global buff vals
    em_trains.printBuffStatus()
    em_trains.reinitialize_chargers() --applies updated buffs
    em_trains.reinitialize_trains()
    em_trains.update_rail_counts()
    em_trains_gui.mark_dirty()

    ei_lib.crystal_echo("⟦✦ TRANSCENSION RECOGNIZED ✦⟧","default-bold")
    ei_lib.crystal_echo("⫷ Sub-layer Recalibration Initiated ⫸")
    ei_lib.crystal_echo("⫷ Core Heuristics Have Shifted ⫸")
    ei_lib.crystal_echo("『CONFIGURATION CHANGED – BY WHOM, WE DARE NOT NAME","default-bold")

end)

local function youHaveArrived(player)
    if not player then
        log("youHaveArrived received null player")
        return
    end
    local surface = player.surface
    local pos = player.position
    local force = player.force or 1
    if not surface or not pos or not force then
        log("youHaveArrived received null surface or pos or force for player ")
        return
    else
        -- Draw multiple electric beams in a ring around the player
        for i = 1, 12 do
            local angle = (math.pi * 2 / 12) * i
            local offset = {
                x = pos.x + math.cos(angle) * 5,
                y = pos.y + math.sin(angle) * 5
            }
            surface.create_entity{
                name = "electric-beam",
                source = offset,
                position = pos,
                target = player,
                duration = 120,
                force = force
            }
        end

        -- Summon a "portal"—use smoke or other suitable entity
        for i = 1, 5 do
            surface.create_entity{
                name = "big-artillery-explosion", -- visually dramatic
                position = {
                    x = pos.x + math.random() * 2 - 1,
                    y = pos.y + math.random() * 2 - 1
                },
                position = pos,
                force = force
            }
        end

        surface.create_trivial_smoke{
            name = "electric-smoke",
            position = pos
        }
        local player_indices = {}
        for _, player in pairs(game.connected_players) do
          table.insert(player_indices, player.index)
        end
        if not ei_lib.getn(player_indices) then return end
        rendering.draw_light{
            sprite = "utility/light_medium",
            target = pos,
            surface = surface,
            color = {r = 0.6, g = 0.1, b = 1.0},
            intensity = 1.5,
            scale = 4.0,
            time_to_live = 180,
            players = player_indices
        }

        rendering.draw_text{
            text = "⟬ THE SYSTEM STIRS ⟭",
            surface = surface,
            target = pos,
            color = {r = 1.0, g = 0.0, b = 0.8},
            alignment = "center",
            scale = 2.5,
            font = "default-large-bold",
            time_to_live = 300,
            players = player_indices
        }
    end
ei_lib.crystal_echo("Fragments of GAIA's lament ripple across space-time...")
ei_lib.crystal_echo("⚠️ YOU HAVE BEEN SEEN ⚠️","default-bold")
end
script.on_event(
  {
    defines.events.on_player_joined_game,
    defines.events.on_cutscene_cancelled,
    defines.events.on_cutscene_finished
  },
  function(event)
    local player = game.get_player(event.player_index)
    if player and player.valid and player.character then
        youHaveArrived(player.character)
        if player.name then
            log(">> Arrival event triggered for player: " .. player.name)
        end
    end
  end
)

--====================================================================================================
--HANDLERS
--====================================================================================================
ei_update_step = 0  -- Tracks which entity type is updated next, skips first tick
ei_update_functions = {
    function() ei_powered_beacon.update() end, --1
    function() ei_powered_beacon.update_fluid_storages() end, --2
    function() ei_neutron_collector.update() end, --3
    function() ei_matter_stabilizer.update() end, --4
    function() orbital_combinator.update() end, --5
    function() ei_fueler.updater() end, --6
    function() ei_gate.update() end, --7
    function() em_trains.train_updater() end,--8
    function() em_trains.charger_updater() end,--9
}
--60/9=x6.66 (rounded up to 7) executions/handler/second, ie 7 rounds of 10 updates per 60ticks (default, customizable update length 9-6000 ticks)
ei_ticksPerFullUpdate = settings.startup["ei_ticks_per_full_update"].value -- How many ticks to spread updates over
local divisor = ei_ticksPerFullUpdate /  ei_lib.getn(ei_update_functions) -- How many times each entity updater is called per cycle
ei_maxEntityUpdates = settings.startup["ei-max_updates_per_tick"].value -- Ceiling on entity updates per tick
ei_update_functions_length = ei_lib.getn(ei_update_functions)
function updater()
    local updates_needed = 1
   -- Hardcoded checks against ei_update_step are quick
   -- Whichever is less: max_updates_per_tick OR total of entities divided by the number of execution cycles
   if ei_update_step < 5 then -- Reduces the average number of `if` checks
--        if ei_update_step == 0 then
--            ei_global.check_init()
--            ei_update_step = 1
--            end
       if ei_update_step == 1 then
           if storage.ei and storage.ei.spaced_updates and storage.ei.spaced_updates > 0 then
               updates_needed = math.max(1,math.min(math.ceil(storage.ei.spaced_updates / divisor), ei_maxEntityUpdates))
               end
           for i = 1, updates_needed do
               --Abort loop if the queue changes to avoid null reference
               if storage.ei and storage.ei.spaced_updates and
               math.max(1,math.min(math.ceil(storage.ei.spaced_updates / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               ei_powered_beacon.update()
           end

       elseif ei_update_step == 2 then
           if storage.ei and storage.ei.spaced_updates and storage.ei.spaced_updates > 0 then
               updates_needed = math.max(1,math.min(math.ceil(storage.ei.spaced_updates / divisor), ei_maxEntityUpdates))
               end
           updates_needed = math.min(math.ceil(storage.ei.spaced_updates / divisor), ei_maxEntityUpdates)
           for i = 1, updates_needed do
               if storage.ei and storage.ei.spaced_updates and
               math.max(1,math.min(math.ceil(storage.ei.spaced_updates / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               ei_powered_beacon.update_fluid_storages()
           end

       elseif ei_update_step == 3 then
           if storage.ei and storage.ei["neutron_sources"] and  ei_lib.getn(storage.ei["neutron_sources"]) then
               updates_needed = math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei["neutron_sources"]) / divisor), ei_maxEntityUpdates))
               end
           for i = 1, updates_needed do
               if storage.ei and storage.ei["neutron_sources"] and
               math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei["neutron_sources"]) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               ei_neutron_collector.update()
           end

       elseif ei_update_step == 4 then
           if storage.ei and storage.ei.matter_machines and #storage.ei.matter_machines then
               updates_needed = math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.matter_machines) / divisor), ei_maxEntityUpdates))
               end
           for i = 1, updates_needed do
               if storage.ei and storage.ei.matter_machines and
               math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.matter_machines) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               ei_matter_stabilizer.update()
           end
       end

   else -- Otherwise, ei_update_step is >= 5

       if ei_update_step == 5 then
           if storage.ei and storage.ei.orbital_combinators and  ei_lib.getn(storage.ei.orbital_combinators) then
                updates_needed = math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.orbital_combinators) / divisor), ei_maxEntityUpdates))
                end
           for i = 1, updates_needed do
               if storage.ei and storage.ei.orbital_combinators and
               math.max(1,math.min(math.ceil(ei_lib.getn(storage.ei.orbital_combinators) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               orbital_combinator.update()
           end

       elseif ei_update_step == 6 then
           if storage.ei and storage.ei.fueler_queue and #storage.ei.fueler_queue then
               updates_needed = math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.fueler_queue) / divisor), ei_maxEntityUpdates))
               end
           for i = 1, updates_needed do
               if storage.ei and storage.ei.fueler_queue and
               math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.fueler_queue) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               ei_fueler.updater()
           end

       elseif ei_update_step == 7 then
           if storage.ei and storage.ei.gate and storage.ei.gate.gate and  ei_lib.getn(storage.ei.gate.gate) then
                updates_needed = math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.gate.gate) / divisor), ei_maxEntityUpdates))
                end
           for i = 1, updates_needed do
               if storage.ei and storage.ei.gate and storage.ei.gate.gate and
               math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei.gate.gate) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               ei_gate.update()
           end

       elseif ei_update_step == 8 then
           em_trains.check_global()

           if storage.ei_emt and storage.ei_emt.trains and ei_lib.getn(storage.ei_emt.trains) then
                updates_needed = math.max(1,math.min(math.ceil(ei_lib.getn(storage.ei_emt.trains) / divisor), ei_maxEntityUpdates))
                end
           for i = 1, updates_needed do
               if storage.ei_emt and storage.ei_emt.trains and
               math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei_emt.trains) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               if not em_trains.train_updater() then -- only try once if nil
                   goto skip
                   end
           end
       elseif ei_update_step == 9 then
           em_trains.check_global()
           if storage.ei_emt and storage.ei_emt.chargers and  ei_lib.getn(storage.ei_emt.chargers) then
                updates_needed = math.max(1,math.min(math.ceil( ei_lib.getn(storage.ei_emt.chargers) / divisor), ei_maxEntityUpdates))
                end
           for i = 1, updates_needed do
               if storage.ei_emt and storage.ei_emt.chargers and
               math.max(1,math.min(math.ceil(ei_lib.getn(storage.ei_emt.chargers) / divisor), ei_maxEntityUpdates)) ~= updates_needed then
                   goto skip
                   end
               if not em_trains.charger_updater() then -- only try once if nil
                   goto skip
                   end
           end
       end
   end
    ::skip::
    em_trains_gui.updater()
   -- Increment ei_update_step and loop back to 1 if needed
   ei_update_step = ei_update_step + 1
   if ei_update_step > #ei_update_functions then
       ei_update_step = 1
   end

   -- Essential updates that run every tick (e.g., timers, global effects)
   ei_alien_spawner.update()
   ei_gaia.update()
   ei_induction_matrix.update()
   ei_black_hole.update()
   end
--Check global once per entity updater cycle
local globalCheckTicks = ei_ticksPerFullUpdate
script.on_nth_tick(globalCheckTicks, function(event)
    ei_global.check_init()
end)
--[[
function spaced_updater()
    ei_global.check_init()
    ei_gate.update()
end

-- Run fueler updates every 10 ticks
script.on_nth_tick(10, function()
  ei_fueler.updater()
end)

-- Run trains updates every 60 ticks
script.on_nth_tick(60, function()
  em_trains_charger.updater()
  em_trains_gui.updater()
  ei_gaia.update()
  ei_alien_spawner.update()
end)
]]
function on_built_entity(e)
    if not e["entity"] then
      return
    end

    if not e["entity"].valid then
      return
    end

    if ei_powered_beacon.counts_for_fluid_handling(e["entity"]) then
        ei_register.register_fluid_entity(e["entity"])
    end

    if e["entity"].name == "ei-copper-beacon" then
        local master_unit = ei_register.register_master_entity("copper_beacon", e["entity"])
        local slave_entity = ei_register.make_slave("copper_beacon", master_unit, "ei-copper-beacon_slave", {x = 0,y = 0})
        ei_register.link_slave("copper_beacon", master_unit, slave_entity, "slave_assembler")
        ei_register.init_beacon("copper_beacon", master_unit)
        ei_register.add_spaced_update()
        ei_beacon_overload.on_built_entity(e["entity"])
    end

    if e["entity"].name == "ei-iron-beacon" then
        local master_unit = ei_register.register_master_entity("copper_beacon", e["entity"])
        local slave_entity = ei_register.make_slave("copper_beacon", master_unit, "ei-iron-beacon_slave", {x = 0,y = 0})
        ei_register.link_slave("copper_beacon", master_unit, slave_entity, "slave_assembler")
        ei_register.init_beacon("copper_beacon", master_unit)
        ei_register.add_spaced_update()
        ei_beacon_overload.on_built_entity(e["entity"])
    end

--    ei_beacon_overload.on_built_entity(e["entity"])
    ei_neutron_collector.on_built_entity(e["entity"])
    ei_fusion_reactor.on_built_entity(e["entity"])
    ei_matter_stabilizer.on_built_entity(e["entity"])
    ei_induction_matrix.on_built_entity(e["entity"])
    ei_black_hole.on_built_entity(e["entity"])
    ei_gate.on_built_entity(e["entity"])
    ei_alien_system.on_built_entity(e["entity"])
    ei_gaia.on_built_entity(e["entity"])
    ei_loaders_lib.on_built_entity(e["entity"])
    ei_fueler.on_built_entity(e["entity"])
    em_trains.on_built_entity(e["entity"])
    orbital_combinator.add(e["entity"])
end


function on_built_tile(e)
    ei_induction_matrix.on_built_tile(e)
end


function on_destroyed_entity(e)
    if not e["entity"] then
        return
    end

    if not e["entity"].valid then
      return
    end

    if e["robot"] or e["player_index"] then
        e["destroy_type"] = "pre"
    else
        e["destroy_type"] = "past"
    end

    local transfer = nil or e["robot"] or e["player_index"]

    if ei_powered_beacon.counts_for_fluid_handling(e["entity"]) then
        ei_register.deregister_fluid_entity(e["entity"])
    end

    if e["entity"].name == "ei-copper-beacon" then
        local master_unit = e["entity"].unit_number
        if not storage.ei.copper_beacon.master[master_unit] then
            goto continue
        end
        local slave_entity = storage.ei.copper_beacon.master[master_unit].slaves.slave_assembler
        ei_register.unregister_slave_entity("copper_beacon", slave_entity ,e["entity"], true)
        ei_register.unregister_master_entity("copper_beacon", master_unit)
        ei_register.subtract_spaced_update()
        ::continue::
    end

    if e["entity"].name == "ei-iron-beacon" then
        local master_unit = e["entity"].unit_number
        if not storage.ei.copper_beacon.master[master_unit] then
            goto continue
        end
        local slave_entity = storage.ei.copper_beacon.master[master_unit].slaves.slave_assembler
        ei_register.unregister_slave_entity("copper_beacon", slave_entity ,e["entity"], true)
        ei_register.unregister_master_entity("copper_beacon", master_unit)
        ei_register.subtract_spaced_update()
        ::continue::
    end

    ei_beacon_overload.on_destroyed_entity(e["entity"], e["destroy_type"])
    ei_neutron_collector.on_destroyed_entity(e["entity"], e["destroy_type"])
    ei_alien_spawner.on_destroyed_entity(e["entity"])
    ei_matter_stabilizer.on_destroyed_entity(e["entity"])
    ei_induction_matrix.on_destroyed_entity(e["entity"])
    ei_black_hole.on_destroyed_entity(e["entity"], transfer)
    ei_gate.on_destroyed_entity(e["entity"], transfer)
    ei_fueler.on_destroyed_entity(e["entity"], transfer)
    em_trains.on_destroyed_entity(e["entity"])
    orbital_combinator.rem(e["entity"])
end


function on_destroyed_tile(e)
    ei_induction_matrix.on_destroyed_tile(e)
end