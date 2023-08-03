Object = require("lib.classic")
Consts = require("consts")

local images = {}
local sounds = {}

local function loadImages()
    for _, filepath in ipairs(love.filesystem.getDirectoryItems("assets/img/")) do
        local filename = filepath:sub(0, filepath:find(".png") - 1)
        images[filename] = love.graphics.newImage("assets/img/" .. filepath)
    end
end

local function loadSounds()
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/sfx/")) do
        local filename = file:sub(0, file:find(".wav") - 1)
        sounds[filename] = love.audio.newSource("assets/sfx/" .. file, "static")
    end
end

function love.load()
    local font = love.graphics.setNewFont(20)
    MenuSubText = love.graphics.newText(font, "Press [space] to start")

    loadImages()
    loadSounds()
end

function love.mousepressed()
    sounds.shoot:play()
end

function love.keypressed(key)
    if key == "space" then
        sounds.start:play()
    end
end

-- function love.update()

-- end

function love.draw()
    love.graphics.draw(images.planet)
    love.graphics.draw(images.logo, (Consts.screenWidth - images.logo:getWidth()) / 2, Consts.screenHeight / 4 - images.logo:getHeight() / 2)
    love.graphics.draw(MenuSubText, (Consts.screenWidth - MenuSubText:getWidth()) / 2, Consts.screenHeight * 0.75 - MenuSubText:getHeight() / 2)
end