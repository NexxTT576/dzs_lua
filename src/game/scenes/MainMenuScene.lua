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
    ccs.ArmatureDataManager:getInstance()
    ccs.ArmatureDataManager:destroyInstance()
    self:enableNodeEvents()
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
    --@TODO 2020-05-13 23:36:52 先做个记号
end
--[[
    @desc: 位于屏幕下方，倒数第2行的按钮
    侠客， 装备， 经脉， 好友， 聊天， 设置
    author:tulilu
    time:2020-05-13 23:31:33
    --@posY: 
    @return:
]]
function MainMenuScene:bottomBtns_2(posY)
    local proxy = CCBProxy:create()
    self._rootnode = self._rootnode or {}
    local node = CCBReaderLoad("ccbi/mainmenu/bottom_icons.ccbi", proxy, self._rootnode)
    local layer = tolua.cast(node, "cc.Layer")
    layer:setPosition(display.width / 2, posY)
    self:addChild(layer)
    local moreFuncBtn = self._rootnode["moreFunc_btn"]
    local moreFuncTouchNode = self._rootnode["moreFunc_touch_node"]
    local moreFuncNode = self._rootnode["moreFunc_node"]
end

return MainMenuScene
