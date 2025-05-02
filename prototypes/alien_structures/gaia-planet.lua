local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")

local presets = require("lib/spawner_presets")

local gaia = table.deepcopy(data.raw.planet.fulgora)
gaia.name = "Gaia"
gaia.order = "g[gaia]"
gaia.distance = 10
gaia.orientation = 0.75
gaia.icon = ei_graphics_2_path.."graphics/icons/gaia.png"
gaia.icon_size = 64
gaia.starmap_icon = ei_graphics_2_path.."graphics/icons/starmap-planet-gaia.png"
gaia.starmap_icon_size = 2048
gaia.lightning_properties = nil

gaia.map_gen_settings.autoplace_controls["ei-phytogas-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_controls["ei-cryoflux-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_controls["ei-ammonia-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_controls["ei-morphium-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_controls["ei-coal-gas-patch"] = {frequency = 5, size = 1, richness = 1}

gaia.map_gen_settings.autoplace_settings.entity.settings["ei-phytogas-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_settings.entity.settings["ei-cryoflux-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_settings.entity.settings["ei-ammonia-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_settings.entity.settings["ei-morphium-patch"] = {frequency = 5, size = 1, richness = 1}
gaia.map_gen_settings.autoplace_settings.entity.settings["ei-coal-gas-patch"] = {frequency = 5, size = 1, richness = 1}

gaia.map_gen_settings.cliff_settings.cliff_elevation_0 = 0
gaia.map_gen_settings.cliff_settings.cliff_elevation_interval = 0
gaia.map_gen_settings.cliff_settings.richness = 0

gaia_water = table.deepcopy(data.raw.tile["water"]);
gaia_water.name = "ei-gaia-water"
gaia_water.fluid = "ei-morphium";
data:extend({gaia_water})

local landfill = data.raw.item.landfill

if landfill then
  table.insert(landfill.place_as_tile.tile_condition, "water-shallow")
  table.insert(landfill.place_as_tile.tile_condition, "water-mud") 
  table.insert(landfill.place_as_tile.tile_condition, "ei-gaia-water") 
end

gaia.map_gen_settings.autoplace_settings.tile.settings = {
  ["ei-gaia-grass-1"] = {},
  ["ei-gaia-grass-2"] = {},
  ["ei-gaia-grass-1-var"] = {},
  ["ei-gaia-grass-2-var"] = {},
  ["ei-gaia-grass-2-var-2"] = {},
  ["ei-gaia-rock-1"] = {},
  ["ei-gaia-rock-2"] = {},
  ["ei-gaia-rock-3"] = {},
  ["ei-gaia-water"] = {},
}

-- error(serpent.block(gaia.map_gen_settings))

data:extend({gaia})
--Dumps map settings table in log to use with reforge_gaia
--[[
local serpent = require("serpent") --File normally not present in data-stage, locate at https://github.com/pkulchenko/serpent
local gaia = data.raw.planet.gaia
if gaia and gaia.map_gen_settings then
  log(serpent.block(gaia.map_gen_settings, {sortkeys=true, numformat="%0.8f"}))
end
]]
data:extend{{
    type = "space-connection",
    name = "nauvis-gaia",
    subgroup = "planet-connections",
    from = "nauvis",
    to = "Gaia",
    order = "0",
    length = 100000,
    asteroid_spawn_definitions = {},
    icon = ei_graphics_2_path.."graphics/icons/gaia.png",
}}

data:extend{{
    name = "ei-gaia",
    type = "technology",

    icons = {
      {
        icon = ei_graphics_tech_path.."gaia.png",
        icon_size = 256
      },
      {
        icon = "__core__/graphics/icons/technology/constants/constant-planet.png",
        icon_size = 128,
        scale = 0.5,
        shift = {
          50,
          50
        }
      }
    },

    essential = true,
    icon_size = 256,
    prerequisites = {"rocket-silo"},
    effects = {
      {
        space_location = "Gaia",
        type = "unlock-space-location",
        use_icon_overlay_constant = true
      }
    },
    unit = {
        count = 100,
        ingredients = ei_data.science["computer-age-space"],
        time = 20
    },
    age = "advanced-computer-age"
}}