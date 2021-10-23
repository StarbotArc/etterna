local defaultConfig = {
    global = {
        TipType = 1, -- 1 = tips, 2 = quotes ...
        ShowVisualizer = true,
        ShowBackgrounds = true, -- wheel and gameplay bg
        StaticBackgrounds = false,
        VideoBanners = true,
        WheelPosition = true, -- true = left, false = right
        WheelBanners = true, -- true = on, false = off
        InstantSearch = true, -- true = search per press, false = search on enter button
    },
}

themeConfig = create_setting("themeConfig", "themeConfig.lua", defaultConfig, -1)
themeConfig:load()

function getWheelPosition()
    -- true means left, false means right
    return themeConfig:get_data().global.WheelPosition
end
function useWheelBanners()
    return themeConfig:get_data().global.WheelBanners
end
function useVideoBanners()
    return themeConfig:get_data().global.VideoBanners
end