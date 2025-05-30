data:extend({
  {
    type = "recipe",
    name = "hydrogen",
    category = "atmosphere-condensation",
    icon = "__exotic-space-industries-graphics-3__/K2_ASSETS/icons/fluids/hydrogen.png",
    subgroup = "raw-material",
    order = "a[atmosphere-condensation]-a1[hydrogen]",
    enabled = false,
    always_show_made_in = true,
    always_show_products = true,
    hide_from_player_crafting = true,
    energy_required = 20,
    ingredients = {},
    results = {
      { type = "fluid", name = "hydrogen", amount = 30 },
    },
  },
  {
    type = "recipe",
    name = "nitrogen",
    category = "atmosphere-condensation",
    icon = "__exotic-space-industries-graphics-3__/K2_ASSETS/icons/fluids/nitrogen.png",
    subgroup = "raw-material",
    order = "a[atmosphere-condensation]-a3[nitrogen]",
    enabled = false,
    always_show_made_in = true,
    always_show_products = true,
    hide_from_player_crafting = true,
    energy_required = 30,
    ingredients = {},
    results = {
      { type = "fluid", name = "nitrogen", amount = 30 },
    },
  },
  {
    type = "recipe",
    name = "oxygen",
    category = "atmosphere-condensation",
    icon = "__exotic-space-industries-graphics-3__/K2_ASSETS/icons/fluids/oxygen.png",
    subgroup = "raw-material",
    order = "a[atmosphere-condensation]-a2[oxygen]",
    enabled = false,
    always_show_made_in = true,
    always_show_products = true,
    hide_from_player_crafting = true,
    energy_required = 5,
    ingredients = {},
    results = {
      { type = "fluid", name = "oxygen", amount = 30 },
    },
  },
  {
    type = "recipe",
    name = "water-from-atmosphere",
    category = "atmosphere-condensation",
    icon = "__exotic-space-industries-graphics-3__/K2_ASSETS/icons/fluids/water.png",
    subgroup = "raw-material",
    order = "a[atmosphere-condensation]-a0[water]",
    enabled = false,
    always_show_made_in = true,
    always_show_products = true,
    hide_from_player_crafting = true,
    energy_required = 10,
    ingredients = {},
    results = {
      { type = "fluid", name = "water", amount = 10 },
    },
  },
})
