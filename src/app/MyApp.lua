--@SuperType AppBase
local MyApp = class("MyApp", cc.load("mvc").AppBase)

GAME_SETTING = {
    HAS_SAVE = "saved",
    ENABLE_MUSIC = "enable_music",
    ENABLE_SFX = "enable_sfx"
}

GAME_SOUND = {
    title_day = "sound/title_day.mp3",
    title_night = "sound/title_night.mp3"
}

DISPLAY_VERSION = "1.5.1"

local path = {
    "res/",
    "res/ui/",
    "res/ccbi/",
    "res/fonts/"
}

local rootpath = CCFileUtils:getInstance():getWritablePath() .. "updateres/"
SearchPath = {}
for k, v in ipairs(path) do
    table.insert(SearchPath, k, rootpath .. v)
    table.insert(SearchPath, #SearchPath + 1, v)
end
for _, v in ipairs(SearchPath) do
    cc.FileUtils:getInstance():addSearchPath(v)
end

require("game.GameConst")

GameAudio = require("utility.GameAudio")
ResMgr = require("utility.ResMgr")

--@SuperType AppBase
function MyApp:onCreate()
    math.randomseed(os.time())
end

function MyApp:run()
    local scene = require("app.views.LogoScene").new()
    display.runScene(scene)
end

return MyApp
