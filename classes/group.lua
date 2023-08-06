require("classes.alien")

Group = Object:extend()

local function getRandomRoundType(round)
    -- local roundTypes = { "normal", "size" }
    -- if round >= 15 then
    --     table.insert(roundTypes, "accessory")
    -- end
    -- local index = math.random(1, #roundTypes)
    -- return roundTypes[index]
    return "accessory"
end

local function newAlien(condition, i, criminalColor, moving, round)
    if condition then
        return NewBigAlien(i, criminalColor, moving, round)
    else
        return NewLittleAlien(i, criminalColor, moving, round)
    end
end

function Group:createNormalRound()
    for i=1, Consts.alien.headcount do
        local alien = newAlien(math.random(1, 4) == 1, i, self.criminalColor, self.moving, self.round)
        while i ~= self.criminalId and alien.color:equals(self.criminalColor) do
            alien.color = RandomColor()
        end
        alien.accessories:adapt(alien.color)
        table.insert(self.aliens, alien)
    end
end

function Group:createSizeRound()
    local isCriminalLittle = math.random(1, 2) == 1
    for i=1, Consts.alien.headcount do
        local isCriminal = i == self.criminalId
        -- This condition is equivalent to (is_criminal && is_criminal_little) || (!is_criminal && !is_criminal_little)
        local alien = newAlien(isCriminal == isCriminalLittle, i, self.criminalColor, self.moving, self.round)
        alien.accessories:adapt(alien.color)
        table.insert(self.aliens, alien)
    end
end

function Group:createAccessoryRound()
    local isCriminalLittle = math.random(1, 4) == 1
    local criminal = newAlien(isCriminalLittle, self.criminalId, self.criminalColor, self.moving, self.round)
    criminal.accessories:createAtLeastOneAccessory()

    for i=1, Consts.alien.headcount do
        if i == self.criminalId then
            table.insert(self.aliens, criminal)
            goto continue
        end

        local alien = newAlien(isCriminalLittle, i, self.criminalColor, self.moving, self.round)
        alien.accessories = CreateVariantAccessories(criminal.accessories, alien.color)
        table.insert(self.aliens, alien)
        ::continue::
    end
end

function Group:new(round, highscore, font)
    self.scoreText = love.graphics.newText(font, string.format("%02d/%02d", round, highscore))
    self.highscore = highscore
    self.font = font
    self.round = round

    self.criminalColor = RandomColor()
    self.criminalId = math.random(1, Consts.alien.headcount)
    self.moving = self.round % 10 >= 5
    -- self.limitedRange = not self.moving and self.round > 10 and math.random(1, 5) == 1
    self.limitedRange = false
    self.aliens = {}

    local roundType = getRandomRoundType(round)

    if roundType == "normal" then
        self:createNormalRound()
    elseif roundType == "size" then
        self:createSizeRound()
    elseif roundType == "accessory" then
        self:createAccessoryRound()
    end
end

function Group:reset(addRound)
    if addRound then
        self:new(self.round + 1, self.highscore, self.font)
    else
        self:new(self.round, self.highscore, self.font)
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

function Group:update(dt)
    for i, alien in ipairs(self.aliens) do
        if alien:isDeathAnimationOver() then
            table.remove(self.aliens, i)
        else
            alien:update(self.moving, dt)
        end
    end
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
