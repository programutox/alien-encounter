Color = Object:extend()

function RandomColor()
    local index = math.random(1, #Consts.colors)
    return Consts.colors[index]
end

function Color:new(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

function Color:equals(other)
    return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end

function Color:normalized()
    return Color(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
end

Colors = {
    black = Color(0, 0, 0, 255):normalized(),
    white = Color(255, 255, 255, 255):normalized(),
    gray = Color(130, 130, 130, 255):normalized(),
    darkGray = Color(80, 80, 80, 255):normalized(),
    orange = Color(255, 161, 0, 255):normalized(),
}
