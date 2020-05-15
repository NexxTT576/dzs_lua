--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-13 18:33:06
]]
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
