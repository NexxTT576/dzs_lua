--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-14 17:17:10
]]
--@SuperType luaIde#cc.Node
local TutoLayer =
    class(
    "TutoLayer",
    function(data)
        return display.newNode()
    end
)

function TutoLayer:onEnter()
    RegNotice(
        self,
        function()
            self.callBackFunc()
        end,
        NoticeKey.REMOVE_TUTOLAYER
    )

    ResMgr.delayFunc(
        0.3,
        function()
            -- print("rerererererererererer")
            -- ResMgr.intoSubMap = false
            -- PostNotice(NoticeKey.REV_TUTO_MASK)
            ResMgr.removeTutoMask()
        end,
        self
    )
end

function TutoLayer:onExit()
    UnRegNotice(self, NoticeKey.REMOVE_TUTOLAYER)
end

function TutoLayer:ctor(param)
    TutoMgr.lockTable()
    local tuData = param.tuData
    local isMask = param.isMask
    self.unlockFunc = param.unlockFunc
    self:enableNodeEvents()
    --新手引导应该引导哪个btn
    local btn = param.btn
    local callBack = param.func
    local btnSize = btn:getContentSize()
    local btnPosX = btn:getPositionX()
    local btnPosY = btn:getPositionY()
    local btnScale  --= btn:getScale()
    local btnPos = cc.p(btnPosX, btnPosY)

    local btnScaleX = btn:getScaleX()
    local btnScaleY = btn:getScaleY()
    if btnScaleX < btnScaleY then
        btnScale = btnScaleX
    else
        btnScale = btnScaleY
    end

    local sizeX = param.sizeX
    local sizeY = param.sizeY
    if sizeX ~= nil and sizeY ~= nil then
        btnSize = cc.size(sizeX, sizeY)
    end

    self.touchType = param.isTouch

    local delay = (param.delay / 1000) or 0

    local btnCenterPos = cc.p(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
    btnPos = btn:convertToWorldSpace(btnCenterPos)

    btnSize = cc.size(btnSize.width, btnSize.height)

    -- local btnRect
    local clippingNode = cc.ClippingNode:create()

    clippingNode:setContentSize(btnSize)
    -- 创建裁剪模板，裁剪节点将按照这个模板来裁剪区域
    local stencil = cc.DrawNode:create()
    local stencilPos1 = cc.p(btnPos.x - btnSize.width / 2, btnPos.y - btnSize.height / 2)
    local stencilPos2 = cc.p(stencilPos1.x + clippingNode:getContentSize().width, stencilPos1.y + clippingNode:getContentSize().height)
    stencil:drawSolidRect(stencilPos1, stencilPos2, cc.c4f(1, 1, 1, 1))
    stencil:setAnchorPoint(cc.p(0.5, 0.5))
    stencil:setScale(btnScale)

    clippingNode:setStencil(stencil)
    clippingNode:setInverted(true)
    self:addChild(clippingNode)

    self.callBackFunc = function()
    end

    display.loadSpriteFrames("ui/ui_tutorial.plist", "ui/ui_tutorial.png")

    local opacity = tuData.opacity
    if opacity == nil then
        opacity = 170
    end
    local lColor = cc.c4b(0, 0, 0, opacity)
    local isDark = tuData.isDark
    if isDark == 0 then
        lColor = cc.c4b(0, 0, 0, 0)
    end
    --@RefType luaIde#cc.LayerColor
    local pLayer = display.newLayer(lColor)
    clippingNode:addChild(pLayer)
    pLayer:setTouchEnabled(true)

    addNodeEventListener(
        pLayer,
        cc.Handler.EVENT_TOUCH_BEGAN,
        function(event)
            -- 如果在镂空的按钮位置，则让它可点击下面的按钮
            --@RefType luaIde#cc.Rect
            local loKongRect = cc.rect(btnPos.x - btnSize.width / 2, btnPos.y - btnSize.height / 2, btnSize.width, btnSize.height)
            if cc.rectContainsPoint(loKongRect, event:getLocation()) == true then
                if self.touchType == 1 then
                    self.callBackFunc()
                end
                return false
            end
            return true
        end
    )
    local bTouch = false

    local function getAppearAct(times)
        local delayTime = times[1] / 1000
        local appTime = times[2] / 1000

        local delayAct = cc.DelayTime:create(delayTime)
        local appearAct = cc.FadeTo:create(appTime, 255) --transition.fadeTo(node, {opacity = 255, time = appTime})
        local seq = transition.sequence({delayAct, appearAct})

        return seq
    end

    self.baseNode = display.newNode()
    self:addChild(self.baseNode)
    --创建一个指着空白的箭头
    local arrow = display.newSprite("#tuto_arrow.png")

    arrowHeight = arrow:getContentSize().height / 2
    self.arrowNode = display.newNode()

    self.arrowNode:addChild(arrow)

    self.baseNode:addChild(self.arrowNode)

    local arrowDir = param.arrowDir

    local arrowPos = nil
    local movePos = nil

    if arrowDir == 1 then
        --从上向下指
        --不翻转
        --位置向上移
        arrowPos = cc.p(btnPos.x, btnPos.y + btnSize.height / 2 + arrowHeight)
        movePos = cc.p(btnPos.x, btnPos.y + btnSize.height / 2 + 20 + arrowHeight)
    elseif arrowDir == 2 then
        --从下向上指
        arrowPos = cc.p(btnPos.x, btnPos.y - btnSize.height / 2 - arrowHeight)
        movePos = cc.p(btnPos.x, btnPos.y - btnSize.height / 2 - 20 - arrowHeight)
        arrow:setFlippedY(true)
    elseif arrowDir == 3 then
        --从左向右
        arrowPos = cc.p(btnPos.x - btnSize.width / 2 - arrowHeight, btnPos.y)
        movePos = cc.p(btnPos.x - btnSize.width / 2 - 20 - arrowHeight, btnPos.y)
        arrow:setRotation(-90)
    elseif arrowDir == 4 then
        --从右向左
        arrowPos = cc.p(btnPos.x + btnSize.width / 2 + arrowHeight, btnPos.y)
        movePos = cc.p(btnPos.x + btnSize.width / 2 + 20 + arrowHeight, btnPos.y)
        arrow:setRotation(90)
    else
        --默认的
        arrowPos = cc.p(btnPos.x, btnPos.y + btnSize.height / 2 + arrowHeight)
        movePos = cc.p(btnPos.x, btnPos.y + btnSize.height / 2 + 20 + arrowHeight)
    end

    self.arrowNode:setPosition(arrowPos)
    arrow:setOpacity(0)
    -- local fadeAct = getAppearAct(tuData.arrow_appear_time)
    local arrowTimes = tuData.arrow_appear_time
    local delayTime = arrowTimes[1] / 1000
    local appTime = arrowTimes[2] / 1000

    -- print("arrowPos "..arrowPos.x.."/"..arrowPos.y)
    -- print("movePos "..movePos.x.."/"..movePos.y)

    -- print("arrowDir"..arrowDir)
    -- print("appTime "..appTime.."delayTime "..delayTime)
    -- dump(arrowTimes)

    ResMgr.delayFunc(
        delayTime,
        function()
            local arrowRep = cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(0.6, movePos), cc.MoveTo:create(0.4, arrowPos)))
            self.arrowNode:runAction(arrowRep)
            local fadeAct = cc.FadeTo:create(appTime, 255)
            -- local arrowSpawn = CCSpawn:createWithTwoActions(arrowRep,fadeAct)
            arrow:runAction(fadeAct)
        end,
        self.arrowNode
    )

    self:initPos()
    self.posId = param.girlPos or 1
    local flip = true
    local flipSign = -1
    local chatBoxAnchor = 0
    local chatCornerAnchor = 1
    local ttfOffsetX = 25
    if self.posId % 2 == 0 then
        flip = false
        flipSign = 1
        chatBoxAnchor = 1
        chatCornerAnchor = 0
        ttfOffsetX = 15
    end

    if GAME_DEBUG and SHOW_TUTO_SKIP then
        local l = cc.Label:create()
        l:setString("跳过")
        l:setSystemFontSize(46)
        l:setTextColor(FONT_COLOR.GREEN)
        --@RefType luaIde#cc.MenuItemLabel
        self.playBtn = cc.MenuItemLabel:create(l)
        self.playBtn:registerScriptTapHandler(
            function()
                TutoMgr.setServerNum(
                    {
                        setNum = 999999
                    }
                )
                self:getApp():changeState(GAME_STATE.STATE_MAIN_MENU)
            end
        )
        self:addChild(cc.Menu:create(self.playBtn))
    end

    if self.posId ~= 0 then -- 如果pos为0 则证明一没小妹妹 二没对话框
        self.grilNode = display.newNode()
        self.baseNode:addChild(self.grilNode)
        local girlTable = {}

        self.girl = display.newSprite("#tuto_girl.png")
        self.girl:setPosition(self.pos[self.posId])

        girlTable[#girlTable + 1] = self.girl

        self.girl:setFlippedX(flip)
        self.grilNode:addChild(self.girl)
        local girlWidth = self.girl:getContentSize().width
        local girlHeight = self.girl:getContentSize().height
        local girlPosX = self.girl:getPositionX()
        local girlPosY = self.girl:getPositionY()

        local corner_offsetX = 7
        --24
        local chatBox_offsetX = 100
        local chatBox_offsetY = 90

        local tutoStr = param.intro or "我是新手引导小妹妹！"
        local tutoStrLen = (#tostring(tutoStr)) / 3
        local colNum = tutoStrLen / 7 + 1
        if colNum < 3 then
            colNum = 3
        end

        local colHigh = 24
        local chatOffsetY = 40
        local chatWidth = 250
        local chatSize = cc.size(chatWidth, colNum * colHigh + chatOffsetY + 30)

        self.chatBox = display.newSprite("#tuto_msgbox.png", {scale9 = true})
        self.chatBox:setContentSize(chatSize)
        self.chatBox:setAnchorPoint(cc.p(chatBoxAnchor, 0.5))
        self.chatBox:setPosition(girlPosX - chatBox_offsetX * flipSign, girlPosY + chatBox_offsetY)
        self.grilNode:addChild(self.chatBox)

        girlTable[#girlTable + 1] = self.chatBox

        self.chatChorner = display.newSprite("#tuto_msgfrom.png")
        self.chatChorner:setAnchorPoint(cc.p(chatCornerAnchor, 0.5))
        self.chatChorner:setFlippedX(flip)
        self.chatChorner:setPosition(self.chatBox:getPositionX() - corner_offsetX * flipSign, self.chatBox:getPositionY())
        self.grilNode:addChild(self.chatChorner)

        girlTable[#girlTable + 1] = self.chatChorner

        local ttfAlian = cc.TEXT_ALIGNMENT_LEFT

        if tutoStrLen < 12 then
            ttfAlian = cc.TEXT_ALIGNMENT_CENTER
        end

        local dim = cc.size(chatWidth - 40, self.chatBox:getContentSize().height - 30)
        --@RefType luaIde#cc.Label
        self.tutoTTF = cc.Label:createWithTTF(tutoStr, FONTS_NAME.font_fzcy, 24)
        self.tutoTTF:setAlignment(ttfAlian)
        self.tutoTTF:setTextColor(FONT_COLOR.BLACK)
        girlTable[#girlTable + 1] = self.tutoTTF

        self.tutoTTF:setDimensions(dim.width, dim.height)
        self.tutoTTF:setAnchorPoint(cc.p(chatBoxAnchor, 0.5))
        self.tutoTTF:setPosition(self.chatBox:getPositionX() - ttfOffsetX * flipSign, self.chatBox:getPositionY())
        self.grilNode:addChild(self.tutoTTF)

        -- getAppearAct(tuData.arrow_appear_time)

        for k, v in pairs(girlTable) do
            local girlFadeAct = getAppearAct(tuData.girl_appear_time)
            v:setOpacity(0)
            v:runAction(girlFadeAct)
        end
    end

    -- self:removeSelf()

    local isShowGirl = param.isShowGirl
    if isShowGirl == 0 then
        self.tutoTTF:setVisible(false)
        self.chatChorner:setVisible(false)
        self.chatBox:setVisible(false)
        self.girl:setVisible(false)
    else
        --播放动画
    end

    local unvisLayer = display.newLayer(cc.c4b(0, 0, 0, 0))
    unvisLayer:setTouchEnabled(true)
    -- unvisLayer:setTouchSwallowEnabled(true)
    self:addChild(unvisLayer, 1000)

    self.baseNode:setVisible(false) -- -setOpacity(10)
    clippingNode:setVisible(false)
    local function appearFunc()
        unvisLayer:removeSelf()
        if self.unlockFunc ~= nil then
            self.unlockFunc()
        end

        self.baseNode:setVisible(true)
        clippingNode:setVisible(true)
        self.callBackFunc = function()
            if isMask == 1 then
                ResMgr.createTutoMask(self:getParent())
            end
            -- self:removeSelf()
            self:setTag(99999)
            TutoMgr.unlockTable()
            if callBack ~= nil then
                callBack()
            end

            ResMgr.delayFunc(
                0.01,
                function()
                    self:removeSelf()
                end,
                self
            )
        end
    end
    ResMgr.delayFunc(delay, appearFunc, self)
end

function TutoLayer:initPos()
    self.pos = {
        cc.p(0.2 * display.width, 0.4375 * display.height),
        cc.p(0.8 * display.width, 0.4375 * display.height),
        cc.p(0.2 * display.width, 0.25 * display.height),
        cc.p(0.8 * display.width, 0.25 * display.height),
        cc.p(0.2 * display.width, 0.7 * display.height),
        cc.p(0.8 * display.width, 0.7 * display.height)
    }
end

return TutoLayer
