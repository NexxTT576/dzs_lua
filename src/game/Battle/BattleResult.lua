require("game.GameConst")

local scheduler = require("utility.scheduler")

--@RefType ShadeLayer
local BattleResult =
    class(
    "BattleResult",
    function(data)
        -- return display.newNode()
        return require("utility.ShadeLayer").new()
    end
)

function BattleResult:ctor(data)
    self.jumpFunc = data.jumpFunc
    -- dump(self.jumpFunc)
    self.curLv = data.curLv
    self.befLv = data.befLv

    display.loadSpriteFrames("ui/ui_common_button.plist", "ui/ui_common_button.png")
    display.loadSpriteFrames("ui/ui_shuxingIcon.plist", "ui/ui_shuxingIcon.png")

    local winType = data.win or 2
    if winType == 1 then
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
        self:initWin(data)
    else
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
        self:initLost(data)
    end

    RequestHelper.getLevelList(
        {
            id = bigMapID,
            callback = function(data)
                -- dump(data)
                game.player.bigmapData = data
            end
        }
    )
end

function BattleResult:onEnter()
    -- body
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function BattleResult:initWin(rewards)
    dump(rewards)
    local proxy = CCBProxy:create()
    -- local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}
    local nodeSz = cc.size(640, 850)
    local boxSz = cc.size(450, 154)

    self:enableNodeEvents()

    -- rewards.rewardItem[3] = rewards.rewardItem[2]
    -- rewards.rewardItem[4] = rewards.rewardItem[2]
    -- rewards.rewardItem[5] = rewards.rewardItem[2]
    if #rewards.rewardItem > 4 then
        nodeSz = cc.size(640, 960)
        boxSz = cc.size(450, 268)
    end

    local node = CCBReaderLoad("ccbi/battle/battle_win.ccbi", proxy, rootnode, self, nodeSz)
    node:setIgnoreAnchorPointForPosition(false)
    node:setPosition(display.width / 2, display.height * 0.58)
    self:addChild(node)

    display.loadSpriteFrames("ui/ui_battle_win.plist", "ui/ui_battle_win.png")

    local rewardNode = rootnode["reward_node"]
    local rewardBg = display.newSprite("#bw_bottom_bg.png", 0, 0, {scale9 = true, size = boxSz})
    rewardBg:setAnchorPoint(cc.p(0.5, 1.0))
    rewardBg:setPosition(rewardBg:getContentSize().width / 2, 0)
    rewardNode:addChild(rewardBg)

    --@RefType luaIde#ccui.Scale9Sprite
    local bg = rootnode["tag_bg"]
    if (display.sizeInPixels.width / display.sizeInPixels.height) > 0.66 then
        bg:setPreferredSize(cc.size(bg:getContentSize().width, display.sizeInPixels.height * 0.65))
    end

    if (ResMgr.isHighEndDevice() == true) then
        -- 关卡特效
        local effWin =
            ResMgr.createArma(
            {
                resType = ResMgr.UI_EFFECT,
                armaName = "zhandoushengli",
                isRetain = true
            }
        )
        effWin:setPosition(rootnode["tag_title_anim"]:getContentSize().width / 2, rootnode["tag_title_anim"]:getContentSize().height)
        rootnode["tag_title_anim"]:addChild(effWin)
    end
    local effTextWin =
        ResMgr.createArma(
        {
            resType = ResMgr.UI_EFFECT,
            armaName = "zhandoushengli_zi",
            isRetain = true
        }
    )
    effTextWin:setPosition(rootnode["tag_title_anim"]:getContentSize().width / 2, rootnode["tag_title_anim"]:getContentSize().height)
    rootnode["tag_title_anim"]:addChild(effTextWin)

    rootnode["tag_lv"]:setString(game.player.m_level)
    rootnode["tag_zhanli"]:setString(game.player.m_battlepoint)
    if (rewards.levelName ~= nil) then
        -- rootnode["tag_level_name"]:setString(rewards.levelName)
        local titleLabel =
            newTTFLabelWithOutline(
            {
                text = rewards.levelName,
                font = FONTS_NAME.font_haibao,
                size = 28,
                color = FONT_COLOR.LEVEL_NAME,
                -- outlineColor = cc.c3b(100,17,2),
                align = cc.TEXT_ALIGNMENT_CENTER,
                x = rootnode["tag_level_name"]:getContentSize().width / 2,
                y = rootnode["tag_level_name"]:getContentSize().height / 2
            }
        )
        rootnode["tag_level_name"]:addChild(titleLabel)
    end

    -- 战斗奖励金钱
    local rewardMoney = rootnode["tag_mid_bg"]

    local textTag = {"tag_silver", "tag_xiahun", "tag_exp"}
    self.coinTable = {}
    self.coinNum = {}
    ResMgr.setMetatableByKV(self.coinTable)
    ResMgr.setMetatableByKV(self.coinNum)

    for i, v in ipairs(rewards.rewardCoin) do
        local x = 0
        local y = 0
        local tag = ""
        if (v.id == 2) then
            tag = "tag_silver"
        elseif (v.id == 7) then
            tag = "tag_xiahun"
        elseif (v.id == 6) then
            tag = "tag_exp"
        end
        _x = rootnode[tag]:getContentSize().width * 1.5
        _y = rootnode[tag]:getContentSize().height * 0.4
        local coinTextLabel =
            newTTFLabel(
            {
                text = v.num,
                x = rootnode[tag]:getContentSize().width / 2 + 30, -- _x,
                y = _y,
                font = FONTS_NAME.font_fzcy,
                size = 20,
                color = cc.c3b(0, 0, 0),
                align = cc.TEXT_ALIGNMENT_LEFT
            }
        )
        self.coinTable[#self.coinTable + 1] = coinTextLabel
        self.coinNum[#self.coinNum + 1] = v.num
        if (tag ~= "") then
            rootnode[tag]:addChild(coinTextLabel)
        else
            dump(v)
        end
    end

    local TIME_TO = 0.1

    local repeatIndex = 60 - 30
    local interval = TIME_TO / repeatIndex

    local index = 0

    local function update(dt)
        index = index + 1
        for i = 1, #self.coinTable do
            self.coinTable[i]:setString(math.floor(self.coinNum[i] / repeatIndex) * index)
        end

        if index >= repeatIndex then
            self.scheduler.unscheduleGlobal(self.timeHandle)
            for i = 1, #self.coinTable do
                self.coinTable[i]:setString(self.coinNum[i])
            end
        end
    end

    self.scheduler = require("utility.scheduler")
    if self.timeHandle ~= nil then
        self.scheduler.unscheduleGlobal(self.timeHandle)
    end
    self.timeHandle = self.scheduler.scheduleGlobal(update, interval, false)

    -- 经验条
    local percent = game.player.m_exp / game.player.m_maxExp

    local befPercent = game.player.m_befExp / game.player.m_maxExp
    -- print("bebebebebebebe  "..befPercent)
    -- print("aaaaaaaffffff   "..percent)

    -- dump(percent)
    if (percent > 1) then
        percent = 1
    end
    -- local bar = rootnode["tag_lv_bar"]
    -- bar:setTextureRect(cc.rect(bar:getTextureRect().origin.x, bar:getTextureRect().origin.y,
    --     bar:getContentSize().width*percent, bar:getTextureRect().size.height))

    self.addBar = display.newProgressTimer("#bw_exp_green.png", display.PROGRESS_TIMER_BAR)
    self.addBar:setMidpoint(cc.p(0, 0.5))
    self.addBar:setBarChangeRate(cc.p(1, 0))
    self.addBar:setAnchorPoint(cc.p(0, 0.5))
    self.addBar:setPosition(0, rootnode["bw_exp_gray"]:getContentSize().height / 2)
    rootnode["bw_exp_gray"]:addChild(self.addBar)
    self.addBar:setPercentage(befPercent * 100)

    local riseAnim
    if self.curLv ~= self.befLv then
        riseAnim =
            transition.sequence(
            {
                CCProgressTo:create(TIME_TO * (1 - befPercent) / ((1 - befPercent) + percent), 100),
                cc.CallFunc:create(
                    function()
                        self.addBar:setPercentage(0)
                    end
                ),
                CCProgressTo:create(TIME_TO * percent / ((1 - befPercent) + percent), percent * 100)
            }
        )
    else
        riseAnim = CCProgressTo:create(TIME_TO, percent * 100)
    end

    self.addBar:runAction(riseAnim)

    if (rewards.gradeID ~= nil) then
        if (rewards.gradeID == 2) then
            rootnode["tag_star_title"]:setSpriteFrame(display.newSpriteFrame("bw_normal.png"))
        elseif (rewards.gradeID == 3) then
            rootnode["tag_star_title"]:setSpriteFrame(display.newSpriteFrame("bw_hard.png"))
        end

        for i = 3, rewards.maxStar + 1, -1 do
            print("gray_star_" .. i)
            rootnode["gray_star_" .. i]:setVisible(false)
        end

        for i = 1, rewards.gradeID do
            rootnode["star_" .. i]:setVisible(true)
        end
    end

    -- 战斗奖励物品

    -- dump(rewards)

    local _data = nil --data_item_item[v.id]
    local w = 95
    local h = 95

    local data_item_item = require("data.data_item_item")
    for k, v in pairs(rewards.rewardItem) do
        local itemType = 1
        itemType = ResMgr.getResType(v["type"])
        if itemType == ResMgr.EQUIP then
            _data = data_item_item[v.id]
        elseif itemType == ResMgr.HERO then
            _data = ResMgr.getCardData(v.id)
        elseif itemType == ResMgr.ITEM then
            itemType = ResMgr.ITEM
            _data = data_item_item[v.id]
        end

        -- if(v.t <= 3 ) then
        --     itemType = ResMgr.EQUIP
        --     _data = data_item_item[v.id]
        -- elseif(v.t == 5 or v.t == 8) then
        --     itemType = ResMgr.HERO
        --     _data = ResMgr.getCardData(v.id)
        -- else
        --     itemType = ResMgr.ITEM
        --     _data = data_item_item[v.id]
        -- end

        local item = ResMgr.getIconSprite({id = v.id, resType = itemType})
        print(item:getContentSize().width .. "," .. item:getContentSize().height)
        local x = w * 0.72 + math.floor((k - 1) % 4) * w * 1.1
        local y = rewardBg:getContentSize().height + h * 0.45 - h * 1.22 * (1 + math.floor(((k - 1) / 4)))
        item:setPosition(x, y)
        rewardBg:addChild(item)

        local y = -10
        local nameColor = cc.c3b(255, 216, 0)
        if itemType == ResMgr.ITEM or itemType == ResMgr.EQUIP then
            nameColor = ResMgr.getItemNameColor(v.id)
        elseif itemType == ResMgr.HERO then
            nameColor = ResMgr.getHeroNameColor(v.id)
            y = -8
        end

        local itemName =
            newTTFLabelWithShadow(
            {
                text = _data.name,
                x = item:getContentSize().width / 2,
                y = y,
                size = 20,
                color = nameColor,
                shadowColor = display.COLOR_BLACK,
                font = FONTS_NAME.font_fzcy,
                align = cc.TEXT_ALIGNMENT_CENTER
            }
        )
        item:addChild(itemName)

        local itemNum =
            newTTFLabelWithOutline(
            {
                text = v.num,
                size = 22,
                color = cc.c3b(0, 255, 0),
                outlineColor = display.COLOR_BLACK,
                font = FONTS_NAME.font_fzcy,
                align = cc.TEXT_ALIGNMENT_CENTER
            }
        )
        itemNum:setPosition(item:getContentSize().width - itemNum:getContentSize().width, item:getContentSize().height * 0.18)
        item:addChild(itemNum)

        if v.t == 3 then
            -- 装备碎片
            local suipianIcon = display.newSprite("#sx_suipian.png")
            suipianIcon:setRotation(-15)
            suipianIcon:setAnchorPoint(cc.p(0, 1))
            suipianIcon:setPosition(-0.13 * item:getContentSize().width, 0.9 * item:getContentSize().height)
            item:addChild(suipianIcon)
        elseif v.t == 5 then
            -- 残魂(武将碎片)
            local canhunIcon = display.newSprite("#sx_canhun.png")
            canhunIcon:setRotation(-18)
            canhunIcon:setAnchorPoint(cc.p(0, 1))
            canhunIcon:setPosition(-0.13 * item:getContentSize().width, 0.93 * item:getContentSize().height)
            item:addChild(canhunIcon)
        end
    end

    -- local shareBtn = require("utility.CommonButton").new({
    --         img = "#com_btn_large_red.png",
    --         listener = function (  )
    --             if self.jumpFunc ~= nil then
    --                 self.jumpFunc()
    --             end
    --         end
    --         })
    -- shareBtn:setPosition(20, shareBtn:getContentSize().height*0.35)
    -- bg:addChild(shareBtn)

    -- local shareText = newTTFLabel({
    --     text = "返回",
    --     x = shareBtn:getContentSize().width*1.1/2,
    --     y = shareBtn:getContentSize().height/2,
    --     font = FONTS_NAME.font_haibao,
    --     size = 36,
    --     align = cc.TEXT_ALIGNMENT_CENTER
    --     })
    -- shareBtn:addChild(shareText,1)

    -- local okBtn = require("utility.CommonButton").new({
    --         img = "#com_btn_large_red.png",
    --         listener = function (  )
    --             if self.jumpFunc ~= nil then
    --                 self.jumpFunc()
    --             end
    --             PostNotice(NoticeKey.REMOVE_TUTOLAYER)
    --         end
    --         })
    -- okBtn:setPosition(bg:getContentSize().width-okBtn:getContentSize().width*1.15, okBtn:getContentSize().height*0.35)
    -- bg:addChild(okBtn)

    -- local okText = newTTFLabel({
    --     text = "确定",
    --     x = okBtn:getContentSize().width/2,
    --     y = okBtn:getContentSize().height/2,
    --     font = FONTS_NAME.font_haibao,
    --     size = 36,
    --     align = cc.TEXT_ALIGNMENT_CENTER
    --     })
    -- okBtn:setFont(okText)

    rootnode["confirmBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if self.jumpFunc ~= nil then
                self.jumpFunc()
            end
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        end,
        CCControlEventTouchDown
    )

    print("add btn zhandoushengli1_btn_quedinganniu1")
    TutoMgr.addBtn("zhandoushengli1_btn_quedinganniu1", rootnode["confirmBtn"])
    ResMgr.delayFunc(
        0.5,
        function()
            TutoMgr.active()
        end
    )
end
function BattleResult:setJumpFunc(func)
    --设置跳转函数
    self.jumpFunc = func
end

function BattleResult:initLost(rewards)
    dump(rewards)
    local proxy = CCBProxy:create()
    -- local ccbReader = proxy:createCCBReader()
    local rootnode = rootnode or {}
    -- ccb 2.
    local node = CCBReaderLoad("ccbi/battle/lost.ccbi", proxy, rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    self:addChild(layer)

    local bg = rootnode["tag_bg"]

    rootnode["tag_zhanli"]:setString(game.player.m_battlepoint)

    if (rewards.levelName ~= nil) then
        -- rootnode["tag_level_name"]:setString(rewards.levelName)
        local titleLabel =
            newTTFLabelWithOutline(
            {
                text = rewards.levelName,
                font = FONTS_NAME.font_haibao,
                size = 28,
                color = FONT_COLOR.LEVEL_NAME,
                -- outlineColor = cc.c3b(100,17,2),
                align = cc.TEXT_ALIGNMENT_CENTER,
                x = rootnode["tag_level_name"]:getContentSize().width / 2,
                y = rootnode["tag_level_name"]:getContentSize().height / 2
            }
        )
        rootnode["tag_level_name"]:addChild(titleLabel)
    end

    if (rewards.gradeID ~= nil) then
        if (rewards.gradeID == 2) then
            rootnode["tag_star_title"]:setSpriteFrame(display.newSpriteFrame("bw_normal.png"))
        elseif (rewards.gradeID == 3) then
            rootnode["tag_star_title"]:setSpriteFrame(display.newSpriteFrame("bw_hard.png"))
        end

        for i = 3, rewards.maxStar + 1, -1 do
            rootnode["gray_star_" .. i]:setVisible(false)
        end

        if (rewards.star > 0) then
            for i = 1, rewards.star do
                rootnode["star_" .. i]:setVisible(true)
            end
        end
    end

    -- 武将强化
    rootnode["wujiangBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
        end,
        CCControlEventTouchUpInside
    )

    -- 装备强化
    rootnode["zhuangbeiBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
        end,
        CCControlEventTouchUpInside
    )

    -- 阵容
    rootnode["goZhenrongBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
        end,
        CCControlEventTouchUpInside
    )

    -- 侠客送礼
    rootnode["heroRewardBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
        end,
        CCControlEventTouchUpInside
    )

    -- 真气
    rootnode["zhenqiBtn"]:registerControlEventHandler(
        function(sender)
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end,
        CCControlEventTouchUpInside
    )

    rootnode["confirmBtn"]:registerControlEventHandler(
        function(sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            if self.jumpFunc ~= nil then
                self.jumpFunc()
            end
        end,
        CCControlEventTouchDown
    )
end

function BattleResult:onExit(...)
    if self.timeHandle ~= nil then
        self.scheduler.unscheduleGlobal(self.timeHandle)
    end
    TutoMgr.removeBtn("zhandoushengli1_btn_quedinganniu1")
    display.removeSpriteFrames("ui/ui_common_button.plist", "ui/ui_common_button.png")

    ResMgr.ReleaseUIArmature("zhandoushengli")
    ResMgr.ReleaseUIArmature("zhandoushengli_zi")

    display.removeImage("ccs/ui_effect/zhandoushengli/zhandoushengli.png")
    display.removeImage("ccs/ui_effect/zhandoushengli_zi/zhandoushengli_zi.png")
    display.removeImage("ccs/effect/nuqiji_zi/nuqiji_zi.png")
    display.removeImage("ccs/effect/dazhaoshifang/dazhaoshifa_bao.png")

    display.removeSpriteFrames("ui/ui_duobao.plist", "ui/ui_duobao.png")
    display.removeImage("ui_weijiao_yishou.png")
    display.removeSpriteFrames("ui/ui_battle_win.plist", "ui/ui_battle_win.png")
    display.removeSpriteFrames("ui/ui_battle.plist", "ui/ui_battle.png")

    cc.Director:getInstance():getTextureCache():removeUnusedTextures()

    collectgarbage("collect")
end

return BattleResult
