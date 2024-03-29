require("classes.alien")

Group = Object:extend()

local function getRandomRoundType(round, colorsOn)
    local roundTypes = { "normal", "size" }
    if round >= 15 then
        table.insert(roundTypes, "accessory")
    end
    if round >= 25 then
        table.insert(roundTypes, "randomBicolor")
    end
    if round >= 35 then
        table.insert(roundTypes, "bicolor")
    end
    if round >= 45 and colorsOn then
        table.insert(roundTypes, "changingColor")
    end
    local index = love.math.random(1, #roundTypes)
    return roundTypes[index]
end

local function newAlien(condition, i, criminalColors, moving, wearAccessories)
    if condition then
        return NewBigAlien(i, criminalColors, moving, wearAccessories)
    else
        return NewLittleAlien(i, criminalColors, moving, wearAccessories)
    end
end

function Group:createNormalRound()
    for i=1, Consts.alien.headcount do
        local alien = newAlien(love.math.random(1, 4) == 1, i, self.criminalColors, self.moving, self.round >= 15)
        while i ~= self.criminalId and alien.colors[1]:equals(self.criminalColors[1]) do
            alien.colors[1] = RandomColor()
        end
        alien:adaptAccessories(alien.colors[1])
        table.insert(self.aliens, alien)
    end
end

function Group:createSizeRound()
    local isCriminalLittle = love.math.random(1, 2) == 1
    for i=1, Consts.alien.headcount do
        local isCriminal = i == self.criminalId
        -- This condition is equivalent to (is_criminal && is_criminal_little) || (!is_criminal && !is_criminal_little)
        local alien = newAlien(isCriminal == isCriminalLittle, i, self.criminalColors, self.moving, self.round >= 15 and love.math.random(1, 2) == 1)
        alien:adaptAccessories(alien.colors[1])
        table.insert(self.aliens, alien)
    end
end

function Group:createAccessoryRound()
    local isCriminalLittle = love.math.random(1, 4) == 1
    local criminal = newAlien(isCriminalLittle, self.criminalId, self.criminalColors, self.moving, true)
    criminal.accessories:createAtLeastOneAccessory()

    for i=1, Consts.alien.headcount do
        if i == self.criminalId then
            table.insert(self.aliens, criminal)
        else
          local alien = newAlien(isCriminalLittle, i, self.criminalColors, self.moving, false)
          alien.accessories = CreateVariantAccessories(criminal.accessories, alien.colors[1])
          table.insert(self.aliens, alien)
        end
    end
end

function Group:createChangingColorRound()
    self.clock = Clock()
    self:createNormalRound()
end

function Group:createRandomBicolorRound()
    table.insert(self.criminalColors, RandomColor())
    for i=1, Consts.alien.headcount do
        local alien = newAlien(love.math.random(1, 4) == 1, i, self.criminalColors, self.moving, self.round)
        while i ~= self.criminalId and (alien:hasSameColors(self.criminalColors) or alien:isSolidColored()) do
            alien:changeColors()
        end
        alien:adaptAccessories(alien.colors[1])
        table.insert(self.aliens, alien)
    end
end

function Group:createBicolorRound()
    repeat
        self.criminalColors[2] = RandomColor()
    until not self.criminalColors[2]:equals(self.criminalColors[1])

    for i=1, Consts.alien.headcount do
        local alien = newAlien(love.math.random(1, 4) == 1, i, self.criminalColors, self.moving, love.math.random(1, 2) == 1)
        if i ~= self.criminalId then
            alien:switchColors()
        end
        alien:adaptAccessories(alien.colors[1])
        table.insert(self.aliens, alien)
    end
end

function Group:new(round, highscore, font, colorsOn, onWeb)
    self.scoreText = love.graphics.newText(font, string.format("%02d/%02d", round, highscore))
    self.highscore = highscore
    self.font = font
    self.round = round

    self.criminalColors = { RandomColor() }
    self.criminalId = love.math.random(1, Consts.alien.headcount)
    self.moving = self.round % 10 >= 5
    self.limitedRange = not onWeb and not self.moving and self.round > 10 and love.math.random(1, 5) == 1
    self.clock = nil
    self.aliens = {}
    self.colorsOn = colorsOn

    local roundType = getRandomRoundType(round, colorsOn)

    if roundType == "normal" then
        self:createNormalRound()
    elseif roundType == "size" then
        self:createSizeRound()
    elseif roundType == "accessory" then
        self:createAccessoryRound()
    elseif roundType == "changingColor" then
        self:createChangingColorRound()
    elseif roundType == "randomBicolor" then
        self:createRandomBicolorRound()
    elseif roundType == "bicolor" then
        self:createBicolorRound()
    else
        error("Got unexpected roundType: " .. roundType, 2)
    end
end

function Group:reset(addRound, onWeb)
    if addRound then
        self:new(self.round + 1, self.highscore, self.font, self.colorsOn, onWeb)
    else
        self:new(self.round, self.highscore, self.font, self.colorsOn, onWeb)
    end
end

function Group:getClickedAliens()
    local result = {}
    for _, alien in ipairs(self.aliens) do
        if alien:isHovered() then
            table.insert(result, alien)
        end
    end
    return result
end

function Group:triggerDeaths()
    for _, alien in ipairs(self.aliens) do
        if alien:isHovered() then
            alien:changeAnimation(Consts.animationInfo.death)
        end
    end
end

function Group:triggerCriminalDeath()
    for _, alien in ipairs(self.aliens) do
        if alien.id == self.criminalId then
            alien:changeAnimation(Consts.animationInfo.criminalDeath)
        end
    end
end

function Group:update(dt, criminalShot)
    for i, alien in ipairs(self.aliens) do
        if alien:isDeathAnimationOver() then
            table.remove(self.aliens, i)
        else
            alien:update(self.moving, dt)
        end
    end

    if not self.clock then
        return
    end

    -- * This triggers a non-wanted behavior, but it looks cool (not for epileptic tho). 
    if self.clock:elapsedSeconds() < 0.5 and not criminalShot then
        return
    end

    self.criminalColors[1] = RandomColor()
    for i, alien in ipairs(self.aliens) do
        if i == self.criminalId then
            alien:changeSolidColor(self.criminalColors[1])
            alien:adaptAccessories(alien.colors[1])
        else
          repeat
              alien:changeSolidColor(RandomColor())
          until not alien.colors[1]:equals(self.criminalColors[1])
          alien:adaptAccessories(alien.colors[1])
        end
    end
    self.clock:restart()
end

function Group:draw(images)
    love.graphics.draw(images.sun, -images.sun:getWidth() / 2, -images.sun:getHeight() / 2)

    --- In for loops like this, since alien is a table, the variable is a reference.
    --- No need to use self.aliens[i].
    for _, alien in ipairs(self.aliens) do
        alien:draw(images)
    end

    if not self.limitedRange then
        return
    end

    local x, y = love.mouse.getPosition()
    Rectangle(0, 0, x - Consts.borderRadius, Consts.screenHeight):draw(Consts.borderColor)
    Rectangle(x - Consts.borderRadius, 0, Consts.borderRadius * 2, y - Consts.borderRadius):draw(Consts.borderColor)
    Rectangle(x - Consts.borderRadius, y + Consts.borderRadius, Consts.borderRadius * 2, Consts.screenHeight):draw(Consts.borderColor)
    Rectangle(x + Consts.borderRadius, 0, Consts.screenWidth - x + Consts.borderRadius, Consts.screenHeight):draw(Consts.borderColor)

    love.graphics.setColor(Consts.borderColor:toRgba())
    love.graphics.draw(images.border, x - Consts.borderRadius, y - Consts.borderRadius)
    love.graphics.setColor(Colors.white:toRgba())
end

function Group:drawGui(images)
    Consts.gui.rect:draw(Colors.gray)

    for _, alien in ipairs(self.aliens) do
        if alien.id == self.criminalId then
            alien:drawGui(images)
            break
        end
    end
end

function Group:drawScore()
    love.graphics.draw(
        self.scoreText,
        Consts.screenWidth - self.scoreText:getWidth() - Consts.offset,
        Consts.gui.rect.y + (Consts.gui.height - self.scoreText:getHeight()) / 2
    )
end
