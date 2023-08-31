AccessoryColor = Object:extend()

function AccessoryColor:new(reversable, optionalColor)
    self.reversable = reversable
    self.optionalColor = optionalColor
end

function AccessoryColor:equals(other)
    return self.reversable == other.reversable and ((self.optionalColor == nil and other.optionalColor == nil) or self.optionalColor:equals(other.optionalColor))
end

local function newOptionalColor()
    if math.random(1, 3) == 1 then
        return RandomColor()
    else
        return nil
    end
end

Accessories = Object:extend()

function Accessories:new()
    self.colors = {}
    self.guiQuad = love.graphics.newQuad(0, 0, Consts.alien.frameWidth, Consts.alien.frameHeight, Consts.alien.imageWidth, Consts.alien.imageHeight)
end

function CreateVariantAccessories(other, alienColor)
    local result = Accessories()
    for tag, accessoryColor in pairs(other.colors) do
        if accessoryColor.optionalColor then
            repeat
                result.colors[tag] = AccessoryColor(accessoryColor.reversable, RandomColor())
            until not (result.colors[tag].optionalColor:equals(accessoryColor.optionalColor) or result.colors[tag].optionalColor:equals(alienColor))
        else
            result.colors[tag] = AccessoryColor(accessoryColor.reversable, nil)
        end
    end
    return result
end

function Accessories:add(tag, reversable)
    self.colors[tag] = AccessoryColor(reversable, newOptionalColor())
end

local function mapLength(map)
    local count = 0
    for _, _ in pairs(map) do
        count = count + 1
    end
    return count
end

local function nthKey(map, n)
    local i = 1
    for k, _ in pairs(map) do
        if i == n then
            return k
        end
        i = i + 1
    end
    return nil
end

function Accessories:createAtLeastOneAccessory()
    local index = math.random(1, mapLength(self.colors))
    local key = nthKey(self.colors, index)
    if not key then
        error("Tried to get a key map from an invalid index", 2)
    end
    self.colors[key] = AccessoryColor(self.colors[key].reversable, RandomColor())
end

function Accessories:equals(other)
    for i, accessoryColor in ipairs(other.colors) do
        if not self.colors[i]:equals(accessoryColor) then
            return false
        end
    end
    return true
end

function Accessories:adapt(alienColor)
    for _, accessoryColor in pairs(self.colors) do
        if accessoryColor.optionalColor then
            while accessoryColor.optionalColor:equals(alienColor) do
                accessoryColor.optionalColor = RandomColor()
            end
            accessoryColor.optionalColor = accessoryColor.optionalColor
        end
    end
end

function Accessories:changeColors(alienColor)
    for _, accessoryColor in pairs(self.colors) do
        if accessoryColor.optionalColor then
            accessoryColor.optionalColor = RandomColor()
        end
    end
    self:adapt(alienColor)
end

function Accessories:draw(images, quad, orientationX, x, y, scale)
    for tag, accessoryColor in pairs(self.colors) do
        local color = accessoryColor.optionalColor
        if color then
            love.graphics.setColor(color:toRgba())
            love.graphics.draw(images[tag], quad, x, y, 0, orientationX * scale, scale)
            love.graphics.setColor(Colors.white:toRgba())
        end
    end
end

function Accessories:drawGui(images, x, y, scale)
    for tag, accessoryColor in pairs(self.colors) do
        local color = accessoryColor.optionalColor
        if color then
            love.graphics.setColor(color:toRgba())
            love.graphics.draw(images[tag], self.guiQuad, x, y, 0, scale, scale)
            love.graphics.setColor(Colors.white:toRgba())
        end
    end
end
