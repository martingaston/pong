Ball = {}
Ball.__index = Ball

function Ball.new()
  local ball = {}
  setmetatable(ball, Ball)
  ball.width = 16
  ball.height = 16
  ball.speed = 120
  ball.dy = love.math.random(-240, 240)
  ball.dx = 120
  ball.x = SCREEN_X*.5 - ball.width*.5
  ball.y = SCREEN_Y*.5 - ball.height*.5
  ball.trails = {}
  ball.particles = love.graphics.newParticleSystem(PARTICLE, 100)
  ball.particles:setParticleLifetime(.1, .2)
  ball.particles:setSizes(6, 1)
  ball.particles:setColors(237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  ball.particles:setSpread(1)
  ball.particles:setSpeed(100)
  ball.score = love.graphics.newParticleSystem(EXPLOSION, 512)
  ball.score:setParticleLifetime(.5, 1)
  ball.score:setSizes(8, 2)
  ball.score:setColors(255 / 255, 51 / 255, 102 / 255, 1, 237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  ball.score:setSpeed(1000)
  ball.score:setSpread(1)
  ball.score:setEmissionRate(512)
  ball.score:setEmitterLifetime(0.25)
  ball.score:stop()
  return ball
end

function Ball:update(dt)
  ball.particles:update(dt)
  ball.score:update(dt)

  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  table.insert(self.trails, { x = self.x, y = self.y })
  if #self.trails > 35 then
    table.remove(self.trails, 1)
  end

  if self.y < 0 then
    self.y = 0
    self.dy = self.dy * -1
  end

  if self.y + self.height > SCREEN_Y then
    self.y = SCREEN_Y - self.height
    self.dy = self.dy * -1
  end
end

function Ball:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.particles, 0, 0)
  love.graphics.draw(self.score, 0, 0)
  love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)

  for i, trail in ipairs(self.trails) do
    local width, height = self.width * i / #self.trails, self.height * i / #self.trails
    love.graphics.setColor(1, 1, 1, i / #self.trails / 10)
    love.graphics.rectangle('fill', trail.x, trail.y, width, height)
  end
end

function Ball:explode(x, y, direction)
  self.score:setPosition(x, y)
  self.score:setDirection(direction)
  self.score:start()
end

function Ball:bounce(x, y, direction)
  self.dx = self.dx * -1
  flux.to(self, 0.1, { dx = self.dx * 3, width = self.width * 1.25, height = self.height * 1.25 }):ease("circout"):after(self, 0.25, { dx = math.min(750, self.dx * 1.25), width = self.width, height = self.height })

  self.particles:setPosition(x, y)
  self.particles:setDirection(direction)
  self.particles:emit(32)
end

function Ball:reset()
  ball.dy = love.math.random(-240, 240)
  ball.dx = self.speed
  ball.x = center(SCREEN_X, ball.width)
  ball.y = center(SCREEN_Y, ball.height)
end
