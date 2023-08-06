Color = Object:extend()

function RandomColor()
    local index = math.random(1, #Consts.colors)
    local result = Consts.colors[index]
    return result
end

function Color:new(r, g, b, a)
    self.r = r / 255
    self.g = g / 255
    self.b = b / 255
    self.a = a / 255
end

function Color:toRgba()
    return self.r, self.g, self.b, self.a
end

-- As r, g, b and a attributes are floats, you cannot have true equality.
-- We want to check if self attributes and other attributes are *approximately* equal.
function Color:equals(other)
    return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

Colors = {
    black = Color(0, 0, 0, 255),
    white = Color(255, 255, 255, 255),
    gray = Color(130, 130, 130, 255),
    darkGray = Color(80, 80, 80, 255),
    orange = Color(255, 161, 0, 255),
}
