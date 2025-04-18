-- Init storage variables for Exotic Industries
ei_lib = require("lib/lib")
local ei_global = {}

--====================================================================================================
--GLOBAL VARIABLES
--====================================================================================================

function ei_global.init()
    storage.ei = {}

    storage.ei["tech_scaling"] = {}
    storage.ei["tech_scaling"].maxCost = 0
    storage.ei["tech_scaling"].startPrice = 0
    storage.ei["tech_scaling"].techCount = 0

    storage.ei["overload_icons"] = {}
    storage.ei["neutron_collector_animation"] = {}
    storage.ei["neutron_sources"] = {}
    storage.ei["spawner_queue"] = {}
    storage.ei["orbital_combinators"] = {}
    storage.ei.spaced_updates = 0
    storage.ei.alien = {}
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

    ei_lib.crystal_echo("»» INITIALIZING SYSTEM CORE: ＥＸＯＴＩＣ ＳＰΛＣΣ ＩＮＤＵＳＴＲＩＥＳ ««","default-bold")
    ei_lib.crystal_echo(">> Integrating chronometric lattices... Binding entropy to mass... Stand by.","default-semibold")
end

function ei_global.check_init()
    -- TODO: dont hardcode this
    if not storage.ei then
        storage.ei = {}
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
    end

    if not storage.ei["tech_scaling"] then
        storage.ei["tech_scaling"] = {}
    end

    if not storage.ei["tech_scaling"].maxCost then
        storage.ei["tech_scaling"].maxCost = 0
    end

    if not storage.ei["tech_scaling"].startPrice then
        storage.ei["tech_scaling"].startPrice = 0
    end

    if not storage.ei["tech_scaling"].techCount then
        storage.ei["tech_scaling"].techCount = 0
    end

    if not storage.ei["overload_icons"] then
        storage.ei["overload_icons"] = {}
    end

    if not storage.ei["neutron_collector_animation"] then
        storage.ei["neutron_collector_animation"] = {}
    end

    if not storage.ei["neutron_sources"] then
        storage.ei["neutron_sources"] = {}
    end

    if not storage.ei["spawner_queue"] then
        storage.ei["spawner_queue"] = {}
    end

    if not storage.ei["orbital_combinators"] then
        storage.ei["orbital_combinators"] = {}
    end

    if not storage.ei.spaced_updates then
        storage.ei.spaced_updates = 0
    end

    if not storage.ei.alien then
        storage.ei.alien = {}
        storage.ei.alien.state = {}
    end
end

return ei_global