--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-15 15:10:37
]]
--@SuperType [ luaIde#cc.LayerColor]
local SimpleColorLayer =
    class(
    "SimpleColorLayer",
    function(color)
        return display.newLayer(color or cc.c4b(0, 0, 0, 170))
    end
)

function SimpleColorLayer:ctor(param)
    self:enableNodeEvents()
    self:setTouchSwallowEnabled(true)
end

function SimpleColorLayer:onEnter()
end

function SimpleColorLayer:onExit()
    ResMgr.blueLayer = nil
end

return SimpleColorLayer
