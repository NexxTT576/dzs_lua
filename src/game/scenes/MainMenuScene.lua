--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-13 17:42:52
]]
--@SuperType luaIde#cc.Scene
local MainMenuScene =
    class(
    "MainMenuScene",
    function()
        return display.newScene("MainMenuScene")
    end
)

function MainMenuScene:ctor(showNote)
    self.showNote = showNote
    ResMgr.setTimeScale(1)
    ccs.ArmatureDataManager:getInstance()
    ccs.ArmatureDataManager:destroyInstance()
    self:enableNodeEvents()
end

function MainMenuScene:updateFriendActIcon()
    if GameModel.isFriendActive() then
        self._rootnode["friend_red_point"]:setVisible(true)
    else
        self._rootnode["friend_red_point"]:setVisible(false)
    end
end
function MainMenuScene:playMusic()
    GameAudio.playMainmenuMusic(true)
end

function MainMenuScene:onEnter()
    display.removeUnusedSpriteFrames()
    self.blackLayer = display.newLayer(cc.c4b(0, 0, 0, 0))
    self:addChild(self.blackLayer)
    local proxy = CCBProxy:create()
    local rootnode = rootnode or {}

    --主菜单背景
    local ccb_mm_name = "ccbi/mainmenu/mainmenu.ccbi"
    local curTime = tonumber(os.date("%H", os.time()))

    -- 夜晚背景显示
    if (curTime > 18 or curTime < 6) then
        ccb_mm_name = "ccbi/mainmenu/mainmenu_night.ccbi"
    end
    GameAudio.playMainmenuMusic(true)

    local node = CCBReaderLoad(ccb_mm_name, proxy, rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    layer:setPosition(0, display.height / 2)
    self:addChild(layer)

    self.moveBg = rootnode["tag_earth"]

    local homeBg2oraginalX = rootnode["homgBg2"]:getPositionX()
    local homeBg2oraginalY = rootnode["homgBg2"]:getPositionY()

    local homeBg3oraginalX = rootnode["homgBg3"]:getPositionX()
    local homeBg3oraginalY = rootnode["homgBg3"]:getPositionY()
    self.acceLayer = rootnode["controlLayer"]

    -- 主菜单顶部玩家信息条
    local node = CCBReaderLoad("ccbi/mainmenu/mm_top_layer.ccbi", proxy, rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    self:addChild(layer)
    self.info_box = rootnode["info_box"]
    self.topFrame = rootnode["tag_zhanli"]
    -- ccb 3. get playerinfo tag
    self.playerInfoNode = rootnode

    -- 系统时间
    self.timeLabel = rootnode["tag_time"]
    local str = GetSystemTime()
    self.timeLabel:setString(str)

    local function update(...)
        local str = GetSystemTime()
        self.timeLabel:setString(str)
        -- 在线奖励时间倒计时
        if game.player.m_isShowOnlineReward then
            if self.onlineRewardTime ~= nil then
                if self.onlineRewardTime > 0 then
                    self.onlineRewardTime = self.onlineRewardTime - 1
                    self._rootnode["tag_onlineTimeLbl"]:setString(format_time(self.onlineRewardTime))
                    self._rootnode["online_notice"]:setVisible(false)
                    self:createParticalEff(self._rootnode["tag_zaixian_node"], false)

                    if self.onlineRewardTime <= 0 then
                        self._rootnode["tag_onlineTimeLbl"]:setVisible(false)
                        self._rootnode["tag_onlineCanGet"]:setVisible(true)
                        self._rootnode["online_notice"]:setVisible(true)
                        self._rootnode["online_num"]:setString("1")
                        self:createParticalEff(self._rootnode["tag_zaixian_node"], true)
                    end
                end
            end
        end
    end

    schedule(self, update, 1)
    local lastX = 0
    local isTouchMove = true
    local curMoveNum = 0

    -- 最底部按钮
    self.bottom = require("game.scenes.BottomLayer"):create()
    self:addChild(self.bottom, 100)

    -- 倒数第2行按钮
    self:bottomBtns_2(self.bottom:getContentSize().height * 1.15)

    local broadcastBg = rootnode["broadcast_tag"]
    local g = broadcastBg:getParent()
    if game.broadcast:getParent() ~= nil then
        game.broadcast:removeFromParent(true)
    end
    broadcastBg:addChild(game.broadcast)
    print("hieieieieiei")
    dump(GAME_DEBUG)
    dump(ENABLE_CHEAT)
    if (GAME_DEBUG == true) then
        if ENABLE_CHEAT == true then
            -- device.showAlert("GAME_DEBUG","")
            local cheatLayer = require("game.scenes.cheatMenuLayer").new()
            -- cheatLayer:setPosition(display.width/2, display.height/2)
            self:addChild(cheatLayer, 10000)
        end
    end
    local bigMapID = nil
    if PageMemoModel.bigMapID ~= 0 then
        bigMapID = PageMemoModel.bigMapID
    end

    -- 请求大地图数据
    RequestHelper.getLevelList(
        {
            id = bigMapID,
            callback = function(data)
                -- dump(data)
                game.player.bigmapData = data
            end
        }
    )

    --请求阵容
    RequestHelper.formation.list(
        {
            m = "fmt",
            a = "list",
            pos = "0",
            param = {},
            callback = function(data)
                -- dump(data)
                game.player.m_formation = data
            end
        }
    )

    ResMgr.createBefTutoMask(self)
    TutoMgr.active()

    game.urgencyBroadcast:checkAndShow()
    self:regNotice()

    self:checkMailTip()
    -- ResMgr.endTime()

    -- add gamenote when player get into game on first time
    if (self.showNote ~= nil and self.showNote == true) then
        local noteLayer = require("game.Huodong.GameNote").new()
        self:addChild(noteLayer, GAMENOTE_ZORDER, HUODONG_TAG)
    end

    -- if(GAME_DEBUG == true) then
    --     ResMgr.showTextureCache()
    -- end

    GameModel.refreshNotice()

    -- 判断各个按钮是否可显示
    -- 在线礼包
    if game.player:getAppOpenData().zaixian == APPOPEN_STATE.close then
        self._rootnode["tag_zaixian_node"]:setVisible(false)
    else
        self._rootnode["tag_zaixian_node"]:setVisible(true)
    end

    -- 开服礼包
    if game.player:getAppOpenData().kaifu == APPOPEN_STATE.close then
        self._rootnode["tag_kaifu_node"]:setVisible(false)
    else
        self._rootnode["tag_kaifu_node"]:setVisible(true)
    end

    -- 等级礼包
    if game.player:getAppOpenData().dengji == APPOPEN_STATE.close then
        self._rootnode["tag_dengji_node"]:setVisible(false)
    else
        self._rootnode["tag_dengji_node"]:setVisible(true)
    end

    -- 成长之路
    if game.player:getAppOpenData().chengzhang == APPOPEN_STATE.close then
        self._rootnode["tag_chengzhangzhilu"]:setVisible(false)
    else
        self._rootnode["tag_chengzhangzhilu"]:setVisible(true)
    end

    -- 精彩活动
    if game.player:getAppOpenData().huodong == APPOPEN_STATE.close then
        self._rootnode["tag_jingcai_node"]:setVisible(false)
    else
        self._rootnode["tag_jingcai_node"]:setVisible(true)
    end

    -- 首充3倍
    if game.player:getAppOpenData().shouchong == APPOPEN_STATE.close then
        self._rootnode["tag_shouchong"]:setVisible(false)
    else
        self._rootnode["tag_shouchong"]:setVisible(true)
    end

    -- 宠物图标
    if game.player:getAppOpenData().chongwu == APPOPEN_STATE.close then
        self._rootnode["tag_pet"]:setVisible(false)
    else
        self._rootnode["tag_pet"]:setVisible(true)
    end
end

function MainMenuScene:regNotice()
    RegNotice(
        self,
        function()
            self:refreshPlayerBoard()
        end,
        NoticeKey.MainMenuScene_Update
    )

    RegNotice(
        self,
        function()
            self.bottom:setVisible(false)
        end,
        NoticeKey.MAINSCENE_HIDE_BOTTOM_LAYER
    )

    RegNotice(
        self,
        function()
            self.bottom:setVisible(true)
        end,
        NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER
    )

    -- 在线奖励
    RegNotice(
        self,
        function()
            if game.player:getAppOpenData().zaixian == APPOPEN_STATE.open then
                self:checkOnlineReward()
            end
        end,
        NoticeKey.MainMenuScene_OnlineReward
    )

    -- 奖励中心
    RegNotice(
        self,
        function()
            self:checkRewardCenter()
        end,
        NoticeKey.MainMenuScene_RewardCenter
    )

    -- 检查成长之路信息
    RegNotice(
        self,
        function()
            if game.player:getAppOpenData().chengzhang == APPOPEN_STATE.open then
                if (ENABLE_DAILY_TASK == true) then
                    self:checkDiaLayTask()
                end
            end
        end,
        NoticeKey.MainMenuScene_ChengZhangZhilu
    )

    -- 签到
    RegNotice(
        self,
        function()
            self:checkQiandao()
        end,
        NoticeKey.MainMenuScene_Qiandao
    )

    -- 等级礼包
    RegNotice(
        self,
        function()
            if game.player:getAppOpenData().dengji == APPOPEN_STATE.open then
                self:checkLevelReward()
            end
        end,
        NoticeKey.MainMenuScene_DengjiLibao
    )

    -- 开服礼包
    RegNotice(
        self,
        function()
            if game.player:getAppOpenData().kaifu == APPOPEN_STATE.open then
                self:checkKaifuReward()
            end
        end,
        NoticeKey.MainMenuScene_KaifuLibao
    )

    -- 聊天消息
    RegNotice(
        self,
        function()
            self:checkChatNewNum()
        end,
        NoticeKey.MainMenuScene_chatNewNum
    )

    -- 挑战
    RegNotice(
        self,
        function()
            self:checkChallengeNotice()
        end,
        NoticeKey.MainMenuScene_challenge
    )

    -- 背景音乐
    RegNotice(
        self,
        function()
            self:playMusic()
        end,
        NoticeKey.MainMenuScene_Music
    )

    -- 检测 紧急广播
    RegNotice(
        self,
        function()
            self:checkUrgencyBroadcast()
        end,
        NoticeKey.MainMenuScene_UrgencyBroadcast
    )

    -- 检测充值3倍
    RegNotice(
        self,
        function()
            if game.player:getAppOpenData().shouchong == APPOPEN_STATE.open then
                self:checkIsShowShouchong()
            end
        end,
        NoticeKey.MainMenuScene_Shouchong
    )

    RegNotice(self, handler(self, MainMenuScene.checkMailTip), NoticeKey.MAIL_TIP_UPDATE)

    RegNotice(
        self,
        function()
            self:updateFriendActIcon()
        end,
        NoticeKey.UP_FRIEND_ICON_ACT
    )

    RegNotice(self, handler(self, MainMenuScene.checkGuildApplyNum), NoticeKey.CHECK_GUILD_APPLY_NUM)
end

function MainMenuScene:checkGuildApplyNum()
    if game.player:getGuildApplyNum() > 0 then
        self._rootnode["guild_notice"]:setVisible(true)
    else
        self._rootnode["guild_notice"]:setVisible(false)
    end
end

-- 刷新mail提示 红点
function MainMenuScene:checkMailTip()
    if (game.player:hasMailTip() == true) then
        self._rootnode["mail_notice"]:setVisible(true)
        self._rootnode["mail_notice_bottom"]:setVisible(true)
    else
        self._rootnode["mail_notice"]:setVisible(false)
        self._rootnode["mail_notice_bottom"]:setVisible(false)
    end
end

-- 刷新提示按钮
function MainMenuScene:refreshNotice()
    PostNotice(NoticeKey.MainMenuScene_OnlineReward)
    PostNotice(NoticeKey.MainMenuScene_RewardCenter)
    PostNotice(NoticeKey.MainMenuScene_Qiandao)
    PostNotice(NoticeKey.MainMenuScene_DengjiLibao)
    PostNotice(NoticeKey.MainMenuScene_KaifuLibao)
    PostNotice(NoticeKey.BottomLayer_Chouka)
    PostNotice(NoticeKey.MainMenuScene_challenge)
    PostNotice(NoticeKey.MainMenuScene_Shouchong)
    PostNotice(NoticeKey.MainMenuScene_ChengZhangZhilu)
    PostNotice(NoticeKey.MAIL_TIP_UPDATE)
    PostNotice(NoticeKey.CHECK_GUILD_APPLY_NUM)
end

-- 首充3倍
function MainMenuScene:checkIsShowShouchong()
    if (game.player:getIsHasBuyGold() == true) then
        self._rootnode["tag_shouchong"]:setVisible(false)
    elseif (game.player:getIsHasBuyGold() == false) then
        self._rootnode["tag_shouchong"]:setVisible(true)
    end
end

-- 紧急广播
function MainMenuScene:checkUrgencyBroadcast()
    if game.urgencyBroadcast:getParent() ~= nil then
        game.urgencyBroadcast:removeFromParent(true)
    end

    game.urgencyBroadcast:setIsShow(true)
    game.urgencyBroadcast:setPosition(display.cx, display.cy)
    self:addChild(game.urgencyBroadcast, URGENCY_BROADCAST_ZORDER)
end

-- 挑战是否有剩余次数
function MainMenuScene:checkChallengeNotice()
    if game.player:getIsShowChallengeNotice() then
        self._rootnode["challenge_notice"]:setVisible(true)
    else
        self._rootnode["challenge_notice"]:setVisible(false)
    end
end

-- 聊天新消息
function MainMenuScene:checkChatNewNum()
    if game.player:getChatNewNum() > 0 then
        self._rootnode["chat_notice"]:setVisible(true)
        self:createNoticeFadeEff(self._rootnode["chat_eff"], true)
    else
        self._rootnode["chat_notice"]:setVisible(false)
        self:createNoticeFadeEff(self._rootnode["chat_eff"], false)
    end
end

-- 检测是否显示在线奖励
function MainMenuScene:checkOnlineReward()
    if not game.player.m_isShowOnlineReward then
        self._rootnode["tag_zaixian_node"]:setVisible(false)
        self:createParticalEff(self._rootnode["tag_zaixian_node"], false)
    else
        self._rootnode["tag_zaixian_node"]:setVisible(true)

        if game.player.m_onlineRewardTime <= 0 then
            self._rootnode["tag_onlineCanGet"]:setVisible(true)
            self._rootnode["tag_onlineTimeLbl"]:setVisible(false)
            self._rootnode["online_notice"]:setVisible(true)
            self._rootnode["online_num"]:setString("1")
            self:createParticalEff(self._rootnode["tag_zaixian_node"], true)
        else
            self.onlineRewardTime = game.player.m_onlineRewardTime
            self._rootnode["tag_onlineTimeLbl"]:setString(format_time(self.onlineRewardTime))
            self._rootnode["tag_onlineTimeLbl"]:setVisible(true)
            self._rootnode["tag_onlineCanGet"]:setVisible(false)
            self._rootnode["online_notice"]:setVisible(false)
            self:createParticalEff(self._rootnode["tag_zaixian_node"], false)
        end
    end
end

-- 检测是否显示奖励中心
function MainMenuScene:checkRewardCenter()
    if not game.player.m_isShowRewardCenter then
        self._rootnode["tag_lingjiang_node"]:setVisible(false)
        self:createParticalEff(self._rootnode["tag_lingjiang_node"], false)
    else
        self._rootnode["tag_lingjiang_node"]:setVisible(true)

        if game.player:getRewardcenterNum() > 0 then
            self._rootnode["rewardcenter_notice"]:setVisible(true)
            self._rootnode["rewardcenter_num"]:setString(game.player:getRewardcenterNum())
            self:createParticalEff(self._rootnode["tag_lingjiang_node"], true)
        else
            self._rootnode["rewardcenter_notice"]:setVisible(false)
            self:createParticalEff(self._rootnode["tag_lingjiang_node"], false)
        end
    end
end

-- 检测成长之路小红点
function MainMenuScene:checkDiaLayTask()
    if not game.player.m_isShowChengzhang then
        if self._rootnode["tag_chengzhangzhilu"]:getChildByTag(111) then
            self._rootnode["tag_chengzhangzhilu"]:getChildByTag(111):removeFromParent()
        end
    else
        if self._rootnode["tag_chengzhangzhilu"]:getChildByTag(111) then
        else
            local tagnew = display.newSprite("#toplayer_mail_tip.png")
            tagnew:setPosition(cc.p(85, 85))
            self._rootnode["tag_chengzhangzhilu"]:addChild(tagnew, 0, 111)
        end
    end
end

-- 检测签到
function MainMenuScene:checkQiandao()
    -- 先判断是否已开启签到，若未开启则不提示新消息
    local bHasOpen, _ = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.QianDao, game.player:getLevel(), game.player:getVip())

    if bHasOpen and game.player:getQiandaoNum() > 0 then
        self._rootnode["qiandao_notice"]:setVisible(true)
        self._rootnode["qiandao_num"]:setString(game.player:getQiandaoNum())
        self:createNoticeFadeEff(self._rootnode["qiandao_eff"], true)
    else
        self._rootnode["qiandao_notice"]:setVisible(false)
        self:createNoticeFadeEff(self._rootnode["qiandao_eff"], false)
    end
end

-- 检测等级礼包奖励
function MainMenuScene:checkLevelReward()
    if not game.player.m_isSHowDengjiLibao then
        self._rootnode["tag_dengji_node"]:setVisible(false)
        self:createParticalEff(self._rootnode["tag_dengji_node"], false)
    else
        self._rootnode["tag_dengji_node"]:setVisible(true)

        if game.player:getDengjilibao() > 0 then
            self._rootnode["dengji_notice"]:setVisible(true)
            self._rootnode["dengji_num"]:setString(game.player:getDengjilibao())
            self:createParticalEff(self._rootnode["tag_dengji_node"], true)
        else
            self._rootnode["dengji_notice"]:setVisible(false)
            self:createParticalEff(self._rootnode["tag_dengji_node"], false)
        end
    end
end

-- 检测开服礼包奖励
function MainMenuScene:checkKaifuReward()
    if not game.player.m_isShowKaifuLibao then
        self._rootnode["tag_kaifu_node"]:setVisible(false)
        self:createNoticeFadeEff(self._rootnode["kaifu_eff"], false)
    else
        self._rootnode["tag_kaifu_node"]:setVisible(true)

        if game.player:getKaifuLibao() > 0 then
            self._rootnode["kaifu_notice"]:setVisible(true)
            self._rootnode["kaifu_num"]:setString(game.player:getKaifuLibao())
            self:createNoticeFadeEff(self._rootnode["kaifu_eff"], true)
        else
            self._rootnode["kaifu_notice"]:setVisible(false)
            self:createNoticeFadeEff(self._rootnode["kaifu_eff"], false)
        end
    end
end

function MainMenuScene:createNormalNoticeEff(effNode, isShow)
    if isShow then
        effNode:setVisible(true)
        local delayTime = 3
        effNode:runAction(
            CCRepeatForever:create(
                transition.sequence {
                    -- CCCallFuncN:create(function(node) node:setVisible(true) end),
                    CCRotateBy:create(4, 360 * 0.4)
                    -- CCCallFuncN:create(function(node) node:setVisible(false) end),
                    -- cc.DelayTime:create(delayTime)
                }
            )
        )
    else
        effNode:setVisible(false)
        effNode:stopAllActions()
    end
end

function MainMenuScene:createParticalEff(effNode, isShow)
    effNode:stopAllActions()
    effNode:setRotation(0)

    if isShow then
        local function addParticel(node)
            local particle = CCParticleSystemQuad:create("ccs/particle/ui/p_zaixianlibao.plist")
            particle:setPosition(node:getContentSize().width / 2, node:getContentSize().height * 0.7)
            node:addChild(particle)
        end

        local rotateSeq =
            transition.sequence {
            CCRotateTo:create(0.05, 10),
            CCRotateTo:create(0.05, 0),
            CCRotateTo:create(0.05, -10),
            CCRotateTo:create(0.05, 0)
        }
        local seq =
            transition.sequence {
            rotateSeq,
            rotateSeq,
            rotateSeq,
            rotateSeq,
            cc.DelayTime:create(3)
        }

        local spawn = cc.Spawn:create(seq, CCCallFuncN:create(addParticel))

        effNode:runAction(CCRepeatForever:create(spawn))
    end
end

function MainMenuScene:createNoticeFadeEff(effNode, isShow)
    if isShow then
        effNode:setVisible(true)
        local delayTime = 3
        local fadeSeq =
            transition.sequence {
            CCFadeTo:create(0.5, 100),
            CCFadeTo:create(0.5, 255)
        }
        effNode:runAction(
            CCRepeatForever:create(
                transition.sequence {
                    fadeSeq,
                    fadeSeq,
                    fadeSeq
                }
            )
        )
    else
        effNode:setVisible(false)
        effNode:stopAllActions()
    end
end

function MainMenuScene:refreshLabel()
    if checkint(self._goldLabel:getString()) ~= game.player:getGold() then
        self._goldLabel:runAction(
            transition.sequence(
                {
                    cc.ScaleTo:create(0.2, 1.5),
                    cc.CallFunc:create(
                        function()
                            self._goldLabel:setString(tostring(game.player:getGold()))
                        end
                    ),
                    cc.ScaleTo:create(0.2, 1)
                }
            )
        )
    end

    if checkint(self._silverLabel:getString()) ~= game.player:getSilver() then
        self._silverLabel:runAction(
            transition.sequence(
                {
                    cc.ScaleTo:create(0.2, 1.5),
                    cc.CallFunc:create(
                        function()
                            self._silverLabel:setString(tostring(game.player:getSilver()))
                        end
                    ),
                    cc.ScaleTo:create(0.2, 1)
                }
            )
        )
    end
end

function MainMenuScene:BlackLayerFadeIn()
    print("BlackLayer FadeIn")
    transition.fadeTo(self.blackLayer, {time = 0.5, opacity = 100})
end

function MainMenuScene:BlackLayerFadeOut()
    print("BlackLayer FadeOut")
    transition.fadeTo(self.blackLayer, {time = 0.5, opacity = 0})
end

--
-- 位于屏幕下方，倒数第2行的按钮
-- 侠客， 装备， 经脉， 好友， 聊天， 设置
--
function MainMenuScene:bottomBtns_2(posY)
    local proxy = CCBProxy:create()
    self._rootnode = self._rootnode or {}

    local node = CCBReaderLoad("ccbi/mainmenu/bottom_icons.ccbi", proxy, self._rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    layer:setPosition(display.width / 2, posY)
    self:addChild(layer)

    -- 更多功能相关
    --@RefType luaIde#cc.MenuItemImage
    local moreFuncBtn = self._rootnode["moreFunc_btn"]
    --@RefType luaIde#cc.Node
    local moreFuncTouchNode = self._rootnode["moreFunc_touch_node"]
    --@RefType luaIde#cc.Node
    local moreFuncNode = self._rootnode["moreFunc_node"]

    local function checkTouchMoreFuncNode()
        if moreFuncNode:isVisible() then
            moreFuncBtn:unselected()
            moreFuncNode:setVisible(false)
            setTouchEnabled(moreFuncTouchNode, false)
        else
            moreFuncNode:setVisible(true)
            setTouchEnabled(moreFuncTouchNode, true)
            moreFuncBtn:selected()
        end
    end

    addNodeEventListener(
        moreFuncTouchNode,
        cc.Handler.EVENT_TOUCH_BEGAN,
        function(event)
            local posX = event:getLocation().x
            local posY = event:getLocation().y
            return true
        end
    )
    -- moreFuncTouchNode:addNodeEventListener(
    --     cc.NODE_TOUCH_CAPTURE_EVENT,
    --     function(event)
    --         local posX = event.x
    --         local posY = event.y
    --         local pos = moreFuncNode:convertToNodeSpace(ccp(posX, posY))
    --         if cc.rect(0, 0, moreFuncNode:getContentSize().width, moreFuncNode:getContentSize().height):containsPoint(pos) == false then
    --             checkTouchMoreFuncNode()
    --         end
    --     end
    -- )

    moreFuncBtn:onClicked(
        function(tag)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            checkTouchMoreFuncNode()
        end
    )

    local tagNames = {
        "tag_shezhi",
        "tag_zhenqi",
        "tag_lianhualu",
        "tag_zhuangbei",
        "tag_xiake",
        "tag_tiaozhan",
        "tag_jingmai",
        "tag_liaotian",
        "tag_jianghulu",
        "tag_pet",
        "tag_bangpai",
        "tag_mail_bottom",
        "tag_friend",
        "tag_gonggao",
        "tag_rank_list"
    }

    local tips = display.newSprite("#toplayer_mail_tip.png")
    tips:setPosition(self._rootnode["tag_gonggao"]:getContentSize().width * 0.9, self._rootnode["tag_gonggao"]:getContentSize().height * 0.9)
    self._rootnode["tag_gonggao"]:addChild(tips)
    -- touch 事件
    local function onTouch(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        -- 设置
        if (tag == tagNames[1]) then
            -- 真气（精元）
            -- GameStateManager:ChangeState(GAME_STATE.STATE_SETTING)

            if self:getChildByTag(HUODONG_TAG) == nil then
                local settingLayer = require("game.Setting.SettingLayer").new()
                self:addChild(settingLayer, HUODONG_ZORDER, HUODONG_TAG)
            end
        elseif (tag == tagNames[2]) then
            -- 炼化炉
            --            show_tip_label(data_error_error[2800001].prompt)
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
        elseif (tag == tagNames[3]) then
            -- 装备
            GameStateManager:ChangeState(GAME_STATE.STATE_LIANHUALU)
        elseif (tag == tagNames[4]) then
            -- 侠客
            GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
        elseif (tag == tagNames[5]) then
            -- 挑战
            GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
        elseif (tag == tagNames[6]) then
            -- 经脉
            GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN)
        elseif (tag == tagNames[7]) then
            -- 聊天
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGMAI)
        elseif (tag == tagNames[8]) then
            -- 群侠录
            if self:getChildByTag(HUODONG_TAG) == nil then
                RewardLayerMgr.createLayerByType(RewardLayerMgrType.chat, self, HUODONG_ZORDER, HUODONG_TAG)
            end
        elseif tag == tagNames[9] then
            -- 邮件
            GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
        elseif (tag == tagNames[12]) then
            --        elseif (tag == "tag_kezhan") then
            --            GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.KeZhan)
            GameStateManager:ChangeState(GAME_STATE.STATE_MAIL)
        elseif tag == "tag_pet" then
            if (CSDKShell.SDK_TYPE == CSDKShell.SDKTYPES.IOS_APPSTORE_HANS) then
                CSDKShell.openAdvertisement()
            else
                show_tip_label(data_error_error[2800001].prompt)
            end
        elseif tag == "tag_friend" then
            --一点这个 清除所在状态
            -- GameModel.friendActive = 0
            GameStateManager:ChangeState(GAME_STATE.STATE_FRIENDS)
        elseif tag == "tag_bangpai" then
            -- 公告
            if ENABLE_GUILD == true then
                GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
            else
                show_tip_label(data_error_error[2800001].prompt)
            end
        elseif (tag == "tag_gonggao") then
            RequestHelper.getNotice(
                {
                    callback = function(data)
                        -- dump(data)
                        tips:setVisible(false)
                        game.player.m_gamenote = data.rtnObj
                        local noteLayer = require("game.Huodong.GameNote").new()
                        self:addChild(noteLayer, HUODONG_ZORDER, HUODONG_TAG)
                    end
                }
            )
        elseif (tag == "tag_rank_list") then
            ResMgr.runFuncByOpenCheck(
                {
                    openKey = OPENCHECK_TYPE.RANK_LIST,
                    openFunc = function()
                        GameStateManager:ChangeState(GAME_STATE.STATE_RANK_SCENE)
                    end
                }
            )
        end
    end

    for i, v in ipairs(tagNames) do
        local btn = self._rootnode[tagNames[i]]
        if tagNames[i] == "tag_xiake" then
            TutoMgr.addBtn("zhujiemian_xiake_btn", btn)
        end
        if tagNames[i] == "tag_tiaozhan" then
            TutoMgr.addBtn("zhujiemian_tiaozhan_btn", btn)
        end

        if tagNames[i] == "tag_lianhualu" then
            TutoMgr.addBtn("zhujiemian_lianhualu", btn)
        end

        if tagNames[i] == "tag_jingmai" then
            TutoMgr.addBtn("zhujiemian_jingmai", btn)
        end

        btn:registerControlEventHandler(
            function(eventName, sender)
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                onTouch(v)
            end,
            CCControlEventTouchUpInside
        )
    end

    self:initPlayerBoard()
    self:initTopFrame()
end

function MainMenuScene:testData(...)
    for k, v in pairs(data_card_card) do
        local path = "hero/icon/" .. v.arr_icon[1] .. ".png"
        if (io.exists(path) == false) then
            print(path)
        end
    end
end

function MainMenuScene:initTopFrame(...)
    local proxy = CCBProxy:create()
    local ccbReader = proxy:createCCBReader()
    -- local rootnode = rootnode or {}
    self._rootnode = self._rootnode or {}

    local node = CCBReaderLoad("ccbi/mainmenu/top_icons.ccbi", proxy, self._rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    layer:setPosition(0, self.topFrame:getPositionY() - 30)
    self.topFrame:addChild(layer)

    local tagNames = {
        "tag_chengzhangzhilu",
        "tag_dengji",
        "tag_shouchong",
        "tag_jingcai",
        "tag_qiandao",
        "tag_lingjiang",
        "tag_zaixian",
        "tag_mail",
        "tag_kaifu",
        "tag_guildboss"
    }

    self:createNoticeFadeEff(self._rootnode["jingcai_eff"], true)
    -- touch 事件
    local function onTouch(tag)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        -- 成长之路
        if (tag == tagNames[1]) then
            -- 等级礼包
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DailyTask, game.player:getLevel(), game.player:getVip())
            if not bHasOpen then
                show_tip_label(prompt)
            else
                if self:getChildByTag(HUODONG_TAG) == nil then
                    RewardLayerMgr.createLayerByType(RewardLayerMgrType.dailyTask, self, HUODONG_ZORDER, HUODONG_TAG)
                end
            end
        elseif (tag == tagNames[2]) then
            -- 首冲3倍
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.DengJiLiBao, game.player:getLevel(), game.player:getVip())
            if not bHasOpen then
                show_tip_label(prompt)
            else
                if self:getChildByTag(HUODONG_TAG) == nil then
                    RewardLayerMgr.createLayerByType(RewardLayerMgrType.levelReward, self, HUODONG_ZORDER, HUODONG_TAG)
                end
            end
        elseif (tag == tagNames[3]) then
            -- 精彩活动
            if self:getChildByTag(HUODONG_TAG) == nil then
                local chongzhiLayer = require("game.shop.Chongzhi.ChongzhiLayer").new()
                self:addChild(chongzhiLayer, HUODONG_ZORDER, HUODONG_TAG)
            end
        elseif (tag == tagNames[4]) then
            -- 签到
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG)
        elseif (tag == tagNames[5]) then
            -- 领奖中心
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.QianDao, game.player:getLevel(), game.player:getVip())
            if not bHasOpen then
                show_tip_label(prompt)
            else
                if self:getChildByTag(HUODONG_TAG) == nil then
                    RewardLayerMgr.createLayerByType(RewardLayerMgrType.dailyLogin, self, HUODONG_ZORDER, HUODONG_TAG)
                end
            end
        elseif (tag == tagNames[6]) then
            -- 在线领奖
            if self:getChildByTag(HUODONG_TAG) == nil then
                RewardLayerMgr.createLayerByType(RewardLayerMgrType.rewardCenter, self, HUODONG_ZORDER, HUODONG_TAG)
            end
        elseif (tag == tagNames[7]) then
            -- 邮件
            if self:getChildByTag(HUODONG_TAG) == nil then
                RewardLayerMgr.createLayerByType(RewardLayerMgrType.onlineReward, self, HUODONG_ZORDER, HUODONG_TAG)
            end
        elseif (tag == tagNames[8]) then
            -- 开服礼包
            GameStateManager:ChangeState(GAME_STATE.STATE_MAIL)
        elseif (tag == tagNames[9]) then
            -- 青龙boss
            if self:getChildByTag(HUODONG_TAG) == nil then
                RewardLayerMgr.createLayerByType(RewardLayerMgrType.kaifuReward, self, HUODONG_ZORDER, HUODONG_TAG)
            end
        elseif (tag == "tag_guildboss") then
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, false)
        end
    end

    for i, v in ipairs(tagNames) do
        local btn = self._rootnode[tagNames[i]]
        if i == 5 then
            TutoMgr.addBtn("main_scene_qiandao_btn", btn)
        end
        btn:registerControlEventHandler(
            function(eventName, sender)
                onTouch(v)
            end,
            CCControlEventTouchUpInside
        )
    end
end

function MainMenuScene:refreshPlayerBoard(...)
    self.playerInfoNode["tag_lv"]:setString(game.player.m_level)
    -- vip
    self.playerInfoNode["label_vip"]:setString(game.player.m_vip)

    -- silver
    self.playerInfoNode["label_silver"]:setString(game.player.m_silver)

    -- gold
    self.playerInfoNode["label_gold"]:setString(game.player.m_gold)

    -- battle point
    self.playerInfoNode["label_zhanli"]:setString(game.player.m_battlepoint)

    self.playerInfoNode["label_tili"]:setString(game.player.m_strength .. "/" .. game.player.m_maxStrength)
    self.playerInfoNode["label_naili"]:setString(game.player.m_energy .. "/" .. game.player.m_maxEnergy)
    self.playerInfoNode["label_exp"]:setString(game.player.m_exp .. "/" .. game.player.m_maxExp)

    local function refreshBar(...)
        local percent = game.player.m_strength / game.player.m_maxStrength
        if (percent > 1) then
            percent = 1
        end
        local barWidth = self.playerInfoNode["tag_tili"]:getContentSize().width
        local bar = self.playerInfoNode["tag_tili_bar"]
        bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, barWidth * percent, bar:getTextureRect().height))

        percent = game.player.m_energy / game.player.m_maxEnergy
        if (percent > 1) then
            percent = 1
        end
        local bar = self.playerInfoNode["tag_naili_bar"]
        bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, barWidth * percent, bar:getTextureRect().height))

        percent = game.player.m_exp / game.player.m_maxExp
        if (percent > 1) then
            percent = 1
        end
        local bar = self.playerInfoNode["tag_exp_bar"]
        bar:setTextureRect(cc.rect(bar:getTextureRect().x, bar:getTextureRect().y, barWidth * percent, bar:getTextureRect().height))
        -- dump("===============")
    end
    refreshBar()
end
--
-- 初始化玩家信息
--
function MainMenuScene:initPlayerBoard(...)
    -- player head icon
    local headImgName = game.player:getPlayerIconName()
    --@RefType luaIde#cc.Sprite
    local playerHead = self.playerInfoNode["head_icon"]
    playerHead:setSpriteFrame(display.newSpriteFrame(headImgName))
    addNodeEventListener(
        playerHead,
        cc.Handler.EVENT_TOUCH_BEGAN,
        function()
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            local cb = function(...)
                setTouchEnabled(playerHead, true)
            end
            self:showPlayerInfo(cb)
            setTouchEnabled(playerHead, false)
        end
    )

    -- level
    self.playerInfoNode["tag_lv"]:setString(game.player.m_level)

    -- name
    -- local text =
    --     newTTFLabelWithOutline(
    --     {
    --         text = game.player.m_name,
    --         x = 5,
    --         y = self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:getContentSize().height * 0.78,
    --         font = FONTS_NAME.font_fzcy,
    --         size = 20,
    --         color = FONT_COLOR.PLAYER_NAME,
    --         outlineColor = ccc3(0, 0, 0),
    --         align = cc.TEXT_ALIGNMENT_LEFT
    --     }
    -- )
    local ttfConfig = {}
    ttfConfig.fontFilePath = FONTS_NAME.font_fzcy
    ttfConfig.fontSize = 20
    ttfConfig.outlineSize = 1

    --@RefType luaIde#cc.Label
    local text = cc.Label:createWithTTF(ttfConfig, game.player.m_name, cc.TEXT_ALIGNMENT_LEFT)
    text:setPosition(60, self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:getContentSize().height * 0.78)
    text:setTextColor(FONT_COLOR.PLAYER_NAME)
    text:enableOutline(cc.c3b(0, 0, 0))
    self.playerInfoNode[CCB_PLAYER_INFO.mm_name]:addChild(text)

    self:refreshPlayerBoard()
end

--[[
    显示玩家信息
]]
function MainMenuScene:showPlayerInfo(cb)
    local playerInfoLayer = require("game.scenes.PlayerInfoLayer").new(self.playerInfoNode, cb)
    self:addChild(playerInfoLayer)
end

function MainMenuScene:onExit()
    if game.urgencyBroadcast:getIsHasShow() then
        game.urgencyBroadcast:setIsShow(false)
    end

    -- CSDKShell.HideToolbar()

    UnRegNotice(self, NoticeKey.MainMenuScene_Update)

    UnRegNotice(self, NoticeKey.MAINSCENE_HIDE_BOTTOM_LAYER)
    UnRegNotice(self, NoticeKey.MAINSCENE_SHOW_BOTTOM_LAYER)

    UnRegNotice(self, NoticeKey.MainMenuScene_OnlineReward)
    UnRegNotice(self, NoticeKey.MainMenuScene_RewardCenter)
    UnRegNotice(self, NoticeKey.MainMenuScene_Qiandao)
    UnRegNotice(self, NoticeKey.MainMenuScene_DengjiLibao)
    UnRegNotice(self, NoticeKey.MainMenuScene_KaifuLibao)
    UnRegNotice(self, NoticeKey.MainMenuScene_chatNewNum)
    UnRegNotice(self, NoticeKey.MainMenuScene_challenge)

    UnRegNotice(self, NoticeKey.MainMenuScene_ChengZhangZhilu)
    UnRegNotice(self, NoticeKey.MainMenuScene_Music)
    UnRegNotice(self, NoticeKey.MainMenuScene_UrgencyBroadcast)
    UnRegNotice(self, NoticeKey.MainMenuScene_Shouchong)
    UnRegNotice(self, NoticeKey.MAIL_TIP_UPDATE)

    UnRegNotice(self, NoticeKey.UP_FRIEND_ICON_ACT)

    UnRegNotice(self, NoticeKey.CHECK_GUILD_APPLY_NUM)

    -- self.scheduler.unscheduleGlobal(self.schedulerUpdateTimeLabel)
    -- self.scheduler.unscheduleGlobal(self.schedulerUnread)

    TutoMgr.removeBtn("zhujiemian_xiake_btn")
    TutoMgr.removeBtn("zhujiemian_tiaozhan_btn")
    TutoMgr.removeBtn("main_scene_qiandao_btn")
    TutoMgr.removeBtn("zhujiemian_lianhualu")
    TutoMgr.removeBtn("zhujiemian_jingmai")

    display.removeSpriteFrames("ui/ui_main_menu.plist", "ui/ui_main_menu.pvr.ccz")
    display.removeSpriteFrames("ui/ui_mm_day.plist", "ui/ui_mm_day.pvr.ccz")
    display.removeSpriteFrames("ui/ui_mm_night.plist", "ui/ui_mm_night.pvr.ccz")
    display.removeSpriteFrames("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
    display.removeSpriteFrames("ui/ui_bottom2.plist", "ui/ui_bottom2.pvr.ccz")
    display.removeSpriteFrames("ui/ui_gamenote.plist", "ui/ui_gamenote.png")
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    -- CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(self, "APP_ENTER_FOREGROUND_EVENT_IN_GAME")
end

function MainMenuScene:UpdateQuickAccess(...)
    display.loadSpriteFrames("2015_03_03.plist", "2015_03_03.png")

    local function onBtn(tag)
        if tag == QuickAccess.SLEEP then
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.KeZhan)
        elseif tag == QuickAccess.BOSS then
            GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
        elseif tag == QuickAccess.LIMITCARD then
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.LimitHero)
        elseif tag == QuickAccess.GUILD_BOSS then
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_QL_BOSS, false)
        elseif tag == QuickAccess.GUILD_BBQ then
            GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
        elseif tag == QuickAccess.TANBAO then
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGCAI_HUODONG, nbActivityShowType.huanggongTanBao)
        end
    end

    self._rootnode["quickAccessNode"]:removeAllChildren(true)
    local menus = {}
    for k, v in pairs(game.player.m_quickAccessState) do
        local canShow = true
        if k == QuickAccess.SLEEP and game.player:getAppOpenData().kezhan == APPOPEN_STATE.close then
            canShow = false
        end

        if canShow == true then
            if v and v == 1 then
                local item =
                    ui.newImageMenuItem(
                    {
                        image = string.format("#2015_03_03_%d.png", k),
                        imageSelected = string.format("#2015_03_03_%d.png", k),
                        listener = c_func(onBtn, k)
                    }
                )
                table.insert(menus, item)
            end
        end
    end
    local menu = ui.newMenu(menus)
    menu:alignItemsHorizontally()
    self._rootnode["quickAccessNode"]:addChild(menu)
end

return MainMenuScene
