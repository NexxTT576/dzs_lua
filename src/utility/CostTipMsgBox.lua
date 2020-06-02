--@SuperType ShadeLayer
local CostTipMsgBox =
    class(
    "CostTipMsgBox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function CostTipMsgBox:ctor(param)
    display.loadSpriteFrames("ui/ui_common_button.plist", "ui/ui_common_button.png")
    local _costNum = param.cost
    local _tip = param.tip
    local _listener = param.listener
    local _cancelListener = param.cancelListener

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBReaderLoad("public/cost_tip_msg.ccbi", proxy, self._rootnode)
    node:setPosition(display.cx, display.cy)
    self:addChild(node)

    self._rootnode["cost_num"]:setString(tostring(_costNum))
    self._rootnode["tipLabel"]:setString(tostring(_tip))

    local function close()
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
        if _cancelListener then
            _cancelListener()
        end
        self:removeSelf()
    end

    self._rootnode["closeBtn"]:registerControlEventHandler(close, CCControlEventTouchUpInside)

    self._rootnode["cancelBtn"]:registerControlEventHandler(close, CCControlEventTouchUpInside)

    self._rootnode["confirmBtn"]:registerControlEventHandler(
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            _listener()
            self:removeSelf()
        end,
        CCControlEventTouchUpInside
    )
end

return CostTipMsgBox
