local model = {}

--====================================================================================================
--SPIDERTRON LIMITER
--====================================================================================================
function model.get_request_logistic_section(player, logistic_point)
    local section_name = model.get_logistic_section_name(player)
    for _, section in ipairs(logistic_point.sections) do
        if section.group == section_name then
            return section
        end
    end
    return nil
end

function model.remove_nonfuel_requests(entity, slot_id)
 local spider = entity.entity
    if spider then
        local section = get_request_logistic_section(spider, logistic_point, true)
        if section then
            for i, request in ipairs(section.filters) do
                if request and request.value then
                    local item = request.value.name
                    if item and item.fuel_category then
                        if not (item.fuel_category == "ei-fusion-fuel" or item.fuel_category == "ei-nuclear-fuel" or item.fuel_category == "chemical") then
                            section.clear_slot(i)
                            game.print("Only fuel items can be requested for this spidertron.")
                            end
                    end
                end
            end
        end
    end
end
--[[]
    if slot == nil then
        return
    end

    if slot.name == nil then
        return
    end

    local item = prototypes.item[slot.name]

    if item.fuel_category then
        if item.fuel_category == "ei-fusion-fuel" or item.fuel_category == "ei-nuclear-fuel" or item.fuel_category == "chemical" then
            return 
        end
    end

    entity.clear_vehicle_logistic_slot(slot_id)

    -- send message
    game.print("Only fuel items can be requested for this spidertron.")

end
]]

function model.on_entity_logistic_slot_changed(event)

    -- spider vehicle as spiderling should only allow request of fuel
    if not event then return end
    if not event.entity then return end
    local entity = event.entity
    if not entity.type then return end
--    local inbound_slots = entity.logistic_sections["inbound"]
--    if not inbound_slots then return end

    if entity.type ~= "spider-vehicle" then
        return
    end

    if entity.name == "sp-spiderling" then
        model.remove_nonfuel_requests(entity)
    end

end


return model