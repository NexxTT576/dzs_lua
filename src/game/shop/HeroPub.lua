--[[
 --
 -- @authors shan 
 -- @date    2014-06-18 16:44:59
 -- @version 
 --
 --]]
local HeroPub =
    class(
    "HeroPub",
    function(...)
        return display.newNode("HeroPub")
    end
)

function HeroPub:ctor(...)
    self:setNodeEventEnabled(true)

    local proxy = CCBProxy:create()
    local rootnode = rootnode or {}

    local node = CCBReaderLoad("shop/shop_pub.ccbi", proxy, rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    self:addChild(layer)

    local function getOneHero(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        RequestHelper.recrute(
            {
                callback = function(data)
                    dump(data)
                end,
                t = tag,
                n = 1
            }
        )
    end

    rootnode["commonHeroBtn"]:registerScriptTapHandler(getOneHero)

    rootnode["nbHeroBtn"]:registerScriptTapHandler(getOneHero)

    rootnode["superNBHeroBtn"]:registerScriptTapHandler(getOneHero)

    rootnode["payBtn"]:registerScriptTapHandler(
        function(tag)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end
    )
end

function HeroPub:onCloseCallback(f)
    self.callback = f
end

return HeroPub
