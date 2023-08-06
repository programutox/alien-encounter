require("classes.rectangle")
require("classes.animation")
require("classes.accessoriescolor")

Alien = Object:extend()

local function getRandomOrientation()
    if math.random(0, 1) == 0 then
        return 1
    else
        return -1
    end
end

function Alien:new(i, criminalColor, moving, rect, guiX, guiY, scale, speed, round)
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
    end

    self.accessoriesColor = AccessoriesColor()

    if round >= 10 then
        self.accessoriesColor:add("monocle", false)
        self.accessoriesColor:add("helmet", false)
        self.accessoriesColor:add("shoes", true)
    end

    self.id = i
    self.guiX = guiX
    self.guiY = guiY
    self.orientationX = orientationX
    self.orientationY = orientationY
    self.scale = scale
    self.color = criminalColor
    self.rect = rect
    self.speed = speed
end

function NewBigAlien(i, criminalColor, moving, round)
    -- consts.offset + (i % consts.alien_per_rows) * (consts.alien_width + consts.offset)
    local x = Consts.offset + ((i - 1) % Consts.alien.perRows) * (Consts.alien.width + Consts.offset)
    local y = Consts.offset + math.floor((i - 1) / Consts.alien.perColumns) * (Consts.alien.height + Consts.offset)
    local rect = Rectangle(x, y, Consts.alien.width, Consts.alien.height)
    return Alien(i, criminalColor, moving, rect, Consts.gui.alienX, Consts.gui.alienY, Consts.alien.scale, Consts.alien.speed, round)
end

function NewLittleAlien(i, criminalColor, moving, round)
    local x = Consts.offset + ((i - 1) % Consts.alien.perRows) * (Consts.alien.width + Consts.offset) + Consts.littleAlienOffsetX
    local y = Consts.offset + math.floor((i - 1) / Consts.alien.perColumns) * (Consts.alien.height + Consts.offset) + Consts.littleAlienOffsetY
    local rect = Rectangle(x, y, Consts.littleAlien.width, Consts.littleAlien.height)
    return Alien(i, criminalColor, moving, rect, Consts.gui.littleAlienX, Consts.gui.littleAlienY, Consts.littleAlien.scale, Consts.littleAlien.speed, round)
end

local function pointInRect(x, y, rect)
    return x >= rect.x and x <= rect:right() and y >= rect.y and y <= rect:bottom()
end

function Alien:isHovered()
    local x, y = love.mouse.getPosition()
    return pointInRect(x, y, self.rect)
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

function Alien:changeAnimation(animationInfo)
    self.animation = Animation(animationInfo)
    self.orientationX = 1
end

function Alien:adaptAccessoriesColor()
    self.accessoriesColor:adapt(self.color)
end

function Alien:flipHorizontally()
    self.orientationX = -self.orientationX
	self.animation:reverse()
end

function Alien:updateMovement(dt)
    self.rect.x = self.rect.x + self.orientationX * self.speed * dt
    self.rect.y = self.rect.y + self.orientationY * self.speed * dt

    if self.rect.x < 0 then
        self.rect.x = 0
        self:flipHorizontally()
    elseif self.rect.x > Consts.screenWidth - self.rect.width then
        self.rect.x = Consts.screenWidth - self.rect.width
        self:flipHorizontally()
    end

    if self.rect.y < 0 then
        self.rect.y = 0
        self.orientationY = -self.orientationY
    elseif self.rect.x > Consts.screenWidth - self.rect.width then
        self.rect.x = Consts.screenWidth - self.rect.width
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
    local quad = self:getCurrentQuad()
    love.graphics.setColor(self.color:toRgba())
    love.graphics.draw(images.alien, quad, self.rect.x, self.rect.y, 0, self.orientationX * self.scale, self.scale)
    love.graphics.setColor(Colors.white:toRgba())

    if self.color:equals(Colors.black) then
        love.graphics.setColor(Colors.gray:toRgba())
        love.graphics.draw(images.eye, quad, self.rect.x, self.rect.y, 0, self.orientationX * self.scale, self.scale)
        love.graphics.setColor(Colors.white:toRgba())
    end

    self.accessoriesColor:draw(images, quad, self.orientationX, self.rect.x, self.rect.y, self.scale)
end

function Alien:drawGui(images)
    local destRect = self:getGuiRect()
    local quad = Consts.animationInfo.idle.startRect:toQuad(Consts.alien.imageWidth, Consts.alien.imageHeight)

    love.graphics.setColor(self.color:toRgba())
    love.graphics.draw(images.alien, quad, destRect.x, destRect.y, 0, self.scale, self.scale)
    love.graphics.setColor(Colors.white:toRgba())

    if self.color:equals(Colors.black) then
        love.graphics.setColor(Colors.gray:toRgba())
        love.graphics.draw(images.eye, quad, destRect.x, destRect.y, 0, self.scale, self.scale)
        love.graphics.setColor(Colors.white:toRgba())
    end

    self.accessoriesColor:drawGui(images, destRect.x, destRect.y, self.scale)
end
