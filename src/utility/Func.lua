--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-13 18:33:06
]]
function c_func(f, ...)
    local args1 = {...}

    return function()
        return f(unpack(args1))
    end
end

function safe_call(f, message)
    if type(f) == "function" then
        local err, ret =
            xpcall(
            f,
            function()
                __G__TRACKBACK__(message or "error:")
            end
        )
        if err then
            return ret
        end
    else
        show_tip_label("请确定f是个函数")
    end
end

-- 系统时间
function GetSystemTime(...)
    local curTime = os.date("%H:%M", os.time())
    return curTime
end

-- 字符串中是否含有中文
function isCnChar(str)
    local len = string.len(str)
    local left = len
    local cnt = 0

    for i = 1, len do
        local curByte = string.byte(str, i)
        -- '￥' = 239
        if (curByte > 127) then
            dump(curByte)
            return true
        end
    end

    return false
end

-- 字符串是否含有非法字符
function hasIllegalChar(str)
    local illegalStr = ""
    --"`-=[]\\;',./～！@#￥%…&×（）—『』|：“”《》？·【】、；’‘，。~!$^*()_+{}:\"<>?"

    local len = string.len(illegalStr)
    local curByte = nil
    for i = 1, len do
        curByte = string.sub(str, i)
        printf(curByte)
        contain = string.find(str, curByte)
        printf(contain)
        if (contain ~= nil) then
            printf("hasIllegalChar")
            return true
        end
    end

    return false
end

function PostNotice(key, msg)
    local n = cc.Director:getInstance():getEventDispatcher()
    if msg == nil then
        local event = cc.EventCustom:new(key)
        n:dispatchEvent(event)
    else
        local event = cc.EventCustom:new(key)
        event._usedata = msg
        n:dispatchEvent(event)
    end
end

function RegNotice(target, cb, key)
    local listener1 = cc.EventListenerCustom:create(key, cb)
    target["listener_" .. key] = listener1
    local eventDispatcher = target:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener1, 1)
end

function UnRegNotice(target, key)
    --@RefType luaIde#cc.EventDispatcher
    local eventDispatcher = target:getEventDispatcher()
    eventDispatcher:removeEventListener(target["listener_" .. key])
    target["listener_" .. key] = nil
end

function show_tip_label(str, delay)
    print(str)
    local tipLabel = require("utility.TipLabel").new(str, delay)
    display.getRunningScene():addChild(tipLabel, 3000000)
end

function setTouchEnabled(node, b)
    if node == nil and type(node) ~= "table" then
        print("setTouchEnabled", "参数错误")
    else
        if node["__eventListener"] == nil then
            addNodeEventListener(node, cc.Handler.EVENT_TOUCH_BEGAN, nil, false)
        end
        --@RefType luaIde#cc.EventListenerTouchOneByOne
        local eventListener = node["__eventListener"]
        eventListener:setEnabled(b)
    end
end

function setTouchSwallowEnabled(node, b)
    if node == nil and type(node) ~= "table" then
        print("setTouchSwallowEnabled", "参数错误")
    else
        if node["__eventListener"] == nil then
            addNodeEventListener(node, cc.Handler.EVENT_TOUCH_BEGAN, nil, false)
        end
        --@RefType luaIde#cc.EventListenerTouchOneByOne
        local eventListener = node["__eventListener"]
        eventListener:setSwallowTouches(b)
    end
end

--[[
    @desc: 
    author:tulilu
    time:2020-05-18 20:16:13
    --@node: luaIde#cc.Node
	--@eventType: 
	--@cb: 
    @return:
]]
function addNodeEventListener(node, eventType, cb, isRefresh)
    if eventType == cc.Handler.EVENT_TOUCH_BEGAN or eventType == cc.Handler.EVENT_TOUCH_MOVED or eventType == cc.Handler.EVENT_TOUCH_CANCELLED or eventType == cc.Handler.EVENT_TOUCH_ENDED then
        local eventListenerHanders = node["__eventListenerHanders"]
        if eventListenerHanders == nil then
            eventListenerHanders = {}
            node["__eventListenerHanders"] = eventListenerHanders
        end
        if isRefresh ~= false then
            eventListenerHanders[eventType] = cb
        end

        if node["__eventListener"] == nil then
            local rshandle = function(touch, event, he)
                --@RefType luaIde#cc.Touch
                local t = touch
                --@RefType luaIde#cc.Event
                local e = event
                --@RefType luaIde#cc.Node
                local target = e:getCurrentTarget()
                local dt = target
                while dt ~= nil do
                    if dt:isVisible() == false then
                        return false
                    end
                    dt = dt:getParent()
                end
                local locationInNode = target:convertToNodeSpace(t:getLocation())
                local s = target:getContentSize()
                local targetPos = target:getPositionX()
                local rect = cc.rect(0, 0, s.width, s.height)
                if cc.rectContainsPoint(rect, locationInNode) then
                    if eventListenerHanders[he] then
                        return eventListenerHanders[he](t, e)
                    end
                end
                return true
            end
            --@RefType luaIde#cc.EventListenerTouchOneByOne
            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(
                function(touch, event)
                    return rshandle(touch, event, cc.Handler.EVENT_TOUCH_BEGAN)
                end,
                cc.Handler.EVENT_TOUCH_BEGAN
            )
            listener:registerScriptHandler(
                function(touch, event)
                    return rshandle(touch, event, cc.Handler.EVENT_TOUCH_MOVED)
                end,
                cc.Handler.EVENT_TOUCH_MOVED
            )
            listener:registerScriptHandler(
                function(touch, event)
                    return rshandle(touch, event, cc.Handler.EVENT_TOUCH_CANCELLED)
                end,
                cc.Handler.EVENT_TOUCH_CANCELLED
            )
            listener:registerScriptHandler(
                function(touch, event)
                    return rshandle(touch, event, cc.Handler.EVENT_TOUCH_ENDED)
                end,
                cc.Handler.EVENT_TOUCH_ENDED
            )
            node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
            node["__eventListener"] = listener
        end
    end
end

function removeAllNodeEventListeners(node)
    if node["__eventListenerHanders"] ~= nil then
        node["__eventListenerHanders"] = {}
    end
end

local sharedDirector = cc.Director:getInstance()
local sceneLevel = 1

function push_scene(scene)
    assert(scene, "Scene is nil")
    sceneLevel = sceneLevel + 1
    print("push scene")
    sharedDirector:pushScene(scene)
end

function pop_scene()
    print("pop scene: " .. tostring(display.getRunningScene().__cname))
    if sceneLevel > 1 then
        sceneLevel = sceneLevel - 1
        sharedDirector:popScene()
    end
end

--[[
    @desc: 
    author:tulilu
    time:2020-05-20 11:41:52
    --@param:  {   text = self._debrisName,
            size = 30,
            color = nameColor,
            shadowColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_haibao,
            align = cc.TEXT_ALIGNMENT_CENTER}
    @return:
]]
function newTTFLabelWithShadow(param)
    if param.text == nil then
        param.text = ""
    end
    if param.color == nil then
        param.color = cc.c3b(255, 255, 255)
    end
    if param.size == nil then
        param.size = 25
    end
    if param.align == nil then
        param.align = cc.TEXT_ALIGNMENT_CENTER
    end
    if param.valign == nil then
        param.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    end
    if param.shadowColor == nil then
        param.shadowColor = cc.c3b(0, 0, 0)
    end
    if param.x == nil then
        param.x = 0
    end
    if param.y == nil then
        param.y = 0
    end
    --@RefType luaIde#cc.Label
    local lb = cc.Label:createWithTTF(param.text, param.font, param.size)
    lb:setTextColor(param.color)
    lb:setAlignment(param.align)
    lb:setVerticalAlignment(param.valign)
    lb:enableShadow(param.shadowColor)
    lb:setPosition(param.x, param.y)
    if param.dimensions ~= nil then
        lb:setDimensions(param.dimensions)
    end
    return lb
end

function newBMFontLabel(param)
    if param.text == nil then
        param.text = ""
    end
    if param.x == nil then
        param.x = 0
    end
    if param.y == nil then
        param.y = 0
    end
    if param.align == nil then
        param.align = cc.TEXT_ALIGNMENT_CENTER
    end
    if param.valign == nil then
        param.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    end
    --@RefType luaIde#cc.Label
    local lb = cc.Label:createWithBMFont(param.font, param.text)
    if param.size then
        lb:setBMFontSize(param.size)
    end
    lb:setPosition(param.x, param.y)
    lb:setAlignment(param.align)
    lb:setVerticalAlignment(param.valign)
    if param.dimensions ~= nil then
        lb:setDimensions(param.dimensions)
    end
    return lb
end

--[[
    @desc: 
    author:tulilu
    time:2020-05-20 11:41:52
    --@param:  {   text = self._debrisName,
            size = 30,
            color = nameColor,
            outlineColor = cc.c3b(0, 0, 0),
            font = FONTS_NAME.font_haibao,
            align = cc.TEXT_ALIGNMENT_CENTER}
    @return: luaIde#cc.Label
]]
function newTTFLabelWithOutline(param)
    if param.text == nil then
        param.text = ""
    end
    if param.color == nil then
        param.color = cc.c3b(255, 255, 255)
    end
    if param.size == nil then
        param.size = 25
    end
    if param.align == nil then
        param.align = cc.TEXT_ALIGNMENT_CENTER
    end
    if param.valign == nil then
        param.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    end
    if param.outlineColor == nil then
        param.outlineColor = cc.c3b(0, 0, 0)
    end
    if param.x == nil then
        param.x = 0
    end
    if param.y == nil then
        param.y = 0
    end
    --@RefType luaIde#cc.Label
    local lb = cc.Label:createWithTTF(param.text, param.font, param.size)
    lb:setTextColor(param.color)
    lb:setAlignment(param.align)
    lb:setVerticalAlignment(param.valign)
    lb:enableOutline(param.outlineColor, 1)
    lb:setPosition(param.x, param.y)
    if param.dimensions ~= nil then
        lb:setDimensions(param.dimensions)
    end
    return lb
end

function newTTFLabel(param)
    if param.text == nil then
        param.text = ""
    end
    if param.color == nil then
        param.color = cc.c3b(255, 255, 255)
    end
    if param.size == nil then
        param.size = 25
    end
    if param.align == nil then
        param.align = cc.TEXT_ALIGNMENT_CENTER
    end
    if param.valign == nil then
        param.valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    end
    if param.outlineColor == nil then
        param.outlineColor = cc.c3b(0, 0, 0)
    end
    if param.x == nil then
        param.x = 0
    end
    if param.y == nil then
        param.y = 0
    end
    --@RefType luaIde#cc.Label
    local lb = cc.Label:create()
    lb:setString(param.text)
    lb:setSystemFontSize(param.size)
    lb:setTextColor(param.color)
    lb:setAlignment(param.align)
    lb:setVerticalAlignment(param.valign)
    lb:setPosition(param.x, param.y)
    if param.dimensions ~= nil then
        lb:setDimensions(param.dimensions.width, param.dimensions.height)
    end
    return lb
end

function resetctrbtnimage(btn, image)
    btn:setBackgroundSpriteForState(display.newSprite(image, {scale9 = true}), cc.CONTROL_STATE_NORMAL)
    btn:setBackgroundSpriteForState(display.newSprite(image, {scale9 = true}), cc.CONTROL_STATE_HIGH_LIGHTED)
    btn:setBackgroundSpriteForState(display.newSprite(image, {scale9 = true}), cc.CONTROL_STATE_DISABLED)
end

function newEditBox(param)
    --@RefType luaIde#ccui.EditBox
    local edit = ccui.EditBox:create(param.size, display.newSprite(param.image, {scale9 = true}))
    if param.x ~= nil then
        edit:setPositionX(param.x)
    end
    if param.y ~= nil then
        edit:setPositionX(param.y)
    end
    return edit
end

function resetbtn(btn, parentNode, zorder)
    local closepos = btn:convertToWorldSpace(cc.p(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    btn:retain()
    btn:removeFromParent(false)
    btn:setPosition(parentNode:convertToNodeSpace(closepos))
    parentNode:addChild(btn, zorder)
    btn:release()
    btn:setTouchEnabled(true)
end

local SEC_OF_MIN = 60
local SEC_OF_HOUR = 3600

function format_time(t)
    local hour = math.floor(t / SEC_OF_HOUR)
    local min = math.floor((t % SEC_OF_HOUR) / SEC_OF_MIN)
    local sec = t - hour * SEC_OF_HOUR - min * SEC_OF_MIN
    return string.format("%02d:%02d:%02d", hour, min, sec)
end

function format_time_unit(t)
    local hour = math.floor(t / SEC_OF_HOUR)
    local min = math.floor((t % SEC_OF_HOUR) / SEC_OF_MIN)
    local sec = t - hour * SEC_OF_HOUR - min * SEC_OF_MIN
    return string.format("%02d小时%02d分%02d秒", hour, min, sec)
end

function arrangeTTFByPosX(cells)
    --按照X位置排序
    for i = 1, #cells do
        if i ~= 1 then
            cells[i]:setPositionX(cells[i - 1]:getPositionX() + cells[i - 1]:getContentSize().width)
        end
    end
end

function newImageMenuItem(params)
    local s1 = ""
    local s2 = ""
    if params.image then
        s1 = params.image
    end
    if params.imageSelected then
        s2 = params.imageSelected
    end
    local l = cc.MenuItemImage:create(s1, s2)
    l:registerScriptTapHandler(params.listener)
    return l
end

function newMenu(items)
    local menu
    menu = cc.Menu:create()

    for k, item in pairs(items) do
        if not tolua.isnull(item) then
            menu:addChild(item, 0, item:getTag())
        end
    end

    menu:setPosition(0, 0)
    return menu
end
--[[
    @desc: 
    author:tulilu
    time:2020-06-11 18:34:51
    --@btn: luaIde#cc.Node
	--@func:
	--@soundFunc: 
    @return:
]]
function setControlBtnEvent(btn, func, soundFunc)
    btn:registerControlEventHandler(
        function(sender)
            sender:runAction(
                transition.sequence(
                    {
                        cc.CallFunc:create(
                            function()
                                if soundFunc ~= nil then
                                    soundFunc()
                                else
                                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
                                end
                                func()
                            end
                        )
                    }
                )
            )
        end,
        CCControlEventTouchUpInside
    )
end
