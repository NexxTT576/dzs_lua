local COMMON_VIEW = 1
local SALE_VIEW = 2

display.loadSpriteFrames("ui/ui_submap.plist", "ui/ui_submap.png")
local HeroListCell =
    class(
    "HeroListCell",
    function(param)
        return CCTableViewCell:new()
    end
)

function HeroListCell:getContentSize()
    return cc.size(display.width, 154) --sprite:getContentSize()
end

function HeroListCell:getJinjieBtn()
    return self._rootnode["jinjieBtn"]
end

function HeroListCell:getHeadIcon()
    return self._rootnode["headIcon"]
end

function HeroListCell:create(param)
    local changeSoldMoney = param.changeSoldMoney

    local addSellItem = param.addSellItem
    local removeSellItem = param.removeSellItem

    self.choseTable = param.choseTable

    -- display.loadSpriteFrames("icon/icon_hero.plist", "icon/icon_hero.png")

    local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBReaderLoad("hero/hero_list_item.ccbi", proxy, self._rootnode)
    node:setPosition(display.width * 0.5, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    self.cellIndex = param.id
    self.createJinJieLayer = param.createJinjieListenr
    self.createQiangHuaLayer = param.createQiangHuaListener

    self.bg = self._rootnode["itemBg"]
    --display.newSprite("#herolist_board.png")

    self.list = param.listData
    self.saleList = param.saleData

    self.headIcon = self._rootnode["headIcon"]
    self.clsTTF = self._rootnode["cls"]

    -- MppUI.refreshShadowLabel({
    -- 	text = "0",
    --        size = 20,
    --        color = cc.c3b(85,210,68),
    --        shadowColor = cc.c3b(0,0,0),
    --        font = FONTS_NAME.font_fzcy,
    --        align = cc.TEXT_ALIGNMENT_LEFT,
    --        label = self.clsTTF
    -- 	})

    -- self.heroName:setPosition(self.heroName:getContentSize().width/2,self._rootnode["nameBg"]:getContentSize().height*0.5)

    setTouchEnabled(self._rootnode["touchNode"], true)
    local bTouch = false
    local offsetX = 0
    addNodeEventListener(
        self._rootnode["touchNode"],
        cc.Handler.EVENT_TOUCH_BEGAN,
        function(t)
            bTouch = true
            offsetX = t:getLocation().x
            return true
        end
    )
    addNodeEventListener(
        self._rootnode["touchNode"],
        cc.Handler.EVENT_TOUCH_MOVED,
        function(t)
            if event.x - offsetX > 5 or event.x - offsetX < -5 then
                bTouch = false
            end
        end
    )
    addNodeEventListener(
        self._rootnode["touchNode"],
        cc.Handler.EVENT_TOUCH_ENDED,
        function(t)
            if bTouch then
                -- ResMgr.createMaskLayer()
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                param.onHeadIcon(self.index)
            end
        end
    )

    self.heroName =
        newTTFLabelWithShadow(
        {
            text = "",
            font = FONTS_NAME.font_fzcy,
            x = 0,
            --self._rootnode["nameBg"]:getContentSize().width/2 + self.headIcon:getContentSize().width+30,
            y = self._rootnode["nameBg"]:getContentSize().height * 0.5,
            size = 22,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )
    self.heroName:setPosition(self.heroName:getContentSize().width / 2, self._rootnode["nameBg"]:getContentSize().height * 0.5)
    self._rootnode["nameBg"]:addChild(self.heroName)

    self.heroCls =
        newTTFLabelWithShadow(
        {
            text = "0",
            size = 20,
            color = cc.c3b(85, 210, 68),
            shadowColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_fzcy,
            align = cc.TEXT_ALIGNMENT_LEFT
        }
    )

    self._rootnode["nameBg"]:addChild(self.heroCls)

    self.lv = self._rootnode["lvNum"]

    ResMgr.setControlBtnEvent(
        self._rootnode["jinjieBtn"],
        function()
            local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.XiaKe_JinJie, game.player:getLevel(), game.player:getVip())
            if not bHasOpen then
                show_tip_label(prompt)
            else
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                self.createJinJieLayer(self.objId, self.index)
            end
        end
    )

    ResMgr.setControlBtnEvent(
        self._rootnode["qianghuaBtn"],
        function()
            if self.lvl < game.player.m_level then --不能超过主角等级
                self.createQiangHuaLayer(self.objId, self.index)
            else
                show_tip_label("侠客等级不能超过主角等级")
            end
        end
    )

    self.selBtn = self._rootnode["unSelIcon"]
    self.unseleBtn = self._rootnode["selIcon"]
    local function selFunc()
        self.selBtn:setVisible(false)
        self.unseleBtn:setVisible(true)
        changeSoldMoney(self.price)
        addSellItem(self.objId, self.index)
    end

    local function unSelFunc()
        self.selBtn:setVisible(true)
        self.unseleBtn:setVisible(false)
        changeSoldMoney(0 - self.price)
        removeSellItem(self.objId, self.index)
    end

    self.selBtn:registerScriptTapHandler(
        function()
            selFunc()
        end
    )

    self.unseleBtn:registerScriptTapHandler(
        function()
            unSelFunc()
        end
    )

    self:refresh(self.cellIndex, param.viewType)
    return self
end

function HeroListCell:setStars(num)
    for i = 1, 5 do
        if i > num then
            self._rootnode["star" .. i]:setVisible(false)
        else
            self._rootnode["star" .. i]:setVisible(true)
        end
    end
end

function HeroListCell:beTouched()
    print(self.cellIndex)
end

function HeroListCell:onExit()
    -- display.removeSpriteFrames("ui/ui_submap.plist", "ui/ui_submap.png")
end

function HeroListCell:refresh(id, viewType, isSel)
    local curList = nil
    if viewType == COMMON_VIEW then
        curList = HeroModel.totalTable
        self._rootnode["commonNode"]:setVisible(true)
        self._rootnode["sellNode"]:setVisible(false)
    else
        self._rootnode["commonNode"]:setVisible(false)
        self._rootnode["sellNode"]:setVisible(true)
        curList = HeroModel.sellAbleData
    end
    -- dump(self.list)
    self.index = id + 1
    self.cellData = curList[id + 1]
    self.objId = self.cellData["id"]

    if self.cellData["lock"] ~= 1 then
        self._rootnode["lock_icon"]:setVisible(false)
    else
        self._rootnode["lock_icon"]:setVisible(true)
    end

    self.resID = self.cellData["resId"]
    local curCardData = ResMgr.getCardData(self.resID)

    --卡牌阶级
    do
        self.cls = self.cellData["cls"]
        self.clsTTF:setString("")
        if self.cls == 0 then
            self.heroCls:setString("")
        else
            -- self.clsTTF:setString()
            self.heroCls:setString("+" .. self.cls)
        end
        --人物级别
        self.lvl = self.cellData["level"]
        ResMgr.showAlert(self.lvl, "level is null,objId:" .. tostring(self.objId))
        if (self.lvl ~= nil) then
            self.lv:setString("LV." .. self.lvl)
        end

        --资质为多少
        local zizhiData = curCardData["arr_zizhi"]
        if zizhiData ~= nil then
            local zizhiValue = zizhiData[self.cls + 1]
            self._rootnode["zizhi"]:removeAllChildren()
            --@RefType luaIde#cc.Label
            local heroZizhi =
                newTTFLabelWithShadow(
                {
                    text = "资质:" .. zizhiValue,
                    font = FONTS_NAME.font_fzcy,
                    shadowColor = cc.c3b(0, 0, 0),
                    size = 20,
                    align = cc.TEXT_ALIGNMENT_LEFT
                }
            )
            heroZizhi:setAnchorPoint(cc.p(0, 0.5))
            heroZizhi:setPosition(10, self._rootnode["zizhi"]:getContentSize().height / 2)
            self._rootnode["zizhi"]:addChild(heroZizhi)
        end

        --是什么职业
        local job = curCardData["job"]
        ResMgr.refreshJobIcon(self._rootnode["job_icon"], job)

        --人物名称
        local nameStr = curCardData["name"]
        if self.resID == 1 or self.resID == 2 then
            nameStr = game.player.m_name
        end
        self.heroName:setString(nameStr)
        self.heroName:setPosition(self.heroName:getContentSize().width / 2 + 20, self._rootnode["nameBg"]:getContentSize().height * 0.5)
        self.heroCls:setContentSize(self.heroCls:getContentSize())
        self.heroCls:setAnchorPoint(cc.p(0, 1))
        self.heroCls:setPosition(self.heroName:getPositionX() + self.heroName:getContentSize().width / 2 + 10, self.heroName:getPositionY() + self.heroName:getContentSize().height / 2)

        self.price = curCardData["price"]
        self._rootnode["price"]:setString(self.price)

        --是否可进阶
        if curCardData["advance"] == 1 then
            self._rootnode["jinjieBtn"]:setVisible(true)
        else
            self._rootnode["jinjieBtn"]:setVisible(false)
        end

        -- if nameStr == "女主角" then
        -- 	print("ddd"..self.resID)
        -- end

        if self.resID == 1 or self.resID == 2 then
            self._rootnode["qianghuaBtn"]:setVisible(false)
        else
            self._rootnode["qianghuaBtn"]:setVisible(true)
        end
        -- print("cellData")
        -- dump(self.cellData)
        --是否有情缘
        self.isQingyuan = #self.cellData["relation"]
        if self.isQingyuan ~= 0 then
            self._rootnode["qingyuanIcon"]:setVisible(true)
        else
            self._rootnode["qingyuanIcon"]:setVisible(false)
        end

        --是否上阵
        self.pos = self.cellData["pos"]
        if self.pos ~= 0 then
            self._rootnode["shangzhenIcon"]:setVisible(true)
            --在显示上阵icon的同时 一定要隐藏情缘
            self._rootnode["qingyuanIcon"]:setVisible(false)
        else
            self._rootnode["shangzhenIcon"]:setVisible(false)
        end

        --是否是主角

        --人物星级
        self.starsNum = self.cellData["star"]
        self:setStars(self.starsNum)

        self.heroName:setColor(NAME_COLOR[self.starsNum])

        ResMgr.refreshIcon({id = self.resID, itemBg = self.headIcon, resType = ResMgr.HERO, cls = self.cls})

        if isSel == true then
            self._rootnode["unSelIcon"]:setVisible(false)
            self._rootnode["selIcon"]:setVisible(true)
        else
            self._rootnode["selIcon"]:setVisible(false)
            self._rootnode["unSelIcon"]:setVisible(true)
        end
    end
end

function HeroListCell:runEnterAnim()
    local delayTime = self.cellIndex * 0.15
    local sequence =
        transition.sequence(
        {
            CCCallFuncN:create(
                function()
                    self:setPosition(CCPoint((self:getContentSize().width / 2 + display.width / 2), self:getPositionY()))
                end
            ),
            cc.DelayTime:create(delayTime),
            CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width / 2 + display.width / 2), 0))
        }
    )
    self:runAction(sequence)
end

return HeroListCell
