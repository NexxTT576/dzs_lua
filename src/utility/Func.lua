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
        node["__touchEnabled"] = b
        if node["__eventListener"] == nil then
        end
    end
end

function setTouchSwallowEnabled(node, b)
    if node == nil and type(node) ~= "table" then
        print("setTouchSwallowEnabled", "参数错误")
    else
        node["__swallowEnabled"] = b
    end
end

--[[
    @desc: 
    author:tulilu
    time:2020-05-18 20:16:13
    --@node: 节点
	--@eventType: 
	--@cb: 
    @return:
]]
function addNodeEventListener(node, eventType, cb)
    if eventType == cc.Handler.EVENT_TOUCH_BEGAN or eventType == cc.Handler.EVENT_TOUCH_MOVED or eventType == cc.Handler.EVENT_TOUCH_CANCELLED or eventType == cc.Handler.EVENT_TOUCH_ENDED then
        --@RefType luaIde#cc.EventListenerTouchOneByOne
        local listener = node["__eventListener"] == nil and cc.EventListenerTouchOneByOne:create() or node["__eventListener"]
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(
            function(e)
                if cb then
                    return cb(e)
                end
            end,
            eventType
        )
        node:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, node)
    end
end
