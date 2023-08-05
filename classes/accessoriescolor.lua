AccessoryColor = Object:extend()

function AccessoryColor:new(reversable, optionalColor)
    self.reversable = reversable
    self.optionalColor = optionalColor
end

local function randomColor()
    local index = math.random(1, #Consts.colors)
    return Consts.colors[index]
end

local function newOptionalColor()
    if math.random(1, 3) == 1 then
        return randomColor()
    else
        return nil
    end
end

AccessoriesColor = Object:extend()

function AccessoriesColor:new()
    self.colors = {}
end

function AccessoriesColor:from(other)
    self.colors = {}
    for k, color in pairs(other.colors) do
        self.colors[k] = color
    end
end

function AccessoriesColor:add(tag, reversable)
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

function AccessoriesColor:createAtLeastOneAccessory()
    local index = math.random(1, mapLength(self.colors))
    local key = nthKey(self.colors, index)
    if not key then
        error("Tried to get a key map from an invalid index", 2)
    end
    self.colors[key] = AccessoryColor(self.colors[key].reversable, randomColor())
end

function AccessoriesColor:adapt(alienColor)
    for _, accessoryColor in pairs(self.colors) do
        local color = accessoryColor
        while color:equals(alienColor) do
            print()
        end
    end
end

function AccessoriesColor:change(alienColor)
    for _, accessoryColor in pairs(self.colors) do
        if accessoryColor.optionalColor then
            accessoryColor.optionalColor = randomColor()
        end
    end
    self:adapt(alienColor)
end

function AccessoriesColor:draw(images, quad, orientationX, x, y, scale)
    for tag, accessoryColor in pairs(self.colors) do
        if accessoryColor.optionalColor then
            love.graphics.draw(images[tag], quad, x, y, 0, orientationX * scale, scale)
        end
    end
end

function AccessoriesColor:drawGui(images, x, y, scale)
    for tag, accessoryColor in pairs(self.colors) do
        if accessoryColor.optionalColor then
            -- TODO: put that quad inside constructor
            love.graphics.draw(images[tag], Consts.animationInfo.idle.startRect:toQuad(), x, y, 0, scale, scale)
        end
    end
end
