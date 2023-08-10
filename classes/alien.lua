require("classes.rectangle")
require("classes.animation")
require("classes.accessories")

Alien = Object:extend()

local function getRandomOrientation()
    if math.random(0, 1) == 0 then
        return 1
    else
        return -1
    end
end

function Alien:new(i, criminalColors, moving, rect, guiX, guiY, scale, speed, round)
    -- self.colors = { criminalColors[1] }
    -- if #criminalColors == 2 then
    --     table.insert(self.colors, criminalColors[2])
    -- end
    -- self.colors = criminalColors
    -- self.guiColors = criminalColors
    self.colors = {}
    self.guiColors = {}
    for j, color in ipairs(criminalColors) do
        self.colors[j] = CloneColor(color)
        self.guiColors[j] = CloneColor(color)
    end

    -- self.guiColors = { criminalColors[1] }
    -- if #criminalColors == 2 then
    --     table.insert(self.guiColors, criminalColors[2])
    -- end
    -- self.guiColors = criminalColors

    local orientationX, orientationY = 1, 1
    if moving then
        orientationX, orientationY = getRandomOrientation(), getRandomOrientation()
    end
    local animationInfo = Consts.animationInfo.idle
    if moving then
        animationInfo = Consts.animationInfo.move
    end

    self.animation = Animation(animationInfo)
    if moving and orientationX < 0 then
        -- No need to reverse the animation
        -- Even when flipped, it will be drawn in the correct order, but the origin becomes top right
        rect.x = rect:right()
        self:switchColors()
    end

    self.accessories = Accessories()

    if round >= 10 then
        self.accessories:add("monocle", false)
        self.accessories:add("helmet", false)
        self.accessories:add("shoes", true)
    end

    self.id = i
    self.guiX = guiX
    self.guiY = guiY
    self.orientationX = orientationX
    self.orientationY = orientationY
    self.scale = scale
    self.rect = rect
    self.speed = speed
end

function NewBigAlien(i, criminalColors, moving, round)
    local x = Consts.offset + ((i - 1) % Consts.alien.perRows) * (Consts.alien.width + Consts.offset)
    local y = Consts.offset + math.floor((i - 1) / Consts.alien.perColumns) * (Consts.alien.height + Consts.offset)
    local rect = Rectangle(x, y, Consts.alien.width, Consts.alien.height)
    return Alien(i, criminalColors, moving, rect, Consts.gui.alienX, Consts.gui.alienY, Consts.alien.scale, Consts.alien.speed, round)
end

function NewLittleAlien(i, criminalColors, moving, round)
    local x = Consts.offset + ((i - 1) % Consts.alien.perRows) * (Consts.alien.width + Consts.offset) + Consts.littleAlienOffsetX
    local y = Consts.offset + math.floor((i - 1) / Consts.alien.perColumns) * (Consts.alien.height + Consts.offset) + Consts.littleAlienOffsetY
    local rect = Rectangle(x, y, Consts.littleAlien.width, Consts.littleAlien.height)
    return Alien(i, criminalColors, moving, rect, Consts.gui.littleAlienX, Consts.gui.littleAlienY, Consts.littleAlien.scale, Consts.littleAlien.speed, round)
end

local function pointInRect(x, y, rect)
    return x >= rect.x and x <= rect:right() and y >= rect.y and y <= rect:bottom()
end

function Alien:isHovered()
    local x, y = love.mouse.getPosition()
    return pointInRect(x, y, self.rect)
end

function Alien:isUnicolor()
    return self.colors[1]:equals(self.colors[2])
end

function Alien:hasSameColors(c)
    return self.colors[1]:equals(c[1]) and self.colors[2]:equals(c[2]) or self.colors[1]:equals(c[2]) and self.colors[2]:equals(c[1])
end

function Alien:getGuiRect()
    return Rectangle(self.guiX, self.guiY, self.rect.width, self.rect.height)
end

function Alien:getCurrentQuad()
    return self.animation:getCurrentQuad()
end

function Alien:isDeathAnimationOver()
    return not self.animation.loop and self.animation:isOver()
end

function Alien:switchColors()
    if #self.colors == 2 then
        self.colors[1], self.colors[2] = self.colors[2], self.colors[1]
    end
end

function Alien:changeColors()
    self.colors = { RandomColor(), RandomColor() }
    self.guiColors = { self.colors[1], self.colors[2] }
end

function Alien:changeAnimation(animationInfo)
    self.animation = Animation(animationInfo)
    self.orientationX = 1
end

function Alien:adaptAccessories()
    self.accessories:adapt(self.colors[1])
end

function Alien:updateMovement(dt)
    self.rect.x = self.rect.x + self.orientationX * self.speed * dt
    self.rect.y = self.rect.y + self.orientationY * self.speed * dt

    if self.rect.x < 0 then
        self.rect.x = 0
        self.orientationX = -self.orientationX
        self:switchColors()
    elseif self.rect.x > Consts.screenWidth - self.rect.width then
        self.rect.x = Consts.screenWidth - self.rect.width
        self.orientationX = -self.orientationX
        self:switchColors()
    end

    if self.rect.y < 0 then
        self.rect.y = 0
        self.orientationY = -self.orientationY
    elseif self.rect.y > Consts.screenHeight - self.rect.height - Consts.gui.height then
        self.rect.y = Consts.screenHeight - self.rect.height - Consts.gui.height
        self.orientationY = -self.orientationY
    end
end

function Alien:update(moving, dt)
    self.animation:update()
    if self.animation.loop and moving then
        self:updateMovement(dt)
    end
end

-- No shadow, we don't need it
function Alien:draw(images)
    local offsetX = 0
    if self.orientationX < 0 then
        offsetX = self.rect.width
    end
    local quad = self:getCurrentQuad()
    love.graphics.setColor(self.colors[1]:toRgba())
    if #self.colors == 1 then
        love.graphics.draw(images.alien, quad, self.rect.x + offsetX, self.rect.y, 0, self.orientationX * self.scale, self.scale)
    else
        love.graphics.draw(images.alienLeft, quad, self.rect.x + offsetX, self.rect.y, 0, self.orientationX * self.scale, self.scale)
        love.graphics.setColor(self.colors[2]:toRgba())
        love.graphics.draw(images.alienRight, quad, self.rect.x + offsetX, self.rect.y, 0, self.orientationX * self.scale, self.scale)
    end
    love.graphics.setColor(Colors.white:toRgba())

    if self.colors[1]:equals(Colors.black) or self.colors[2] and self.colors[2]:equals(Colors.black) then
        love.graphics.setColor(Colors.gray:toRgba())
        love.graphics.draw(images.eye, quad, self.rect.x + offsetX, self.rect.y, 0, self.orientationX * self.scale, self.scale)
        love.graphics.setColor(Colors.white:toRgba())
    end

    self.accessories:draw(images, quad, self.orientationX, self.rect.x + offsetX, self.rect.y, self.scale)
end

function Alien:drawGui(images)
    local destRect = self:getGuiRect()
    local quad = Consts.animationInfo.idle.startRect:toQuad(Consts.alien.imageWidth, Consts.alien.imageHeight)

    love.graphics.setColor(self.guiColors[1]:toRgba())
    if #self.guiColors == 1 then
        love.graphics.draw(images.alien, quad, destRect.x, destRect.y, 0, self.scale, self.scale)
    else
        love.graphics.draw(images.alienLeft, quad, destRect.x, destRect.y, 0, self.scale, self.scale)
        love.graphics.setColor(self.guiColors[2]:toRgba())
        love.graphics.draw(images.alienRight, quad, destRect.x, destRect.y, 0, self.scale, self.scale)
    end
    love.graphics.setColor(Colors.white:toRgba())

    if self.guiColors[1]:equals(Colors.black) or self.guiColors[2] and self.guiColors[2]:equals(Colors.black) then
        love.graphics.setColor(Colors.gray:toRgba())
        love.graphics.draw(images.eye, quad, destRect.x, destRect.y, 0, self.scale, self.scale)
        love.graphics.setColor(Colors.white:toRgba())
    end

    self.accessories:drawGui(images, destRect.x, destRect.y, self.scale)
end
