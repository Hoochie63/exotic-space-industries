data:extend({
    {
        name = "ei_emt-logo",
        type = "sprite",
        filename = ei_trains_tech_path.."em-locomotive.png",
        size = 256,
        scale = 0.25,
    },
    {
        name = "ei_emt-range-toggle",
        type = "sprite",
        filename = ei_trains_item_path.."charging.png",
        size = 64,
    },
    {
        name = "ei_emt-radius",
        type = "sprite",
        filename = ei_trains_entity_path.."radius.png",
        size = 256,
    },
    {
        name = "ei_emt-radius_big",
        type = "sprite",
        filename = ei_trains_entity_path.."radius_big.png",
        size = 256*4,
    },
})


local style = data.raw["gui-style"]["default"]

style.ei_subheader_frame = {
    type = "frame_style",
    parent = "subheader_frame",
    horizontally_stretchable = "on"
}

style.ei_inner_content_flow = {
    type = "vertical_flow_style",
    padding = 12
}