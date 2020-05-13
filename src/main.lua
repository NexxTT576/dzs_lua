require "config"
require "cocos.init"
cc.FileUtils:getInstance():setPopupNotify(false)

local function main()
    --@RefType MyApp
    app = require("app.MyApp"):create()
    app:run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
