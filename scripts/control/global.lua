-- Init storage variables for Exotic Industries

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
    storage.ei.em_train_que = 1 --0 is off, 1 is beam, 2 is ring, updated in on_configuration_changed
    game.print("Exotic Industries globals initialized")
end

function ei_global.check_init()
    -- TODO: dont hardcode this
    if not storage.ei then
        storage.ei = {}
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