local CardLayer =
    class(
    "CardLayer",
    function()
        return require("utility.ShadeLayer").new()
    end
)

function CardLayer:ctor(heroInfo)
    display.loadSpriteFrames("ui/ui_common_button.plist", "ui/ui_common_button.png")

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBReaderLoad("shop/hero_card2.ccbi", proxy, rootnode)
    node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self:addChild(node, 100)

    dump(rootnode)

    --    local label = ui.newTTFLabel({
    --        text = heroInfo.name,
    --        size = 30,
    --        x = node:getContentSize().width / 2,
    --        y = node:getContentSize().height / 2
    --    })
    --    node:addChild(label)

    local okBtn =
        require("utility.CommonButton").new(
        {
            img = "#com_btn_large_red.png",
            listener = function()
                self:removeFromParent(true)
            end
        }
    )
    okBtn:setPosition(node:getContentSize().width * 0.8, node:getContentSize().height * 0.1)
    node:addChild(okBtn)

    --
    --    cardroot["closeBtn"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function()
    --        self:removeFromParent(true)
    --    end)
end

return CardLayer
