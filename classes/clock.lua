Clock = Object:extend()

function Clock:new()
    self.instant = love.timer.getTime()
end

function Clock:elapsedSeconds()
    return love.timer.getTime() - self.instant
end

function Clock:restart()
    self.instant = love.timer.getTime()
end
