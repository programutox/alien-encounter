AnimationInfo = Object:extend()

function AnimationInfo:new(startRect, framesCount, frameDuration, loop, imageWidth, imageHeight)
    self.startRect = startRect
    self.framesCount = framesCount
    self.frameDuration = frameDuration
    self.loop = loop
    self.imageWidth = imageWidth
    self.imageHeight = imageHeight
end
