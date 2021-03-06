--
-- Created by IntelliJ IDEA.
-- User: seletz
-- Date: 21.02.18
-- Time: 19:13
-- To change this template use File | Settings | File Templates.
--

Boost = GameObject:extend()

function Boost:new(area, x, y, opts)
    Boost.super.new(self, area, x, y, opts)

    local direction = utils.table.random({-1, 1})
    self.x = gw/2 + direction*(gw/2 + 48)
    self.y = utils.random(48, gh - 48)

    self.color = opts.color or colors.boost_color

    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction*utils.random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(utils.random(-24, 24))
end

function Boost:destroy()
    Boost.super.destroy(self)
end

function Boost:die()
    self.dead = true
    self.area:addGameObject('BoostEffect', self.x, self.y,
        {color = colors.boost_color, w = self.w, h = self.h, r = self.r})

    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {s = 3, color = colors.boost_color})
    end

    self.area:addGameObject('InfoText',
        self.x + utils.random(-self.w, self.w),
        self.y + utils.random(-self.h, self.h),
        {text = '+BOOST', color = colors.boost_color})
end

function Boost:update(dt)
    Boost.super.update(self, dt)
end

function Boost:draw()
    love.graphics.setColor(self.color)
    utils.pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, 1.5*self.w, 1.5*self.h, 'line')
    draft:rhombus(self.x, self.y, 0.5*self.w, 0.5*self.h, 'fill')
    love.graphics.pop()
    love.graphics.setColor(colors.default_color)
end


