--[[
    luaide  模板位置位于 Template/FunTemplate/NewFileTemplate.lua 其中 Template 为配置路径 与luaide.luaTemplatesDir
    luaide.luaTemplatesDir 配置 https://www.showdoc.cc/web/#/luaide?page_id=713062580213505
    author:tulilu
    time:2020-05-13 16:35:22
]]
require("utility.Func")
game = {
    player = require("game.Player").new(),
    --@RefType MyApp
    app = nil,
    --@RefType [packages#mvc#ViewBase]
    runningScene = nil
}
