local TipLabel =
    class(
    "TipLabel",
    function()
        local tipLabelSprite = display.newSprite("ui_common/tip_bg2.png", {scale9 = true})
        tipLabelSprite:setPosition(display.cx, display.cy)
        tipLabelSprite:setColor(cc.c3b(255, 255, 255))
        return tipLabelSprite
    end
)

function TipLabel:ctor(text, delayTime)
    --@RefType luaIde#cc.Label
    local tipLabel = cc.Label:create()
    tipLabel:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    tipLabel:setSystemFontSize(22)
    tipLabel:setString(text)
    tipLabel:setAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self:addChild(tipLabel)

    local w = tipLabel:getContentSize().width * 1.3
    if (w < display.width / 3) then
        w = display.width * 0.4
    end
    self:setPreferredSize(cc.size(w, tipLabel:getContentSize().height + 40))

    tipLabel:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)

    local delayTime = delayTime or 2
    local action =
        transition.sequence(
        {
            CCMoveBy:create(0.5, cc.p(0, display.height / 6)),
            CCDelayTime:create(delayTime),
            CCFadeOut:create(2.0),
            CCRemoveSelf:create(true)
        }
    )
    self:runAction(action)
end

return TipLabel
