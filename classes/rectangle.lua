Rectangle = Object:extend()

function Rectangle:new(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function Rectangle:toQuad(refWidth, refHeight)
    return love.graphics.newQuad(self.x, self.y, self.width, self.height, refWidth, refHeight)
end

function Rectangle:draw(r, g, b)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

function Rectangle:right()
    return self.x + self.width
end

function Rectangle:bottom()
    return self.y + self.height
end
