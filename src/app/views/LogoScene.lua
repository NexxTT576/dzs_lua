--@SuperType ViewBase
local LogoScene = class("LogoScene", cc.load("mvc").ViewBase)

function LogoScene:onCreate()
    local colorBg = display.newLayer(cc.c4b(0, 0, 0, 255))
    self:addChild(colorBg)
    --@RefType luaIde#cc.Sprite
    local logo = display.newSprite("logo/logo.png")
    logo:setPosition(display.width / 2, display.height / 2)
    self:addChild(logo)
end

function LogoScene:onEnter()
    performWithDelay(
        self,
        function()
            print("onenter2")
            self:getApp():enterScene("VersionCheckScene")
        end,
        2
    )
end

return LogoScene
