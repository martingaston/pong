Paddle = {}
Paddle.__index = Paddle

function Paddle.new(x, y, width, height, speed, moveUpKey, moveDownKey)
  local paddle = {}
  setmetatable(paddle, Paddle)
  paddle.width = width
  paddle.height = height
  paddle.y = y
  paddle.x = x
  paddle.speed = speed
  paddle.score = 0

  paddle.moveUpKey = moveUpKey
  paddle.moveDownKey = moveDownKey

  paddle.particles = love.graphics.newParticleSystem(PARTICLE, 100)
  paddle.particles:setParticleLifetime(.1, .2)
  paddle.particles:setSizes(6, 1)
  paddle.particles:setEmissionRate(128)
  paddle.particles:setSpread(1)
  paddle.particles:setSpin(1, 15)
  paddle.particles:setColors(237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  paddle.particles:stop()

  return paddle
end

function Paddle:update(dt)
  self.particles:update(dt)
  if love.keyboard.isDown(self.moveUpKey) then
    self.y = math.max(0, self.y - self.speed * dt)
    self.particles:setPosition(self.x + self.width*.5, self.y + self.height)
    self.particles:setDirection(math.pi/2)
    self.particles:setSpeed(800)
    self.particles:start()
  elseif love.keyboard.isDown(self.moveDownKey) then
    self.y = math.min(SCREEN_Y - self.height, self.y + self.speed * dt)
    self.particles:setPosition(self.x+self.width*.5, self.y+(dir == -1 and self.height or 0))
    self.particles:setDirection(3 * math.pi / 2)
    self.particles:setSpeed(800)
    self.particles:start()
  else
    self.particles:stop()
  end
end

function Paddle:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.particles, 0, 0)
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
end
