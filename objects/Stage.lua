--
-- Created by IntelliJ IDEA.
-- User: seletz
-- Date: 20.02.18
-- Time: 22:11
-- To change this template use File | Settings | File Templates.
--

Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.main_canvas = love.graphics.newCanvas(gw, gh)

    self.timer = Timer()

    self.timer:every(0.3, function()
        local x = love.math.random(0,gw)
        local y = love.math.random(0,gh)
        local r = love.math.random(0,gw / 10)
        local c = self.area:addGameObject('Circle', x, y, {radius = r})
        self.area:dump()
    end, 10)

end

function Stage:update(dt)
    self.timer:update(dt)
    self.area:update(dt)
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
    self.area:draw()
    love.graphics.setCanvas()

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
    love.graphics.setBlendMode('alpha')
end

