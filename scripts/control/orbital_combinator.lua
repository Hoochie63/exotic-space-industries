local model = {}

local function sb(data) game.players[1].force.print(serpent.block(data)) end
local function sl(data) game.players[1].force.print(serpent.line(data)) end
local function print(line) game.players[1].force.print(line) end


function model.entity_check(entity)
  if entity == nil then return false end
  if not entity.valid then return false end
  return true
end


function model.check_init()
  if not storage.ei.orbital_combinators then
    storage.ei.orbital_combinators = {}
  end
end


function model.add(entity)
  if model.entity_check(entity) then 
    if entity.name ~= "ei-orbital-combinator" then return end
    model.check_init()
    storage.ei.orbital_combinators[entity.unit_number] = entity
  end
end

function model.rem(entity)
  if model.entity_check(entity) then 
    if entity.name ~= "ei-orbital-combinator" then return end
    model.check_init()
    storage.ei.orbital_combinators[entity.unit_number] = nil
  end
end


local function get_logistic_content(entity)
  if not entity then return {} end 
  if not entity.valid then return {} end  

  lst = {}
  for _,logistic_point in pairs(entity.get_logistic_point()) do
    -- sb(logistic_point)
    for _,logistic_section in pairs(logistic_point.sections) do
      -- sb(logistic_section)
      for i = 1,logistic_section.filters_count do
        local slot = logistic_section.get_slot(i)
        if slot['value'] and slot['min'] and slot['min'] > 0 then
          table.insert(lst,{min=slot['min'],max=slot['max'],name=slot['value']['name']})
        end
      end
    end
  end

  return lst
end



local function set_combinator(entity,requests)
  -- sl("set_logistic_sections - 1")
  local control = entity.get_control_behavior()
  if not control then return end
  -- sl("set_logistic_sections - 2")

  local removed = true
  for i = 1,control.sections_count do
    local remove = true
    for name,request in pairs(requests) do 
      local section = control.get_section(i)
      if section.group == name then remove = false end
    end
    if remove then control.remove_section(i) return end
  end

  for name,request in pairs(requests) do 
    local found = false
    for i = 1,control.sections_count do
      local section = control.get_section(i)
      if section.group == name then found = true end
    end

    if not found then 
      control.add_section(name)
      return
    end

  end

  -- sl("set_logistic_sections - 3")
  
  for name,request in pairs(requests) do 
    for i = 1,control.sections_count do
      local section = control.get_section(i)
      if section.group == name then 
        local index = 1

        for i = 1,section.filters_count do
          section.clear_slot(i)
        end
    
        for name,data in pairs(request) do
          -- sl(data)
          section.set_slot(index,{value=data["name"],min=data["min"],max=data["max"]})
          index = index + 1
        end

      end
    end
  end

end



function model.update_orbital_combinators(entity)
  requests = {}

  for index,platform in pairs(entity.force.platforms) do
    requests[platform.name] = get_logistic_content(platform.hub)
  end

  set_combinator(entity,requests)
end



function model.update()
  if not storage.ei.orbital_combinators then
    return
  end

  for _,entity in pairs(storage.ei.orbital_combinators) do
    model.update_orbital_combinators(entity)
  end

end

return model
