Consts = require("consts")
require("classes.button")
require("classes.group")

local images = {}
local sounds = {}
local texts = {}
local music
local onWeb

local state = "menu"
local targetX, targetY = 0, 0

local highscore = 0
local startHighscore = 0
local lives = Consts.livesMax

local explosionAnimation = Animation(Consts.animationInfo.explosion)
local explosionX, explosionY = 0, 0
local canDrawExplosion = false

local buttons = {
    sound = Button(Consts.buttonX, Consts.soundButtonY),
    music = Button(Consts.buttonX, Consts.musicButtonY),
    colors = Button(Consts.buttonX, Consts.colorsButtonY)
}

-- Quads are slow when called repeatedly, so it is better to store them in a table
local heartsQuad = {}
local clock = Clock()
local reloadClock = Clock()

local group
local timeBar = CloneRect(Consts.gui.bgTimeBar)
local timeBarWidth = 0
local criminalShot = false
local canShoot = true

local function playSound(sound)
    if buttons.sound.on then
        sound:play()
    end
end

local playPressSound = function () playSound(sounds.press) end

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
    onWeb = love.system.getOS() == "Web"
    love.mouse.setVisible(onWeb)

    loadHighscore()

    Font = love.graphics.setNewFont(20)
    local bigFont = love.graphics.setNewFont(50)

    texts.lostTitle = love.graphics.newText(bigFont, "You lost!")
    texts.lostScore = love.graphics.newText(Font)
    texts.sub = love.graphics.newText(Font, "Click to start")

    music = love.audio.newSource("assets/mus/alien_swamp.ogg", "stream")
    music:setLooping(true)

    loadImages()
    loadSounds()
end

local function launchGame()
    state = "game"
    resetLives()
    group = Group(0, highscore, Font, buttons.colors.on, onWeb)
    clock:restart()
    playSound(sounds.start)
    if buttons.music.on then
        music:play()
    end
end

local function menuMousePressed()
    local buttonClicked = false
    for _, b in pairs(buttons) do
        if b:updateIfClicked(playPressSound) then
            buttonClicked = true
        end
    end

    if not buttonClicked then
        launchGame()
    end
end

local function loseLife()
    heartsQuad[lives] = love.graphics.newQuad(0, 0, Consts.heartSize, Consts.heartSize, images.heart)
    lives = lives - 1
end

local function gameMousePressed()
    if reloadClock:elapsedSeconds() < Consts.reloadDuration or criminalShot then
        return
    end

    local clickedAliens = group:getClickedAliens()
    if #clickedAliens == 0 then
        return
    end

    canShoot = false
    reloadClock:restart()

    local innocentAliensId = {}
    for _, alien in ipairs(clickedAliens) do
        if alien.id ~= group.criminalId then
            table.insert(innocentAliensId, alien.id)
        end
    end

    local isCriminalClicked = #innocentAliensId == #clickedAliens - 1
    if not isCriminalClicked and #innocentAliensId > 0 then
        group:triggerDeaths()
        if lives - 1 > 0 then
            targetX, targetY = love.mouse.getPosition()
            explosionX = targetX - Consts.explosionSize / 2
            explosionY = targetY - Consts.explosionSize / 2
            explosionAnimation:restart()
            playSound(sounds.shoot)
        end
        loseLife()
        return
    end

    criminalShot = true
    group:triggerCriminalDeath()
    timeBarWidth = (1 - clock:elapsedSeconds() / Consts.roundDuration) * Consts.screenWidth
    clock:restart()
    targetX, targetY = love.mouse.getPosition()
    explosionX = targetX - Consts.explosionSize / 2
    explosionY = targetY - Consts.explosionSize / 2
    explosionAnimation:restart()
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
    elseif state == "lost" then
        launchGame()
    end
end

local function launchLost()
    state = "lost"
    local score = group.round
    group = nil
    canShoot = true

    local text = ""
    if score > highscore then
        highscore = score
        text = string.format("%02d, new record!", score)
    else
        text = string.format("You got %02d", score)
    end

    texts.lostScore:set(text)
    if buttons.music.on then
        music:stop()
    end
    playSound(sounds.lost)
end

function love.keypressed(key)
    if key ~= "escape" then
        return
    end

    if (state == "menu" or state == "lost") and not onWeb then
        love.event.quit()
    elseif state == "game" then
        state = "menu"
        group = nil
        if buttons.music.on then
            music:stop()
        end
    end
end

function love.update(dt)
    if not onWeb then
        targetX, targetY = love.mouse.getPosition()
    end

    if state ~= "game" then
        return
    end

    if criminalShot and clock:elapsedSeconds() > Consts.deathAnimationDuration then
        if (group.round + 1) % 10 == 0 and lives < Consts.livesMax then
            lives = lives + 1
            heartsQuad[lives] = love.graphics.newQuad(Consts.heartSize, 0, Consts.heartSize, Consts.heartSize, images.heart)
            playSound(sounds.heal)
        end
        group:reset(true, onWeb)
        criminalShot = false
        clock:restart()
    end

    if not criminalShot and clock:elapsedSeconds() > Consts.roundDuration then
        loseLife()
        group:reset(false, onWeb)
        clock:restart()
        playSound(sounds.lost)
    end

    if reloadClock:elapsedSeconds() > Consts.reloadDuration then
        canShoot = true
    end

    group:update(dt, criminalShot)
    explosionAnimation:update()
    if not canDrawExplosion and explosionAnimation:isOver() then
        canDrawExplosion = true
    end

    if not criminalShot then
        timeBarWidth = (1 - clock:elapsedSeconds() / Consts.roundDuration) * Consts.screenWidth
        timeBar.width = timeBarWidth
    end

    if lives == 0 then
        launchLost()
    end
end

local function drawMenu()
    love.graphics.draw(images.logo, (Consts.screenWidth - images.logo:getWidth()) / 2, Consts.screenHeight / 4 - images.logo:getHeight() / 2)
    love.graphics.draw(texts.sub, (Consts.screenWidth - texts.sub:getWidth()) / 2, Consts.screenHeight * 0.75 - texts.sub:getHeight() / 2)

    buttons.sound:draw(images.soundOn, images.soundOff)
    buttons.music:draw(images.musicOn, images.musicOff)
    buttons.colors:draw(images.colorsOn, images.colorsOff)
end

local function drawGame()
    group:draw(images)
    group:drawGui(images)
    group:drawScore()

    for i, quad in ipairs(heartsQuad) do
        local x = 80 + (i - 1) * (5 + Consts.heartSize)
        love.graphics.draw(images.heart, quad, x, Consts.heartY)
    end

    if canDrawExplosion and not explosionAnimation:isOver() then
        love.graphics.draw(images.explosion, explosionAnimation:getCurrentQuad(), explosionX, explosionY)
    end

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

    if onWeb then
        return
    end

    if canShoot then
        love.graphics.draw(images.target, targetX - images.target:getWidth() / 2, targetY - images.target:getHeight() / 2)
    else
        love.graphics.setColor(Colors.black:toRgba())
        love.graphics.draw(images.target, targetX - images.target:getWidth() / 2, targetY - images.target:getHeight() / 2)
        love.graphics.setColor(Colors.white:toRgba())
    end
end

function love.quit()
    if highscore > startHighscore then
        saveHighscore()
    end
end