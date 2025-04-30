ei_rng = {}

-- Toggle for in-game print debug
local debug_rng = false

-- Internal entropy
local rng_counter = 0
local last_tick = -1

-- Util
local function serialize_seed(input)
  if type(input) == "string" then return input end
  if type(input) == "number" then return tostring(input) end
  if type(input) == "table" then return serpent.line(input, {sortkeys = true}) end
  return tostring(input)
end

local function hash(str)
  local h = 5381
  for i = 1, #str do
    h = (bit32.lshift(h, 5) + h) + str:byte(i)
    h = bit32.band(h, 0x7FFFFFFF)
  end
  return h
end

local function log_echo(msg)
  log(msg)
  if debug_rng and game and game.print then
    game.print(msg)
  end
end

-- Create fresh RNG per call
local function create_ephemeral_rng(name)
  if game.tick ~= last_tick then
    rng_counter = 0
    last_tick = game.tick
  end
  rng_counter = rng_counter + 1
  local seed_input = name .. "::" .. game.tick .. "::" .. rng_counter
  local seed = hash(serialize_seed(seed_input))
  local rng = game.create_random_generator(seed)
  return rng
end

function ei_rng.int(name, min, max)
  if min == nil or max == nil then
    error("ei_rng.int: Missing min or max for '" .. tostring(name) .. "'")
  end
  if min > max then
    log_echo("⚠ [ei_rng.int] Swapping min > max for '" .. name .. "'")
    min, max = max, min
  end
  if min == max then return min end

  local rng = create_ephemeral_rng(name)
  local ok, result = pcall(function() return rng(min, max) end)
  if ok then
	game.print(tostring(result))
	return result
	end

  local fallback = math.floor((min + max) / 2)
  log_echo("🛑 [ei_rng.int] Fallback for '" .. name .. "'. Returning " .. fallback)
  return fallback
end

function ei_rng.float(name, min, max)
  local rng = create_ephemeral_rng(name)
  local ok, val = pcall(function() return rng() end)
  if not ok then
    local fallback = min and max and ((min + max) / 2) or 0.5
    log_echo("🛑 [ei_rng.float] Fallback for '" .. name .. "'. Returning " .. fallback)
    return fallback
  end

  if min and max then
    if min > max then
      log_echo("⚠ [ei_rng.float] Swapping min > max for '" .. name .. "'")
      min, max = max, min
    end
    return min + val * (max - min)
  end

  return val
end

-- Optional inspection utility (shows only counter)
function ei_rng.inspect()
  log_echo("🔍 [ei_rng] Current tick: " .. game.tick .. ", counter: " .. rng_counter)
end

return ei_rng
