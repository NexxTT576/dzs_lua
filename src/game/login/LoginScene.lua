--@SuperType ViewBase
local LoginScene = class("LoginScene", cc.load("mvc").ViewBase)
require("game.game")

function LoginScene:onCreate()
    print("LoginScene onCreate")
    self:init()
    GameAudio.preloadMusic(ResMgr.getSFX(SFX_NAME.u_queding))
    GameAudio.playMainmenuMusic(true)
end

function LoginScene:init()
    local proxy = cc.CCBProxy:create()
    self._rootnode = {}
    local contentNode = CCBReaderLoad("login/login_scene.ccbi", proxy, self._rootnode, self, cc.size(display.width, display.height))
    contentNode:setPosition(display.cx, display.cy)
    self:addChild(contentNode, 1)
    self._rootnode["versionLabel"]:setString("V" .. DISPLAY_VERSION)
    --  背景
    local bgSprite = display.newSprite("ui/jpg_bg/gamelogo.jpg")
    local bottomLogoOffY = 0
    if (display.sizeInPixels.width / display.sizeInPixels.height) == 0.75 then
        bgSprite:setPosition(display.cx, display.height * 0.55)
        bgSprite:setScale(0.9)
    elseif (display.sizeInPixels.width == 640 and display.sizeInPixels.height == 960) then
        bgSprite:setPosition(display.cx, display.height * 0.55)
    else
        bgSprite:setPosition(display.cx, display.cy)
        self._rootnode["bottomNode"]:setPositionY(display.height * 0.065)
    end
    self:addChild(bgSprite)

    --  game title logo anim
    local logoName_default = "jiemian_biaotidonghua"
    local xunhuanname = "jiemian_biaotidonghua_xunhuan"
    self.logoAnim =
        ResMgr.createArma(
        {
            resType = ResMgr.UI_EFFECT,
            armaName = logoName_default,
            isRetain = true
        }
    )
    self.logoAnim:setPosition(self._rootnode["tag_logo_pos"]:getContentSize().width / 2, self._rootnode["tag_logo_pos"]:getContentSize().height / 2)
    self._rootnode["tag_logo_pos"]:addChild(self.logoAnim)

    local heroAnim =
        ResMgr.createArma(
        {
            resType = ResMgr.UI_EFFECT,
            armaName = "jiemian_dadoudonghua",
            isRetain = true
        }
    )
    heroAnim:setPosition(self._rootnode["tag_anim_pos"]:getContentSize().width / 2, self._rootnode["tag_anim_pos"]:getContentSize().height / 2)
    self._rootnode["tag_anim_pos"]:addChild(heroAnim)
    if (display.sizeInPixels.width / display.sizeInPixels.height) == 0.75 then
        heroAnim:setScale(0.8)
    end
    -- self._rootnode["enterGameBtn"]:addNodeEventListener()
    --@RefType luaIde#cc.EventListenerTouchOneByOne
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(
        function()
            return true
        end,
        cc.Handler.EVENT_TOUCH_BEGAN
    )
    listener:registerScriptHandler(
        function()
            require("network.RequestHelper")
            RequestHelper.game.login(
                {
                    acc = "bai__4115648358",
                    callback = function(data)
                        if data == nil then
                            --@TODO 2020-05-13 16:25:27 新用户
                        else
                            DramaMgr.request(data)
                        end
                    end
                }
            )
        end,
        cc.Handler.EVENT_TOUCH_ENDED
    )

    local eventDispatcher = self._rootnode["enterGameBtn"]:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._rootnode["enterGameBtn"])
end

function LoginScene:onExit()
end

return LoginScene
