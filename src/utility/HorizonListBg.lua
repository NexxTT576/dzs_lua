--@SuperType luaIde#cc.Node
local HorizonListBg =
    class(
    "HorizonListBg",
    function()
        return display.newNode()
    end
)

function HorizonListBg:ctor()
    display.loadSpriteFrames("ui/ui_bigmap.plist", "ui/ui_bigmap.png")

    self.bg = display.newSprite("#bigmap_tab_bg.png", 0, 0, {scale9 = true, size = cc.size(display.width, 130)})
    self:addChild(self.bg)

    setTouchEnabled(self.bg, true)
end

function HorizonListBg:getContentSize()
    return self.bg:getContentSize()
end

return HorizonListBg
