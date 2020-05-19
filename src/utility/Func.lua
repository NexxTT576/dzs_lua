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
    --@RefType luaIde#cc.EventDispatcher
    local eventDispatcher = target:getEventDispatcher()
    eventDispatcher:addCustomEventListener(key, cb)
end

function UnRegNotice(target, key)
    --@RefType luaIde#cc.EventDispatcher
    local eventDispatcher = target:getEventDispatcher()
    eventDispatcher:removeCustomEventListeners(key)
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
            --@RefType luaIde#cc.EventListenerTouchOneByOne
            local listener = cc.EventListenerTouchOneByOne:create()
            listener:registerScriptHandler(
                function(e)
                    if eventListenerHanders[eventType] then
                        return eventListenerHanders[eventType](e)
                    end
                    return true
                end,
                eventType
            )
            node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
            node["__eventListener"] = listener
        end
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
