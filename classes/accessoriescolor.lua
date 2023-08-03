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
    if math.random(1, 10) == 1 then
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
    if key == nil then
        error("Tried to get a key map from an invalid index", 2)
    end
    self.colors[key] = AccessoryColor(self.colors[key].reversable, randomColor())
end

function AccessoriesColor:adaptColor(alienColor)
    for _, accessoryColor in pairs(self.colors) do
        local color = accessoryColor
        while color:equals(alienColor) do
            print()
        end
    end
end
