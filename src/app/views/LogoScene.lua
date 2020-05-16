require("game.game")
--@SuperType luaIde#cc.Scene
local LogoScene =
    class(
    "LogoScene",
    function()
        return display.newScene("LogoScene")
    end
)

function LogoScene:ctor()
    local colorBg = display.newLayer(cc.c4b(0, 0, 0, 255))
    self:addChild(colorBg)
    --@RefType luaIde#cc.Sprite
    local logo = display.newSprite("logo/logo.png")
    logo:setPosition(display.width / 2, display.height / 2)
    self:addChild(logo)
    GameAudio.init()
    self:enableNodeEvents()
end

function LogoScene:onEnter()
    performWithDelay(
        self,
        function()
            GameStateManager:ChangeState(GAME_STATE.STATE_VERSIONCHECK)
        end,
        2
    )
end

return LogoScene
