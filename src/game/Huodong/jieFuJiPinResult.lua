--[[
 --
 -- @authors shan 
 -- @date    2014-06-03 17:40:45
 -- @version 
 --
 --]]
require("game.GameConst")

local JieFuJiPinResult =
    class(
    "JieFuJiPinResult",
    function(data)
        return require("utility.ShadeLayer").new()
    end
)

function JieFuJiPinResult:ctor(data)
    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()

    self.jumpFunc = data.jumpFunc
    local totalDamge = data.totalDamage
    local totalMoney = data.totalMoney

    self._rootnode = {}

    local node = CCBReaderLoad("ccbi/huodong/jiefujipin_result_layer.ccbi", proxy, self._rootnode)

    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    local function setNumPos(parent, num)
        num:setPosition(parent:getPositionX() + parent:getContentSize().width, parent:getPositionY()) --parent:getContentSize().height/2)
    end
    --+num:getContentSize().width/2
    self.curDamageNum =
        newTTFLabelWithShadow(
        {
            text = totalDamge,
            size = 26,
            color = cc.c3b(230, 56, 56),
            shadowColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_haibao,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )
    setNumPos(self._rootnode["total_num"], self.curDamageNum)

    -- self._rootnode["total_num"]
    self._rootnode["listView"]:addChild(self.curDamageNum)

    self.curSilverNum =
        newTTFLabelWithShadow(
        {
            text = totalMoney,
            size = 26,
            -- color = cc.c3b(231,230,228),
            shadowColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_haibao,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )
    setNumPos(self._rootnode["silver_icon"], self.curSilverNum)

    self._rootnode["listView"]:addChild(self.curSilverNum)

    self._rootnode["confirm_btn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            self.jumpFunc()
        end,
        CCControlEventTouchDown
    )

    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
end

function JieFuJiPinResult:setJumpFunc(func)
    --设置跳转函数
    self.jumpFunc = func
end

return JieFuJiPinResult
