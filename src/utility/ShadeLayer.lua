--@SuperType luaIde#cc.Layer
local ShadeLayer =
    class(
    "ShadeLayer",
    function(color)
        return display.newLayer(color or cc.c4b(0, 0, 0, 170))
    end
)

function ShadeLayer:ctor(param)
    self.touchFunc = nil
    self:enableNodeEvents()
    if param ~= nil then
        self.touchFunc = param.touchFunc
    end

    self.notice = ""

    setTouchEnabled(self, true)
    addNodeEventListener(
        self,
        cc.Handler.EVENT_TOUCH_BEGAN,
        function()
            if self.touchFunc ~= nil then
                self.touchFunc()
            end
            return true
        end
    )
    setTouchSwallowEnabled(self, true)
end

function ShadeLayer:setNotice(str)
    self.notice = str
    RegNotice(
        self,
        function()
            self:removeSelf()
        end,
        str
    )
end

function ShadeLayer:onExit()
    if self.notice ~= "" then
        UnRegNotice(self, self.notice)
    end
end

function ShadeLayer:setTouchFunc(func)
    self.touchFunc = func
end

return ShadeLayer
