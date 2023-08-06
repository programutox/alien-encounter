require("classes.alien")

Group = Object:extend()

local function getRandomRoundType(round)
    local roundTypes = { "normal", "size" }
    if round >= 15 then
        table.insert(roundTypes, "accessory")
    end
    local index = math.random(1, #roundTypes)
    return roundTypes[index]
end

local function newAlien(condition, i, criminalColor, moving, round)
    if condition then
        return NewBigAlien(i, criminalColor, moving, round)
    else
        return NewLittleAlien(i, criminalColor, moving, round)
    end
end

function Group:createNormalRound(round)
    self.criminalColor = RandomColor()
    self.round = round
    self.criminalId = math.random(1, Consts.alien.headcount)
    self.moving = round % 10 >= 5
    self.limitedRange = not self.moving and round > 10 and math.random(1, 4) == 1
    self.aliens = {}

    for i=1, Consts.alien.headcount do
        local alien = newAlien(math.random(1, 4) == 1, i, self.criminalColor, self.moving, round)
        while i ~= self.criminalId and alien.color:equals(self.criminalColor) do
            alien.color = RandomColor()
        end
        alien.accessories:adapt(alien.color)
        table.insert(self.aliens, alien)
    end
end

function Group:new(round)
    local roundType = getRandomRoundType(round)
    -- TODO Remove the line below later
    roundType = "normal"

    if roundType == "normal" then
        self:createNormalRound(round)
    end
end

function Group:reset(addRound)
    if addRound then
        self:new(self.round + 1)
    else
        self:new(self.round)
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
