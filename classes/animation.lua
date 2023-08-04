require("classes.clock")

Animation = Object:extend()

function Animation:new(animationInfo)
    local startRect = animationInfo.startRect
    local frames = {}

    for i = 0, (animationInfo.framesCount - 1) do
        table.insert(frames, Rectangle(i * startRect.width, startRect.y, startRect.width, startRect.height))
    end

    self.frameDuration = animationInfo.frameDuration
    self.loop = animationInfo.loop
    self.frames = frames
    self.frameIndex = 1
    self.timer = Clock()
end

function Animation:getCurrentFrame()
    local frame = self.frames[self.frameIndex]
    return love.graphics.newQuad(frame.x, frame.y, frame.width, frame.height, frame.width * #self.frames, frame.height * 4)
end

function Animation:isOver()
    return self.timer:elapsedSeconds() > self.frameDuration * #self.frames
end

function Animation:restart()
    self.timer:restart()
end

function Animation:reverse()
    table.sort(self.frames, function (a, b) return a.x > b.x end)
    self:restart()
end

function Animation:update()
    -- Remember: arrays start at 1
    local index = 1 + math.floor(self.timer:elapsedSeconds() / self.frameDuration)
    if index <= #self.frames then
        self.frameIndex = index
    elseif self.loop then
        self:restart()
    end
end
