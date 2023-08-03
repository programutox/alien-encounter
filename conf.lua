local consts = require("consts")

function love.conf(t)
    t.window.icon = "assets/img/icon.png"
    t.window.width = consts.screenWidth
    t.window.height = consts.screenHeight
    t.window.title = consts.title
end
