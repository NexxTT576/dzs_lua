--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
   
    time:2020-05-13 10:30:25
]]
require("json")
ws = {}
ws._rid = 0
ws.handers = {}
ws.maxReqNum = 99999

function ws.init(cb)
    print("ws://118.25.57.248:8080/ws")
    --@RefType luaIde#cc.WebSocket
    ws.wsSendString = cc.WebSocket:create("ws://127.0.0.1:8080/ws")
    ws.wsSendString:registerScriptHandler(
        function()
            print("WEBSOCKET_OPEN")
            if cb then
                cb()
            end
        end,
        cc.WEBSOCKET_OPEN
    )
    ws.wsSendString:registerScriptHandler(
        function(dataStr)
            print("WEBSOCKET_MESSAGE", dataStr)
            local data = json.decode(dataStr)
            local _rid = data["_rid"]
            if ws.handers[_rid] ~= nil then
                dump(ws.handers[_rid].reqData)
                if ws.handers[_rid].cb ~= nil and data.code == 0 then
                    ws.handers[_rid].cb(data.body)
                    ws.handers[_rid] = nil
                elseif data.code ~= 0 then
                    show_tip_label(data.msg)
                end
            end
        end,
        cc.WEBSOCKET_MESSAGE
    )
    ws.wsSendString:registerScriptHandler(
        function()
            print("WEBSOCKET_CLOSE")
            ws.wsSendString = nil
        end,
        cc.WEBSOCKET_CLOSE
    )
    ws.wsSendString:registerScriptHandler(
        function()
            print("WEBSOCKET_ERROR")
            ws.wsSendString = nil
        end,
        cc.WEBSOCKET_ERROR
    )
end

--[[
    @desc: 
   
    time:2020-05-13 11:27:09
	--@tableData: 发送数据
	--@callback:  正常回调
	--@errorcb:   错误回调
    @return:
]]
function ws.SendRequest(tableData, callback, errorcb)
    dump(tableData)
    local msg = {}
    msg._rid = ws._rid
    msg.body = json.encode(tableData)
    local str = json.encode(msg)
    ws.handers[ws._rid] = {
        reqData = msg,
        cb = callback,
        errcb = errorcb
    }
    ws._rid = ws._rid + 1
    if ws._rid > ws.maxReqNum then
        ws._rid = 0
    end
    ws._SendRequest(str)
end

function ws._SendRequest(wsSend)
    if ws.wsSendString == nil then
        local successcb = function()
            ws.wsSendString:sendString(wsSend)
        end
        ws.init(successcb)
    else
        ws.wsSendString:sendString(wsSend)
    end
end
