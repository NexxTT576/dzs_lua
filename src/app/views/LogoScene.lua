local LogoScene = class("LogoScene", cc.load("mvc").LogoScene)

function LogoScene:onCreate()
    local colorBg = display.newLayer(cc.c4b(0,0,0,255))
    self:addChild(colorBg)
    local logo = display.newSprite("logo/logo.png")
    self:addChild(logo)
end