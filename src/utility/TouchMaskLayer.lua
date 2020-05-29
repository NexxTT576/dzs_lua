--@SuperType luaIde#cc.LayerColor
local TouchMaskLayer =
    class(
    "TouchMaskLayer",
    function()
        return display.newLayer(cc.c4b(0, 0, 0, 0))
    end
)

function TouchMaskLayer:ctor(param)
    local _btns = param.btns
    local _contents = {}

    local showColorRect = false

    --    self:setContentSize(CCSizeMake(display.width, display.height))

    for k, v in ipairs(param.contents) do
        table.insert(_contents, v)

        if showColorRect then
            local l = display.newLayer(cc.c4b(255, 0, 0, 170))
            l:setContentSize(v.size)
            l:setPosition(v.origin)
            self:addChild(l)
        end
    end

    for _, v in ipairs(_btns) do
        local p = self:convertToNodeSpace(v:convertToWorldSpace(cc.p(0, 0)))
        local s = v:getContentSize()
        table.insert(_contents, cc.rect(p.x, p.y, s.width, s.height))

        if showColorRect then
            local l = display.newLayer(cc.c4b(255, 0, 0, 170))
            l:setContentSize(s)
            l:setPosition(p)
            self:addChild(l)
        end
    end

    -- self:registerScriptHandler(
    --     function(event)
    --         if "began" == event.name then
    --             for k, v in ipairs(_contents) do
    --                 if v:containsPoint(ccp(event.x, event.y)) then
    --                     return false
    --                 end
    --             end
    --             return true
    --         end
    --     end
    -- )
    self.onTouchBegan = function()
        for k, v in ipairs(_contents) do
            if v:containsPoint(ccp(event.x, event.y)) then
                return false
            end
        end
        return true
    end
    self:setTouchEnabled(true)
    --self:setTouchCaptureEnabled(true)

    self:setTag(1234)
end

return TouchMaskLayer
