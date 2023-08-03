AnimationInfo = Object:extend()

function AnimationInfo:new(startRect, framesCount, frameDuration, loop)
    self.startRect = startRect
    self.framesCount = framesCount
    self.frameDuration = frameDuration
    self.loop = loop
end
