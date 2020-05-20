local GuildFubenCell =
    class(
    "GuildFubenCell",
    function()
        return CCTableViewCell:new()
    end
)

function GuildFubenCell:getContentSize()
    local proxy = CCBProxy:create()
    local rootNode = {}

    local node = CCBReaderLoad("guild/guild_fuben_item.ccbi", proxy, rootNode)
    local size = rootNode["itemBg"]:getContentSize()
    self:addChild(node)
    node:removeSelf()
    return size
end

function GuildFubenCell:getRewardBoxIcon()
    return self._rootnode["reward_box"]
end

function GuildFubenCell:create(param)
    local viewSize = param.viewSize
    local itemData = param.itemData

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBReaderLoad("guild/guild_fuben_item.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width * 0.5, 0)
    self:addChild(node)

    self:refreshItem(itemData)

    return self
end

function GuildFubenCell:refresh(itemData)
    self:refreshItem(itemData)
end

function GuildFubenCell:refreshItem(itemData)
    -- dump(itemData.fbid)

    -- 背景图
    local imagePath = "ui/ui_guild_fb/" .. itemData.icon .. ".png"
    dump(imagePath)

    local itemBg
    if itemData.state == FUBEN_STATE.notOpen then
        itemBg = display.newGraySprite(imagePath, {0.4, 0.4, 0.4, 0.1})
    else
        itemBg = display.newSprite(imagePath)
    end
    -- itemBg = display.newSprite(imagePath)
    itemBg:setAnchorPoint(0.5, 0)
    itemBg:setPosition(self._rootnode["itemBg_node"]:getContentSize().width / 2, 0)
    self._rootnode["itemBg_node"]:removeAllChildren()
    self._rootnode["itemBg_node"]:addChild(itemBg)

    -- 通关状态
    local rewardBox = self._rootnode["reward_box"]
    -- dump(itemData.state)
    if itemData.state == FUBEN_STATE.notOpen then
        ResMgr.createOutlineMsgTTF(
            {
                text = itemData.openMsg,
                parentNode = self._rootnode["open_msg_1"]
            }
        )

        ResMgr.createOutlineMsgTTF(
            {
                text = itemData.needLvMsg,
                color = cc.c3b(255, 222, 0),
                parentNode = self._rootnode["open_msg_2"]
            }
        )
        self._rootnode["passed_icon"]:setVisible(false)
        self._rootnode["open_node"]:setVisible(true)
        self._rootnode["hp_node"]:setVisible(false)
    else
        if itemData.state == FUBEN_STATE.hasPass then
            self._rootnode["passed_icon"]:setVisible(true)
        else
            self._rootnode["passed_icon"]:setVisible(false)
        end
        self._rootnode["open_node"]:setVisible(false)
        self._rootnode["hp_node"]:setVisible(true)
    end

    self:setBoxState(itemData.boxState)
    self:updateHp(itemData)
end

function GuildFubenCell:updateHp(itemData)
    -- 血量相关
    self._rootnode["blood_lbl"]:setString(tostring(itemData.leftHp) .. "/" .. tostring(itemData.totalHp))

    -- 血量条
    local percent = itemData.leftHp / itemData.totalHp
    local normalBar = self._rootnode["normalBar"]
    local bar = self._rootnode["addBar"]
    local rotated = false
    if bar:isTextureRectRotated() == true then
        rotated = true
    end

    bar:setTextureRect(
        cc.rect(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y, normalBar:getContentSize().width * percent, bar:getTextureRect().size.height),
        rotated,
        cc.size(normalBar:getContentSize().width * percent, normalBar:getContentSize().height * percent)
    )
end

function GuildFubenCell:setBoxState(state)
    local rewardBox = self._rootnode["reward_box"]

    if state == FUBEN_REWARD_STATE.notOpen then
        rewardBox:setDisplayFrame(display.newSprite("#guild_fuben_box_1.png"):getSpriteFrame())
    elseif state == FUBEN_REWARD_STATE.canGet then
        rewardBox:setDisplayFrame(display.newSprite("#guild_fuben_box_2.png"):getSpriteFrame())
    elseif state == FUBEN_REWARD_STATE.hasGet then
        rewardBox:setDisplayFrame(display.newSprite("#guild_fuben_box_3.png"):getSpriteFrame())
    end
end

return GuildFubenCell
