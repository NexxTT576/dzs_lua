--[[
 --
 -- add by vicky
 -- 2015.01.15 
 --
 --]]
local GuildFuliRewardMsgBox =
    class(
    "GuildFuliRewardMsgBox",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function GuildFuliRewardMsgBox:ctor(param)
    local tili = param.tili
    local naili = param.naili
    local proxy = CCBProxy:create()
    local rootnode = {}
    local node = CCBReaderLoad("ccbi/guild/guild_guildFuli_reward_msgBox.ccbi", proxy, rootnode)
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    rootnode["tili_lbl"]:setString(tostring(tili))
    rootnode["naili_lbl"]:setString(tostring(naili))

    local function closeFunc()
        self:removeFromParent(true)
    end

    rootnode["confirmBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            closeFunc()
        end,
        CCControlEventTouchUpInside
    )

    rootnode["tag_close"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            closeFunc()
        end,
        CCControlEventTouchUpInside
    )
end

return GuildFuliRewardMsgBox
