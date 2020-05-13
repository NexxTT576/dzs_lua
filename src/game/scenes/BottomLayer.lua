--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-13 18:40:32
]]
--@SuperType ViewBase
local BottomLayer = class("BottomLayer", cc.load("mvc").ViewBase)
function BottomLayer:onCreate()
    self:enableNodeEvents()
    display.loadSpriteFrames("ui/ui_bottom_layer.plist", "ui/ui_bottom_layer.pvr.ccz")
    local showbg = showbg or true
    if (showbg == true) then
        self.bottomBg = display.newSprite("#bl_bottom_bg.png", {scale9 = true})
        self.bottomBg:setPreferredSize(cc.size(display.width, self.bottomBg:getContentSize().height))
        self.bottomBg:setPosition(display.width / 2, self.bottomBg:getContentSize().height * 0.5)
        self:addChild(self.bottomBg)
    end

    self:initBottomFrame()

    self.bottomFrame = display.newSprite("#bl_bottom_layer.png", {scale9 = true})
    self.bottomFrame:setPreferredSize(cc.size(display.width, self.bottomFrame:getContentSize().height))
    self.bottomFrame:setPosition(display.width / 2, self.bottomFrame:getContentSize().height / 2)
    self:addChild(self.bottomFrame)
end

function BottomLayer:initBottomFrame(...)
    local bottomImage = {
        "#bl_shouye_up.png",
        "#bl_zhenrong_up.png",
        "#bl_fuben_up.png",
        "#bl_huodong_up.png",
        "#bl_beibao_up.png",
        "#bl_shop_up.png"
    }
    local bottomImageDown = {
        "#bl_shouye_down.png",
        "#bl_zhenrong_down.png",
        "#bl_fuben_down.png",
        "#bl_huodong_down.png",
        "#bl_beibao_down.png",
        "#bl_shop_down.png"
    }
    local baseBottomItems = {
        CCB_TAG.mm_shouye,
        CCB_TAG.mm_zhenrong,
        CCB_TAG.mm_fuben,
        CCB_TAG.mm_huodong,
        CCB_TAG.mm_beibao,
        CCB_TAG.mm_shop
    }

    local items = {}
    self.btns = {}
    self.allBtns = items
    for k, v in pairs(bottomImage) do
        --@RefType luaIde#cc.MenuItemSprite
        local btn = cc.MenuItemSprite:create(display.newSprite(bottomImage[k]), display.newSprite(bottomImageDown[k]))
        btn:registerScriptTapHandler(
            function()
                self:postNotice("hello", "ff")
            end
        )
        local menu = cc.Menu:create()
        menu:addChild(btn)
        menu:setPosition(0, 0)
        self.bottomBg:addChild(menu)

        if v == "#bl_zhenrong_up.png" then
            TutoMgr.addBtn("zhujiemian_btn_zhenrong", btn)
        end

        if v == "#bl_shop_up.png" then
            TutoMgr.addBtn("zhujiemian_btn_shangcheng", btn)
        end

        if v == "#bl_fuben_up.png" then
            TutoMgr.addBtn("zhenrong_btn_fuben", btn)
        end

        if v == "#bl_huodong_up.png" then
            TutoMgr.addBtn("zhujiemian_btn_huodong", btn)
        end

        self.btns[#self.btns + 1] = btn
        btn:setPosition(1 + (k - 1) * self.bottomBg:getContentSize().width / (#bottomImage) + btn:getContentSize().width / 2, btn:getContentSize().height * 0.5 + 9)

        if k == #bottomImage then
            display.loadSpriteFrames("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
            self._shopBtnNotice = display.newSprite("#toplayer_mail_tip.png")
            self._shopBtnNotice:setAnchorPoint(cc.p(1, 1))
            self._shopBtnNotice:setPosition(btn:getContentSize().width, btn:getContentSize().height)
            self._shopBtnNotice:setVisible(false)
            btn:addChild(self._shopBtnNotice, 100)
        end
    end

    for k, v in pairs(G_BOTTOM_BTN) do
        if (self:getApp().currentState == v and self:getApp().currentState > 2) then
            items[k]:selected()
            break
        end
    end
end

-- 刷新商店免费抽卡次数
function BottomLayer:refreshShopNotice()
    if self._shopBtnNotice ~= nil then
        dump(game.player:getChoukaNum())
        if game.player:getChoukaNum() > 0 then
            self._shopBtnNotice:setVisible(true)
        else
            self._shopBtnNotice:setVisible(false)
        end
    end
end

function BottomLayer:onEnter()
    -- TutoMgr.active()
    -- -- 抽卡
    -- RegNotice(
    --     self,
    --     function()
    --         self:refreshShopNotice()
    --     end,
    --     NoticeKey.BottomLayer_Chouka
    -- )
    -- RegNotice(
    --     self,
    --     function()
    --         self:setMenuItemEnabled(false)
    --     end,
    --     NoticeKey.LOCK_BOTTOM
    -- )
    -- RegNotice(
    --     self,
    --     function()
    --         self:setMenuItemEnabled(true)
    --     end,
    --     NoticeKey.UNLOCK_BOTTOM
    -- )
    -- self:refreshShopNotice()
end

function BottomLayer:onExit()
    TutoMgr.removeBtn("zhujiemian_btn_zhenrong")
    TutoMgr.removeBtn("zhujiemian_btn_shangcheng")
    TutoMgr.removeBtn("zhenrong_btn_fuben")
    TutoMgr.removeBtn("zhujiemian_btn_huodong")
    UnRegNotice(self, NoticeKey.BottomLayer_Chouka)
    UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
    UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
end

function BottomLayer:getContentSize(...)
    -- body
    return self.bottomBg:getContentSize()
end

--[[
    游戏底部 按键 event ui跳转
]]
--[[
    @desc: 
    author:tulilu
    time:2020-05-13 20:07:05
    --@tag: 
    @return:
]]
function BottomLayer:onTouchBtn(tag)
    -- gameworks 按钮 点击事件
    SDKGameWorks.GameBtClick(tag)

    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))

    local nextState = 0
    local msg = {}
    if (tag == CCB_TAG.mm_shouye) then
        nextState = GAME_STATE.STATE_MAIN_MENU
    elseif (tag == CCB_TAG.mm_zhenrong) then
        -- 先请求阵容数据，再切换场景
        RequestHelper.formation.list(
            {
                m = "fmt",
                a = "list",
                pos = "0",
                param = {},
                callback = function(data)
                    -- dump(data)
                    game.player.m_formation = data
                    nextState = GAME_STATE.STATE_ZHENRONG
                    GameStateManager:ChangeState(nextState, msg)
                end
            }
        )
    elseif (tag == CCB_TAG.mm_fuben) then
        -- print("boooootttommlllll")
        nextState = GAME_STATE.STATE_FUBEN
    elseif (tag == CCB_TAG.mm_huodong) then
        nextState = GAME_STATE.STATE_HUODONG
    elseif (tag == CCB_TAG.mm_beibao) then
        nextState = GAME_STATE.STATE_BEIBAO
    elseif (tag == CCB_TAG.mm_shop) then
        -- "zhujiemian_btn_shangcheng"
        nextState = GAME_STATE.STATE_SHOP
    end
    for k, v in pairs(G_BOTTOM_BTN) do
        if (GameStateManager.currentState == v and GameStateManager.currentState > 2) then
            self.allBtns[k]:selected()
            break
        end
    end

    if (tag == CCB_TAG.mm_fuben) then
        local bigMapID = nil
        if PageMemoModel.bigMapID ~= 0 then
            bigMapID = PageMemoModel.bigMapID
        end

        -- 请求大地图数据
        RequestHelper.getLevelList(
            {
                id = bigMapID,
                callback = function(data)
                    dump(data)
                    game.player.bigmapData = data
                    msg.bigMapID = game.player.bigmapData["1"]
                    msg.subMapID = game.player.bigmapData["2"]
                    GameStateManager:ChangeState(nextState, msg)
                end
            }
        )
    else
        GameStateManager:ChangeState(nextState, msg)
    end
end
return BottomLayer
