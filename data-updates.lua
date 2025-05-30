--====================================================================================================
--PRE UPDATES
--====================================================================================================

-- info

ei_mod.stage = "data-updates"
ei_lib = require("lib/lib")

--====================================================================================================
--CONTENT UPDATES
--====================================================================================================

-- reorganize vanilla data

-- remove vanilla resources from autoplace-controls
require("scripts/data-updates/vanilla_resources")
-- set science costs to startPrice and set prerequisite to "ei-temp" tech for vanilla techs
require("scripts/data-updates/tech_flattening")
-- set prerequisites of vanilla techs for IE
require("scripts/data-updates/tech_structure")
-- apply vanilla patches
require("scripts/data-updates/vanilla_patches")

-- add metalworks
require("prototypes/metalworks")
-- apply icon patches
require("scripts/data-updates/icon_updates")
-- apply locale patches
require("scripts/data-updates/locale_updates")

-- shoop
--[[
if ei_lib.config("slag") then
    require("scripts/data-updates/slag")
end
if ei_lib.config("ash") then
    require("scripts/data-updates/ash")
end
]]

if ei_lib.config("loader-prototype-complexity") then
  require("scripts/data-updates/loader_patches")
end

-- apply mod patches
require("scripts/data-updates/nanobot_patches")
require("scripts/data-updates/fmf_patches")
require("scripts/data-updates/sp_patches")
require("scripts/data-updates/flow_control_patches")
require("scripts/data-updates/teleporters_patches")
require("scripts/data-updates/solar_patches")
require("scripts/data-updates/text_plates_patches")
require("scripts/data-updates/extra_storage_tanks_patches")

-- =======================================================================================

if settings.startup["ei-rocket-lift-capacity-buff"].value == 0 then
  return
end

local size_multiplier = settings.startup["ei-rocket-lift-capacity-buff"].value
data.raw["utility-constants"]["default"].rocket_lift_weight = data.raw["utility-constants"]["default"].rocket_lift_weight * size_multiplier
data.raw["space-platform-starter-pack"]["space-platform-starter-pack"].weight = data.raw["utility-constants"]["default"].rocket_lift_weight
data.raw["rocket-silo"]["rocket-silo"].weight = data.raw["utility-constants"]["default"].rocket_lift_weight * size_multiplier * 10
data.raw["cargo-landing-pad"]["cargo-landing-pad"].weight = data.raw["utility-constants"]["default"].rocket_lift_weight * size_multiplier * 10

data.raw["rocket-silo"]["rocket-silo"].cargo_station_parameters.prefer_packed_cargo_units = false

data.raw["rocket-silo"]["rocket-silo"].to_be_inserted_to_rocket_inventory_size = 90