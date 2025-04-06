-- changes to exotic-industries-loaders mod

local ei_lib = require("lib/lib")
local ei_data = require("lib/data")

--====================================================================================================
--CHECK FOR MOD
--====================================================================================================

if not mods["exotic-industries-loaders"] then
    return
end

--====================================================================================================
--CHANGES
--====================================================================================================

-- change where loaders are unlocked
ei_lib.remove_unlock_recipe("logistics", "ei-loader")
table.insert(data.raw.technology["fast-inserter"].effects, {
    type = "unlock-recipe",
    recipe = "ei-loader"
})

ei_lib.remove_unlock_recipe("logistics-2", "ei-fast-loader")
table.insert(data.raw.technology["advanced-circuit"].effects, {
    type = "unlock-recipe",
    recipe = "ei-fast-loader"
})

ei_lib.remove_unlock_recipe("logistics-3", "ei-express-loader")
table.insert(data.raw.technology["bulk-inserter"].effects, {
    type = "unlock-recipe",
    recipe = "ei-express-loader"
})

-- make new loader recipes
ei_lib.recipe_new("ei-loader", {
    {type="item", name="electric-engine-unit", amount=4},
    {type="item", name="fast-inserter", amount=2},
    {type="item", name="ei-iron-mechanical-parts", amount=6},
})

ei_lib.recipe_new("ei-fast-loader", {
    {type="item", name="electric-engine-unit", amount=10},
    {type="item", name="ei-loader", amount=1},
    {type="item", name="advanced-circuit", amount=10},
})

ei_lib.recipe_new("ei-express-loader", {
    {type="item", name="bulk-inserter", amount=2},
    {type="item", name="ei-fast-loader", amount=1},
    {type="item", name="ei-steel-mechanical-parts", amount=10},
})