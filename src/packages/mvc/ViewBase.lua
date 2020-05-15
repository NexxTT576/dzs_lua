--@SuperType luaIde#cc.Node
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name, data)
    if type(app) == "table" and app.class and app.class.super and app.class.super.__cname == "AppBase" then
        app = app
    else
        data = name
        name = app
        app = game.app
    end

    if name == nil then
        name = "default"
    elseif type(name) == "table" then
        data = name
        name = "default"
    end

    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end

    if self.onCreate then
        self:onCreate(data)
    end
end

--[[
    @desc: 
    author:tulilu
    time:2020-05-12 16:27:22
    @return: AppBase
]]
function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format('ViewBase:createResourceNode() - load resouce node from file "%s" failed', resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResourceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResourceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = self.resourceNode_:getChildByName(nodeName)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                node:onTouch(handler(self, self[event.method]))
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)

    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

function ViewBase:postNotice(key, msg)
    --@RefType luaIde#cc.EventCustom
    local event = cc.EventCustom:new(key)
    event._usedata = msg
    --@RefType luaIde#cc.EventDispatcher
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:dispatchEvent(event)
end

function ViewBase:regNotice(cb, key)
    --@RefType luaIde#cc.EventDispatcher
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addCustomEventListener(key, cb)
end

function ViewBase:unRegNotice(key)
    --@RefType luaIde#cc.EventDispatcher
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeCustomEventListeners(key)
end

return ViewBase
