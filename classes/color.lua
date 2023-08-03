Color = Object:extend()

function Color:new(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

function Color:equals(other)
    return self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a
end
