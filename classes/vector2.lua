Vector2 = Object:extend()

-- * Note to myself: when instantiating a class, use Vector2(x, y), not Vector2:new(x, y)
-- * This will avoid debugging for minutes about why the program indexed nil
function Vector2:new(x, y)
    self.x = x
    self.y = y
end
