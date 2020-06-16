--[[
 --
 -- add by vicky
 -- 2014.09.04
 --
 --]]
local LianzhanMsgBox =
    class(
    "LianzhanMsgBox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function LianzhanMsgBox:ctor(param)
    local gold = param.gold
    local listener = param.listener

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBReaderLoad("battle/liangzhan_msgbox.ccbi", proxy, rootnode)
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    rootnode["goldNumLbl"]:setString(gold)

    -- 确认
    rootnode["confirmBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if listener ~= nil then
                listener()
            end
            self:removeFromParent(true)
        end,
        CCControlEventTouchUpInside
    )

    -- 关闭
    rootnode["closeBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:removeFromParent(true)
        end,
        CCControlEventTouchUpInside
    )

    -- 关闭
    rootnode["cancelBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:removeFromParent(true)
        end,
        CCControlEventTouchUpInside
    )
end

return LianzhanMsgBox
