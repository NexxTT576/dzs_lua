EventType = {
    began = "began",
    ended = "ended",
    cancel = "cancel"
}

addTouchListener = function(node, callBack)
    local imageButton = require("game.Biwu.ImageButton"):new()
    imageButton:addTouchListener(node, callBack)
end
