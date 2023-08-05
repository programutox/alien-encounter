Object = require("lib.classic")
require("classes.color")
require("classes.animationinfo")
require("classes.rectangle")

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
    leftClick = 1,

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
        Color(220, 20, 60, 255):normalized(), -- red
		Color(50, 205, 50, 255):normalized(), -- green
		Color(255, 105, 180, 255):normalized(), -- rose
		Color(255, 165, 0, 255):normalized(), -- orange
		Color(255, 255, 0, 255):normalized(), -- yellow
		Color(138, 43, 226, 255):normalized(), -- purple
		Color(139, 69, 19, 255):normalized(), -- brown
		Color(0, 255, 255, 255):normalized(), -- cyan
		Color(0, 0, 255, 255):normalized(), -- blue
		Color(0, 0, 0, 255):normalized(), -- black
		Color(255, 255, 255, 255):normalized(), -- white
    },

    gui = {},
    animationInfo = {},
}

c.alien.imageWidth = 3 * c.alien.frameWidth
c.alien.imageHeight = 4 * c.alien.frameHeight
c.alien.headcount = c.alien.perRows * c.alien.perColumns
c.alien.width = math.floor(c.alien.frameWidth * c.alien.scale)
c.alien.height = math.floor(c.alien.frameHeight * c.alien.scale)

c.littleAlien.width = math.floor(c.alien.frameWidth * c.littleAlien.scale)
c.littleAlien.height = math.floor(c.alien.frameHeight * c.littleAlien.scale)

c.gui.height = c.offset + c.alien.height
c.screenWidth = c.offset + c.alien.perRows * (c.alien.width + c.offset)
c.screenHeight = c.offset + c.alien.perColumns * (c.alien.height + c.offset) + c.gui.height

c.gui.rect = Rectangle(0, c.screenHeight - c.gui.height, c.screenWidth, c.gui.height)

c.littleAlienOffsetX = math.floor((c.alien.width - c.littleAlien.width) / 2)
c.littleAlienOffsetY = math.floor((c.alien.height - c.littleAlien.height) / 2)

c.gui.alienX = c.offset
c.gui.alienY = c.gui.rect.y + c.offset / 2
c.gui.littleAlienX = c.offset * 2
c.gui.littleAlienY = math.floor(c.gui.rect.y + (c.offset + c.alien.height - c.littleAlien.height) / 2)
c.gui.bgTimeBar = Rectangle(0, c.gui.rect.y, c.screenWidth, 5)
c.heartY = c.gui.rect.y + (c.gui.height - c.heartSize) / 2

c.animationInfo.idle = AnimationInfo(
    Rectangle(0, 0, c.alien.frameWidth, c.alien.frameHeight),
    2,
    0.5,
    true,
    c.alien.imageWidth,
    c.alien.imageHeight
)

c.animationInfo.move = AnimationInfo(
    Rectangle(0, c.alien.frameHeight, c.alien.frameWidth, c.alien.frameHeight),
    3,
    0.25,
    true,
    c.alien.imageWidth,
    c.alien.imageHeight
)

c.animationInfo.death = AnimationInfo(
    Rectangle(0, c.alien.frameHeight * 2, c.alien.frameWidth, c.alien.frameHeight),
    3,
    0.25,
    false,
    c.alien.imageWidth,
    c.alien.imageHeight
)

c.animationInfo.criminalDeath = AnimationInfo(
    Rectangle(0, c.alien.frameHeight * 2, c.alien.frameWidth, c.alien.frameHeight),
    3,
    0.25,
    true,
    c.alien.imageWidth,
    c.alien.imageHeight
)

c.animationInfo.explosion = AnimationInfo(
    Rectangle(0, 0, c.explosionSize, c.explosionSize),
    4,
    c.animationInfo.death.frameDuration / 4,
    false,
    4 * c.explosionSize,
    4 * c.explosionSize
)

c.reloadDuration = c.animationInfo.death.frameDuration * c.animationInfo.death.framesCount

c.buttonX = c.screenWidth - c.buttonSize - c.offset
c.soundButtonY = c.screenHeight - (c.buttonSize + c.offset) * 2
c.musicButtonY = c.screenHeight - (c.buttonSize + c.offset)

return protect(c)
