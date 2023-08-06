AccessoryColor = Object:extend()

function AccessoryColor:new(reversable, optionalColor)
    self.reversable = reversable
    self.optionalColor = optionalColor
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
end

function Accessories:from(other)
    self.colors = {}
    for k, color in pairs(other.colors) do
        self.colors[k] = color
    end
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

function Accessories:adapt(alienColor)
    for i, accessoryColor in pairs(self.colors) do
        if not accessoryColor.optionalColor then
            goto continue
        end

        while accessoryColor.optionalColor:equals(alienColor) do
            accessoryColor.optionalColor = RandomColor()
        end
        accessoryColor.optionalColor = accessoryColor.optionalColor
        ::continue::
    end
end

function Accessories:change(alienColor)
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
            -- TODO: put that quad inside constructor
            love.graphics.draw(images[tag], Consts.animationInfo.idle.startRect:toQuad(images[tag]:getWidth(), images[tag]:getHeight()), x, y, 0, scale, scale)
            love.graphics.setColor(Colors.white:toRgba())
        end
    end
end
