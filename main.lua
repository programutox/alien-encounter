Object = require("lib.classic")
Consts = require("consts")

local images = {}
local sounds = {}
local texts = {}

local state = "menu"
local lives = Consts.livesMax
local targetPosition = Vector2(0, 0)

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
    local bigFont = love.graphics.setNewFont(50)
    texts.lost = love.graphics.newText(bigFont, "You lost!")
    texts.sub = love.graphics.newText(font, "Press [space] to start")

    loadImages()
    loadSounds()
end

function love.mousepressed()
    if state == "game" then
        state = "lost"
        sounds.shoot:play()
    end
end

function love.keypressed(key)
    if state == "menu" then
        if key == "space" then
            state = "game"
            sounds.start:play()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif state == "game" then
        if key == "escape" then
            state = "menu"
        end
    elseif state == "lost" then
        if key == "space" then
            state = "game"
            sounds.start:play()
        end
    end
end

function love.update()
    targetPosition.x, targetPosition.y = love.mouse.getPosition()
end

function love.draw()
    love.graphics.draw(images.planet)
    
    if state == "menu" then
        love.graphics.draw(images.logo, (Consts.screenWidth - images.logo:getWidth()) / 2, Consts.screenHeight / 4 - images.logo:getHeight() / 2)
        love.graphics.draw(texts.sub, (Consts.screenWidth - texts.sub:getWidth()) / 2, Consts.screenHeight * 0.75 - texts.sub:getHeight() / 2)
    elseif state == "game" then
        Consts.gui.rect:draw(0.5, 0.5, 0.5)

        for i=1,Consts.livesMax do
            local x = 0
            if i <= lives then
                x = Consts.heartSize
            end
            local quad = love.graphics.newQuad(x, 0, Consts.heartSize, Consts.heartSize, images.heart)
            local position = Vector2(80 + (i - 1) * (5 + Consts.heartSize), Consts.heartY)
            love.graphics.draw(images.heart, quad, position.x, position.y)
        end
    elseif state == "lost" then
        love.graphics.draw(texts.lost, (Consts.screenWidth - texts.lost:getWidth()) / 2, Consts.screenHeight / 4 - texts.lost:getHeight() / 2)
        love.graphics.draw(texts.sub, (Consts.screenWidth - texts.sub:getWidth()) / 2, Consts.screenHeight * 0.75 - texts.sub:getHeight() / 2)
    end

    love.graphics.draw(images.target, targetPosition.x - images.target:getWidth() / 2, targetPosition.y - images.target:getHeight() / 2)
end

function love.quit()
    -- Write highscore
end