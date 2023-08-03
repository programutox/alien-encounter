Rectangle = Object:extend()

function Rectangle:new(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function Rectangle:draw(r, g, b)
    love.graphics.setColor(r, g, b)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end
