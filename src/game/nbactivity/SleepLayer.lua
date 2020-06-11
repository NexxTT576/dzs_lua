local SleepLayer =
    class(
    "SleepLayer",
    function()
        return display.newNode()
    end
)

function SleepLayer:ctor(param)
    local viewSize = param.viewSize
    local proxy = CCBProxy:create()
    local rootnode = {}

    local contentNode = CCBReaderLoad("nbhuodong/nbhuodong_scene.ccbi", proxy, rootnode, self, viewSize)
    self:addChild(contentNode)
    --    bg2
    if (display.sizeInPixels.width / display.sizeInPixels.height) > 0.67 then
        rootnode["bg2"]:setPositionY(rootnode["bg2"]:getPositionY() - rootnode["bg2"]:getContentSize().height * 0.06)
    end
    local function onGetup()
        show_tip_label("恭喜获得50点体力")
        ccb["nbHuodongCtrl"]["mAnimationManager"]:runAnimationsForSequenceNamed("getupAnim")
        rootnode["girlSprite"]:runAction(
            transition.sequence(
                {
                    cc.DelayTime:create(2),
                    CCShow:create(),
                    CCFadeIn:create(0.8)
                    --            cc.CallFunc:create(function()
                    --                rootnode["restBtn"]:setVisible(true)
                    --            end)
                }
            )
        )
    end

    local function onRestBtn()
        rootnode["restBtn"]:setVisible(false)
        rootnode["girlSprite"]:runAction(
            transition.sequence(
                {
                    cc.FadeOut:create(0.5),
                    CCHide:create(),
                    cc.CallFunc:create(
                        function()
                            local schedule = require("utility.scheduler")
                            schedule.performWithDelayGlobal(
                                function()
                                    local particle = CCParticleSystemQuad:create("ccs/particle/p_kezhan_xiuxi_1.plist")
                                    rootnode["particleNode"]:addChild(particle)

                                    local particle = CCParticleSystemQuad:create("ccs/particle/p_kezhan_xiuxi_2.plist")
                                    rootnode["particleNode"]:addChild(particle)
                                    schedule.performWithDelayGlobal(
                                        function()
                                            onGetup()
                                        end,
                                        2.25
                                    )
                                end,
                                2.5
                            )

                            ccb["nbHuodongCtrl"]["mAnimationManager"]:runAnimationsForSequenceNamed("sleepAnim")
                        end
                    )
                }
            )
        )
    end

    rootnode["restBtn"]:registerControlEventHandler(
        function()
            RequestHelper.nbHuodong.sleep(
                {
                    callback = function(data)
                        dump(data)
                        if string.len(data["0"]) > 0 then
                            CCMessageBox(data["0"], "Tip")
                        else
                            onRestBtn()
                            rootnode["restBtn"]:setVisible(false)
                            game.player:setStrength(data["1"])
                        end
                    end
                }
            )

            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end,
        CCControlEventTouchDown
    )

    RequestHelper.nbHuodong.state(
        {
            callback = function(data)
                if string.len(data["0"]) > 0 then
                    CCMessagBox(data["0"])
                else
                    if data["1"] > 0 then
                        rootnode["restBtn"]:setVisible(true)
                    else
                        rootnode["restBtn"]:setVisible(false)
                    end
                end
            end
        }
    )
end

return SleepLayer
