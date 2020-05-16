--[[
 --
 -- add by vicky
 -- 2015.03.11 
 --
 --]]
local GuildFubenDynamicItem =
    class(
    "GuildFubenDynamicItem",
    function()
        return CCTableViewCell:new()
    end
)

function GuildFubenDynamicItem:getContentSize()
    dump("getContentSize")

    if self._contentSz == nil then
        local proxy = CCBProxy:create()
        local rootnode = {}
        local node = CCBReaderLoad("guild/guild_fuben_dynamic_item.ccbi", proxy, rootnode)
        self._contentSz = rootnode["item_bg"]:getContentSize()
        self:addChild(node)
        node:removeSelf()
    end

    return self._contentSz
end

function GuildFubenDynamicItem:create(param)
    local viewSize = param.viewSize
    local itemData = param.itemData
    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBReaderLoad("guild/guild_fuben_dynamic_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width / 2, 0)
    self:addChild(node)

    self:refreshItem(itemData)

    return self
end

function GuildFubenDynamicItem:refresh(itemData)
    self:refreshItem(itemData)
end

function GuildFubenDynamicItem:refreshItem(itemData)
    -- dump(itemData.content)

    local function createText(text, contentNode)
        contentNode:removeAllChildren()

        local infoNode = getRichText(text, contentNode:getContentSize().width)
        infoNode:setPosition(0, contentNode:getContentSize().height - 30)
        contentNode:addChild(infoNode)
    end

    -- 内容
    createText(itemData.content, self._rootnode["content_tag"])
end

return GuildFubenDynamicItem
