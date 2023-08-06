Consts = require("consts")
require("classes.button")
require("classes.group")

local images = {}
local sounds = {}
local texts = {}
local music

local state = "menu"
local targetX, targetY = 0, 0

local score = 0
local highscore = 0
local startHighscore = 0
local lives = Consts.livesMax

local explosionAnimation = Animation(Consts.animationInfo.explosion)
local explosionX, explosionY = 0, 0
local canDrawExplosion = false

local soundButton = Button(Consts.buttonX, Consts.soundButtonY)
local musicButton = Button(Consts.buttonX, Consts.musicButtonY)

-- Quads are slow when called repeatedly, so it is better to store them in a table
local heartsQuad = {}
local clock = Clock()
local reloadClock = Clock()

local group
local timeBar = CloneRect(Consts.gui.bgTimeBar)

local function playSound(sound)
    if soundButton.on then
        sound:play()
    end
end

local function loadHighscore()
    local file = io.open(Consts.highscoreFilePath)
    if not file then
        return
    end

    local content = file:read("*n")
    if content then
        highscore = content
        startHighscore = content
    end

    file:close()
end

local function saveHighscore()
    local file = io.open(Consts.highscoreFilePath, "w")
    if not file then
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

local function resetLives()
    lives = Consts.livesMax
    for i = 1, lives do
        heartsQuad[i] = love.graphics.newQuad(Consts.heartSize, 0, Consts.heartSize, Consts.heartSize, images.heart)
    end
end

function love.load()
    love.mouse.setVisible(false)

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

local function menuMousePressed()
    if soundButton:isHovered() then
        soundButton:toggle()
        playSound(sounds.press)
    elseif musicButton:isHovered() then
        musicButton:toggle()
        playSound(sounds.press)
    end
end

local function gameMousePressed()
    if reloadClock:elapsedSeconds() < Consts.reloadDuration then
        return
    end
    score = score + 1
    explosionX = targetX - Consts.explosionSize / 2
    explosionY = targetY - Consts.explosionSize / 2
    explosionAnimation:restart()
    reloadClock:restart()
    clock:restart()
    texts.score:set(string.format("%02d/%02d", score, highscore))
    playSound(sounds.shoot)
end

function love.mousepressed(_, _, button, _, _)
    if button ~= Consts.leftClick then
        return
    end

    if state == "menu" then
        menuMousePressed()
    elseif state == "game" then
        gameMousePressed()
    end
end

local function launchGame()
    state = "game"
    score = 0
    resetLives()
    group = Group(11)
    texts.score:set(string.format("%02d/%02d", score, highscore))
    clock:restart()
    playSound(sounds.start)
    if musicButton.on then
        music:play()
    end
end

local function launchLost()
    state = "lost"
    group = nil

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
            group = nil
            if musicButton.on then
                music:stop()
            end
        elseif key == "space" then
            heartsQuad[lives] = love.graphics.newQuad(0, 0, Consts.heartSize, Consts.heartSize, images.heart)
            lives = lives - 1
            if lives == 0 then
                launchLost()
            end
        end
    elseif state == "lost" then
        if key == "space" then
            launchGame()
        end
    end
end

function love.update(dt)
    targetX, targetY = love.mouse.getPosition()
    if state ~= "game" then
        return
    end

    if clock:elapsedSeconds() > Consts.roundDuration then
        launchLost()
        return
    end

    group:update(dt)
    explosionAnimation:update()
    if not canDrawExplosion and explosionAnimation:isOver() then
        canDrawExplosion = true
    end

    timeBar.width = (1 - clock:elapsedSeconds() / Consts.roundDuration) * Consts.screenWidth
end

local function drawMenu()
    love.graphics.draw(images.logo, (Consts.screenWidth - images.logo:getWidth()) / 2, Consts.screenHeight / 4 - images.logo:getHeight() / 2)
    love.graphics.draw(texts.sub, (Consts.screenWidth - texts.sub:getWidth()) / 2, Consts.screenHeight * 0.75 - texts.sub:getHeight() / 2)

    soundButton:draw(images.soundOn, images.soundOff)
    musicButton:draw(images.musicOn, images.musicOff)
end

local function drawGame()
    group:draw(images)
    group:drawGui(images)

    for i, quad in ipairs(heartsQuad) do
        local x = 80 + (i - 1) * (5 + Consts.heartSize)
        love.graphics.draw(images.heart, quad, x, Consts.heartY)
    end

    if canDrawExplosion and not explosionAnimation:isOver() then
        love.graphics.draw(images.explosion, explosionAnimation:getCurrentQuad(), explosionX, explosionY)
    end

    love.graphics.draw(
        texts.score,
        Consts.screenWidth - texts.score:getWidth() - Consts.offset, 
        Consts.gui.rect.y + (Consts.gui.height - texts.score:getHeight()) / 2
    )

    Consts.gui.bgTimeBar:draw(Colors.black)
    timeBar:draw(Colors.orange)
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