require("game.GameConst")
local data_item_item = require("data.data_item_item")
local data_jiefujipin_jiefujipin = require("data.data_jiefujipin_jiefujipin")

local jiefuRuleLayer =
    class(
    "jiefuRuleLayer",
    function(data)
        return require("utility.ShadeLayer").new()
    end
)

function jiefuRuleLayer:ctor(data)
    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()

    self.jumpFunc = data.jumpFunc

    self._rootnode = {}

    local node = CCBReaderLoad("ccbi/huodong/jiefujipin_rule_layer.ccbi", proxy, self._rootnode)

    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    self._rootnode["confirm_btn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            self.jumpFunc()
        end,
        CCControlEventTouchDown
    )

    self._rootnode["closeBtn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:removeSelf()
        end,
        CCControlEventTouchDown
    )

    for i = 1, #data_jiefujipin_jiefujipin do
        local jiefuData = data_jiefujipin_jiefujipin[i]
        local bar = self._rootnode["bar" .. i]
        local curDamageNum =
            newTTFLabelWithShadow(
            {
                text = jiefuData.damage,
                size = 30,
                color = cc.c3b(234, 193, 135),
                shadowColor = cc.c3b(0, 0, 0),
                font = FONTS_NAME.font_haibao,
                align = cc.TEXT_ALIGNMENT_LEFT
            }
        )
        curDamageNum:setPosition(bar:getContentSize().width * 0.18, bar:getContentSize().height / 2)
        bar:addChild(curDamageNum)

        local curSilverNum =
            newTTFLabelWithShadow(
            {
                text = jiefuData.silver,
                size = 30,
                -- color = cc.c3b(231,230,228),
                shadowColor = cc.c3b(0, 0, 0),
                font = FONTS_NAME.font_haibao,
                align = cc.TEXT_ALIGNMENT_LEFT
            }
        )
        curSilverNum:setPosition(bar:getContentSize().width * 0.66, bar:getContentSize().height / 2)
        bar:addChild(curSilverNum)
    end

    -- local totalDamge = data.totalDamage
    -- local totalMoney = data.totalMoney

    -- local function setNumPos(parent,num)
    --     num:setPosition(parent:getContentSize().width+num:getContentSize().width/2,parent:getContentSize().height/2)
    -- end

    -- self.curDamageNum =newTTFLabelWithShadow({
    --     text = totalDamge,
    --     size = 26,
    --     color = cc.c3b(230,56,56),
    --     shadowColor = cc.c3b(0,0,0),
    --     font = FONTS_NAME.font_haibao,
    --     align = cc.TEXT_ALIGNMENT_LEFT
    --     })
    -- setNumPos(self._rootnode["total_num"],self.curDamageNum)

    -- self._rootnode["total_num"]:addChild(self.curDamageNum)

    -- self.curSilverNum =newTTFLabelWithShadow({
    --     text = totalMoney,
    --     size = 26,
    --     -- color = cc.c3b(231,230,228),
    --     shadowColor = cc.c3b(0,0,0),
    --     font = FONTS_NAME.font_haibao,
    --     align = cc.TEXT_ALIGNMENT_LEFT
    --     })
    -- setNumPos(self._rootnode["silver_icon"],self.curSilverNum)

    -- self._rootnode["silver_icon"]:addChild(self.curSilverNum)

    -- GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
end

function jiefuRuleLayer:setJumpFunc(func)
    --设置跳转函数
    self.jumpFunc = func
end

return jiefuRuleLayer
