-- require("classes.color")
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
        self = Group(self.round + 1)
    else
        self = Group(self.round)
    end
end

function Group:update(dt)
    -- TODO Add death
    for i, _ in ipairs(self.aliens) do
        self.aliens[i]:update(self.moving, dt)
    end
end

function Group:draw(images)
    love.graphics.draw(images.sun, -images.sun:getWidth() / 2, -images.sun:getHeight() / 2)
    for i, _ in ipairs(self.aliens) do
        self.aliens[i]:draw(images)
    end

    -- TODO Add draw borders
end

function Group:drawGui(images)
    for i, _ in ipairs(self.aliens) do
        if i == self.criminalId then
            self.aliens[i]:drawGui(images)
            break
        end
    end
end
