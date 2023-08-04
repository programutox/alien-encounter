Consts = require("consts")
require("classes.animation")
require("classes.button")

local images = {}
local sounds = {}
local texts = {}
local music = nil

local state = "menu"
local lives = Consts.livesMax
local targetX, targetY = 0, 0

local score = 0
local highscore = 0
local startHighscore = 0

local explosionAnimation = Animation(Consts.animationInfo.explosion)
local explosionX, explosionY = 0, 0
local canDrawExplosion = false

local soundButton = Button(Consts.buttonX, Consts.soundButtonY)
local musicButton = Button(Consts.buttonX, Consts.musicButtonY)

local function playSound(sound)
    if soundButton.on then
        sound:play()
    end
end

local function loadHighscore()
    local file = io.open(Consts.highscoreFilePath)
    if file == nil then
        return
    end

    local content = file:read("*n")
    if content ~= nil then
        highscore = content
        startHighscore = content
    end

    file:close()
end

local function saveHighscore()
    local file = io.open(Consts.highscoreFilePath, "w")
    if file == nil then
        return
    end

    file:write(highscore)
    file:close()
end

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
    loadHighscore()

    local font = love.graphics.setNewFont(20)
    local bigFont = love.graphics.setNewFont(50)

    texts.lostTitle = love.graphics.newText(bigFont, "You lost!")
    texts.lostScore = love.graphics.newText(font)
    texts.sub = love.graphics.newText(font, "Press [space] to start")
    texts.score = love.graphics.newText(font, string.format("%02d/%02d", score, highscore))

    music = love.audio.newSource("assets/mus/alien_swamp.ogg", "stream")

    loadImages()
    loadSounds()
end

function love.mousepressed()
    if state == "menu" then
        if soundButton:isHovered() then
            soundButton:toggle()
            playSound(sounds.press)
        elseif musicButton:isHovered() then
            musicButton:toggle()
            playSound(sounds.press)
        end
    elseif state == "game" then
        if sounds.shoot:isPlaying() then
            return
        end
        score = score + 1
        explosionX = targetX - Consts.explosionSize / 2
        explosionY = targetY - Consts.explosionSize / 2
        explosionAnimation:restart()
        texts.score:set(string.format("%02d/%02d", score, highscore))
        playSound(sounds.shoot)
    end
end

local function launchGame()
    state = "game"
    score = 0
    texts.score:set(string.format("%02d/%02d", score, highscore))
    playSound(sounds.start)
    if musicButton.on then
        music:play()
    end
end

local function launchLost()
    state = "lost"

    local text = ""
    if score > highscore then
        highscore = score
        text = string.format("%02d, new record!", score)
    else
        text = string.format("You got %02d", score)
    end

    texts.lostScore:set(text)
    if musicButton.on then
        music:stop()
    end
    playSound(sounds.lost)
end

function love.keypressed(key)
    if state == "menu" then
        if key == "space" then
            launchGame()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif state == "game" then
        if key == "escape" then
            state = "menu"
            if musicButton.on then
                music:stop()
            end
        elseif key == "space" then
            launchLost()
        end
    elseif state == "lost" then
        if key == "space" then
            launchGame()
        end
    end
end

function love.update()
    targetX, targetY = love.mouse.getPosition()
    if state == "game" then
        explosionAnimation:update()
        if not canDrawExplosion and explosionAnimation:isOver() then
            canDrawExplosion = true
        end
    end
end

local function drawMenu()
    love.graphics.draw(images.logo, (Consts.screenWidth - images.logo:getWidth()) / 2, Consts.screenHeight / 4 - images.logo:getHeight() / 2)
    love.graphics.draw(texts.sub, (Consts.screenWidth - texts.sub:getWidth()) / 2, Consts.screenHeight * 0.75 - texts.sub:getHeight() / 2)
    
    soundButton:draw(images.soundOn, images.soundOff)
    musicButton:draw(images.musicOn, images.musicOff)
end

local function drawGame()
    Consts.gui.rect:draw(0.5, 0.5, 0.5)

    for i=1,Consts.livesMax do
        local quadX = 0
        if i <= lives then
            quadX = Consts.heartSize
        end
        local quad = love.graphics.newQuad(quadX, 0, Consts.heartSize, Consts.heartSize, images.heart)
        local x, y = 80 + (i - 1) * (5 + Consts.heartSize), Consts.heartY
        love.graphics.draw(images.heart, quad, x, y)
    end

    if canDrawExplosion and not explosionAnimation:isOver() then
        love.graphics.draw(images.explosion, explosionAnimation:getCurrentFrame(), explosionX, explosionY)
    end

    love.graphics.draw(
        texts.score,
        Consts.screenWidth - texts.score:getWidth() - Consts.offset, 
        Consts.gui.rect.y + (Consts.gui.height - texts.score:getHeight()) / 2
    )
end

local function drawLost()
    love.graphics.draw(
        texts.lostTitle,
        (Consts.screenWidth - texts.lostTitle:getWidth()) / 2,
        Consts.screenHeight / 4 - texts.lostTitle:getHeight() / 2
    )
    love.graphics.draw(
        texts.lostScore,
        (Consts.screenWidth - texts.lostScore:getWidth()) / 2,
        (Consts.screenHeight - texts.lostScore:getHeight()) / 2
    )
    love.graphics.draw(
        texts.sub,
        (Consts.screenWidth - texts.sub:getWidth()) / 2,
        Consts.screenHeight * 0.75 - texts.sub:getHeight() / 2
    )
end

function love.draw()
    love.graphics.draw(images.planet)

    if state == "menu" then
        drawMenu()
    elseif state == "game" then
        drawGame()
    elseif state == "lost" then
        drawLost()
    end

    love.graphics.draw(images.target, targetX - images.target:getWidth() / 2, targetY - images.target:getHeight() / 2)
end

function love.quit()
    if highscore > startHighscore then
        saveHighscore()
    end
end