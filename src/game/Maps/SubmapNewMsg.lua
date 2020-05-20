--[[
 --
 -- add by vicky
 -- 2014.09.25
 --
 --]]
local SubmapNewMsg =
    class(
    "SubmapNewMsg",
    function()
        return display.newNode()
    end
)

function SubmapNewMsg:ctor(title, levelName)
    dump(title)
    dump(levelName)

    local proxy = CCBProxy:create()
    local rootnode = {}

    local node = CCBReaderLoad("fuben/sub_map_open.ccbi", proxy, rootnode)
    node:setPosition(display.width / 2, display.height / 2)
    self:addChild(node)

    rootnode["title_lbl"]:setString(title)

    -- 关卡名称
    local titleLbl =
        newTTFLabelWithOutline(
        {
            text = levelName,
            size = 40,
            color = cc.c3b(101, 1, 1),
            outlineColor = cc.c3b(225, 225, 134),
            font = FONTS_NAME.font_haibao,
            align = ui.TEXT_ALIGN_CENTER
        }
    )

    titleLbl:setPosition(0, titleLbl:getContentSize().height / 2)
    rootnode["level_name"]:addChild(titleLbl)

    self:runAction(
        transition.sequence {
            CCDelayTime:create(1.5),
            CCFadeOut:create(1.0),
            CCCallFunc:create(
                function()
                    self:removeFromParent(true)
                end
            )
        }
    )
end

return SubmapNewMsg
