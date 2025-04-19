-- Persistent RNG state table
ei_rng = {}

-- Safely serialize input to string
local function serialize_seed(input)
  if type(input) == "string" then return input end
  if type(input) == "number" then return tostring(input) end
  if type(input) == "table" then return serpent.line(input, {sortkeys = true}) end
  return tostring(input)
end

-- Persistent RNG state table
function ei_rng.get(name, seed)
  storage.ei = storage.ei or {}
  storage.ei.rngs = storage.ei.rngs or {}
    -- DJB2 hash using bit32 for Lua 5.1
    local function hash(str)
      local h = 5381
      for i = 1, #str do
        h = (bit32.lshift(h, 5) + h) + str:byte(i) -- h * 33 + c
        h = bit32.band(h, 0x7FFFFFFF) -- Clamp to signed 32-bit int
      end
      return h
    end
  if not storage.ei.rngs[name] then
    local seed_str = seed or name
    local numeric_seed = hash(serialize_seed(seed_str))
    storage.ei.rngs[name] = game.create_random_generator(numeric_seed)
  end

  return storage.ei.rngs[name]
end

-- Generate an integer between min and max (inclusive)
function ei_rng.int(name, min, max)
  if min == nil or max == nil then
    error("ei_rng.int: Missing min or max for '"..tostring(name).."'")
  end
  if min > max then
    log("⚠ ei_rng.int: Swapping min > max for "..name)
    min, max = max, min
  end
  if min == max then return min end

  local rng = ei_rng.get(name)
  return rng(min, max)
end

-- Generate float between 0 and 1, or [min, max] if given
function ei_rng.float(name, min, max)
  local rng = ei_rng.get(name)
  local val = rng()

  if min and max then
    if min > max then
      log("⚠ ei_rng.float: Swapping min > max for "..name)
      min, max = max, min
    end
    return min + val * (max - min)
  end

  return val -- default [0,1)
end


--- Reseed a named RNG (optional use)
---@param name string
---@param new_seed string|number
function ei_rng.reseed(name, new_seed)
    local rng = ei_rng.get(name, new_seed)
    rng:re_seed(new_seed or name)
end
function ei_rng.shuffle(name, tbl)
    local rng = ei_rng.get(name)
    for i = #tbl, 2, -1 do
        local j = rng:random(1, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end
function ei_rng.reseed_all(base_seed)
  base_seed = base_seed or game.tick

  for name, _ in pairs(storage.ei.rngs or {}) do
    local combined_seed = tostring(base_seed) .. "::" .. tostring(name)
    local rng = game.create_random_generator(combined_seed)
    storage.ei.rngs[name] = rng
    log("🔄 [ei_rng] Reseeded RNG '" .. name .. "' with seed '" .. combined_seed .. "'")
  end
end

--/c ei_rng.inspect_all_rngs()
function ei_rng.inspect_all_rngs()
  if not storage.ei.rngs then
    log("🧿 [ei_rng] No RNGs registered.")
    return
  end

  log("🔍 [ei_rng] Registered RNGs:")
  for name, rng in pairs(storage.ei.rngs) do
    if type(rng) == "LuaRandomGenerator" then
      -- There's no way to directly view internal state, so we just log identity
      log(" • " .. tostring(name) .. " — RNG object: " .. serpent.line(rng))
    else
      log(" ⚠️ Warning: entry for '" .. tostring(name) .. "' is not a valid LuaRandomGenerator!")
    end
  end
end

return ei_rng