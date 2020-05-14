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
require("game.game")
GameAudio = require("utility.GameAudio")
ResMgr = require("utility.ResMgr")

function MyApp:onCreate()
    game.app = self
    math.randomseed(os.time())
end

--[[
    @desc: 
    author:tulilu
    time:2020-05-12 19:34:15
    --@nextState: game.GameConst#GAME_STATE
	--@msg: 
    @return:
]]
function MyApp:changeState(nextState, msg)
    if self.currentState ~= nextState then
        local lastState = self.currentState
        self.currentState = nextState

        local canShow = true

        if nextState == GAME_STATE.STATE_LOGO then
            local scene = require("app.views.LogoScene"):create(self, "LogoScene")
            scene:showWithScene()
        elseif nextState == GAME_STATE.STATE_VERSIONCHECK then
            local scene = require("app.views.VersionCheckScene"):create(self, "VersionCheckScene")
            scene:showWithScene()
        elseif nextState == GAME_STATE.STATE_LOGIN then
            -- 登陆页面
            local scene = require("game.login.LoginScene"):create(self, "LoginScene")
            scene:showWithScene()
        elseif nextState == GAME_STATE.STATE_MAIN_MENU then
            local showNote = nil
            if (msg ~= nil) then
                showNote = msg.showNote
            end
            local scene = require("game.scenes.MainMenuScene"):create(self, "MainMenuScene", showNote)
            scene:showWithScene()
        end
    end
end

return MyApp
