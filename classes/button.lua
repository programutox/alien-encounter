Button = Object:extend()

function Button:new(x, y)
    self.on = true
    self.rect = Rectangle(x, y, Consts.buttonSize, Consts.buttonSize)
end

local function pointInRect(x, y, rect)
    local rectRight = rect.x + rect.width
    local rectBottom = rect.y + rect.height
    return x >= rect.x and x <= rectRight and y >= rect.y and y <= rectBottom
end

-- No need to implement isClicked
-- Go to love.mousepressed and check if isHovered()
function Button:isHovered()
    local x, y = love.mouse.getPosition()
    return pointInRect(x, y, self.rect)
end

function Button:toggle()
    self.on = not self.on
end

function Button:draw(imageOn, imageOff)
    local image = imageOn
    if not self.on then
        image = imageOff
    end
    love.graphics.draw(image, self.rect.x, self.rect.y)
end