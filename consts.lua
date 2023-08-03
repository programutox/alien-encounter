Object = require("lib.classic")
require("classes.color")
require("classes.vector2")
require("classes.rectangle")
require("classes.animationinfo")

local function protect(table)
    return setmetatable({}, {
        __index = table,
        __newindex = function (_, key, value)
            error(string.format("Attempting to change constant %s to %s", key, value), 2)
        end
    })
end

local c = {
    title = "Alien Encounter",
    livesMax = 3,
    roundDuration = 10.0,
    highscoreFilePath = "assets/data/highscore.bin",
    scoreFontSize = 30,
    offset = 10,

    alien = {
        perRows = 5,
        perColumns = 5,
        frameWidth = 104,
        frameHeight = 143,
        scale = 0.5,
        speed = 100
    },

    littleAlien = {
        scale = 0.35,
        speed = 150
    },

    heartSize = 35,
    buttonSize = 32,
    explosionSize = 64,
    borderRadius = 25,
    borderColor = Color(0, 0, 0, 240),

    colors = {
        Color(220, 20, 60, 255), -- red
		Color(50, 205, 50, 255), -- green
		Color(255, 105, 180, 255), -- rose
		Color(255, 165, 0, 255), -- orange
		Color(255, 255, 0, 255), -- yellow
		Color(138, 43, 226, 255), -- purple
		Color(139, 69, 19, 255), -- brown
		Color(0, 255, 255, 255), -- cyan
		Color(0, 0, 255, 255), -- blue
		Color(0, 0, 0, 255), -- black
		Color(255, 255, 255, 255), -- white
    },

    gui = {},
    animationInfo = {},
}

c.alien.headcount = c.alien.perRows * c.alien.perColumns
c.alien.width = c.alien.frameWidth * c.alien.scale
c.alien.height = math.floor(c.alien.frameHeight * c.alien.scale)

c.littleAlien.width = c.alien.frameWidth * c.littleAlien.scale
c.littleAlien.height = c.alien.frameHeight * c.littleAlien.scale

c.gui.height = c.offset + c.alien.height
c.screenWidth = c.offset + c.alien.perRows * (c.alien.width + c.offset)
c.screenHeight = c.offset + c.alien.perColumns * (c.alien.height + c.offset) + c.gui.height

c.gui.rect = Rectangle(0, c.screenHeight - c.gui.height, c.screenWidth, c.gui.height)

c.gui.alienPosition = Vector2(c.offset, c.gui.rect.y + c.offset / 2)
c.gui.littleAlienPosition = Vector2(c.offset * 2, c.gui.rect.y + (c.offset + c.alien.height - c.littleAlien.height) / 2)
c.gui.bgTimeBar = Rectangle(0, c.gui.rect.y, c.screenWidth, 5)
c.heartY = c.gui.rect.y + (c.gui.height - c.heartSize) / 2

c.animationInfo.idle = AnimationInfo(
    Rectangle(0, 0, c.alien.frameWidth, c.alien.frameHeight),
    2,
    0.5,
    true
)

c.animationInfo.move = AnimationInfo(
    Rectangle(0, c.alien.frameHeight, c.alien.frameWidth, c.alien.frameHeight),
    3,
    0.25,
    true
)

c.animationInfo.death = AnimationInfo(
    Rectangle(0, c.alien.frameHeight * 2, c.alien.frameWidth, c.alien.frameHeight), 
    3,
    0.25,
    false
)

c.animationInfo.criminalDeath = AnimationInfo(
    Rectangle(0, c.alien.frameHeight * 2, c.alien.frameWidth, c.alien.frameHeight), 
    3,
    0.25,
    true
)

c.animationInfo.explosion = AnimationInfo(
    Rectangle(0, 0, c.explosionSize, c.explosionSize),
    4,
    c.animationInfo.death.frameDuration / 4,
    false
)

c.reloadDuration = c.animationInfo.death.frameDuration

return protect(c)
