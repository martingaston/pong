require 'constants'
require 'dependencies'

function love.load()
  love.window.setTitle("PONG")
  love.math.setRandomSeed(os.time())

  particle = love.graphics.newCanvas(2, 6)
  love.graphics.setCanvas(particle)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', 0, 0, 2, 10)
  love.graphics.setCanvas()

  score = {}
  score.graphic = love.graphics.newCanvas(16, 16)
  love.graphics.setCanvas(score.graphic)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.rectangle('fill', 0, 0, 16, 16)
  love.graphics.setCanvas()

  score.particles = love.graphics.newParticleSystem(particle, 512)
  score.particles:setParticleLifetime(.5, 1)
  score.particles:setSizes(8, 2)
  score.particles:setColors(255 / 255, 51 / 255, 102 / 255, 1, 237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  score.particles:setSpeed(1000)
  score.particles:setSpread(1)
  score.particles:setEmissionRate(512)
  score.particles:setEmitterLifetime(0.25)
  score.particles:stop()

  playerOne = {}
  playerOne.width = 10
  playerOne.height = 90
  playerOne.y = SCREEN_Y*.5 - playerOne.height*.5
  playerOne.x = 20
  playerOne.speed = 1200
  playerOne.score = 0

  playerOne.particles = love.graphics.newParticleSystem(particle, 100)
  playerOne.particles:setParticleLifetime(.1, .2)
  playerOne.particles:setSizes(6, 1)
  playerOne.particles:setEmissionRate(128)
  playerOne.particles:setSpread(1)
  playerOne.particles:setSpin(1, 15)
  playerOne.particles:setColors(237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  playerOne.particles:stop()

  playerTwo = {}
  playerTwo.width = 10
  playerTwo.height = 90
  playerTwo.y = SCREEN_Y*.5 - playerTwo.height*.5
  playerTwo.x = SCREEN_X - playerTwo.width - 20
  playerTwo.speed = 1200
  playerTwo.score = 0

  playerTwo.particles = love.graphics.newParticleSystem(particle, 100)
  playerTwo.particles:setParticleLifetime(.1, .2)
  playerTwo.particles:setSizes(6, 1)
  playerTwo.particles:setEmissionRate(128)
  playerTwo.particles:setSpread(1)
  playerTwo.particles:setSpin(1, 15)
  playerTwo.particles:setColors(237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  playerTwo.particles:stop()

  ball = {}
  ball.width = 16
  ball.height = 16
  ball.speed = 120
  ball.dy = love.math.random(-240, 240)
  ball.dx = 120
  ball.x = SCREEN_X*.5 - ball.width*.5
  ball.y = SCREEN_Y*.5 - ball.height*.5

  ball.particles = love.graphics.newParticleSystem(particle, 100)
  ball.particles:setParticleLifetime(.1, .2)
  ball.particles:setSizes(6, 1)
  ball.particles:setColors(237 / 255, 119 / 255, 16 / 255, .5, 237 / 255, 119 / 255, 16 / 255, 0)
  ball.particles:setSpread(1)
  ball.particles:setSpeed(100)
  ball.trails = {}

  shake = 3

  divider = {}
  divider.width = 10
  divider.height = 10

  shack:setDimensions(love.graphics.getDimensions())
  crt = moonshine(moonshine.effects.crt)
  background = moonshine(moonshine.effects.glow).chain(moonshine.effects.scanlines)
  foreground = moonshine(moonshine.effects.glow)
  foreground.glow.strength = 10
end

function love.update(dt)
  flux.update(dt)
  shack:update(dt)
  playerOne.particles:update(dt)
  playerTwo.particles:update(dt)
  ball.particles:update(dt)
  score.particles:update(dt)

  if love.keyboard.isDown("a") then
    playerOne.y = math.max(0, playerOne.y - playerOne.speed * dt)
    playerOne.particles:setPosition(playerOne.x + playerOne.width*.5, playerOne.y + playerOne.height)
    playerOne.particles:setDirection(math.pi/2)
    playerOne.particles:setSpeed(800)
    playerOne.particles:start()
  elseif love.keyboard.isDown("z") then
    playerOne.y = math.min(SCREEN_Y - playerOne.height, playerOne.y + playerOne.speed * dt)
    playerOne.particles:setPosition(playerOne.x+playerOne.width*.5, playerOne.y+(dir == -1 and playerOne.height or 0))
    playerOne.particles:setDirection(3 * math.pi / 2)
    playerOne.particles:setSpeed(800)
    playerOne.particles:start()
  else
    playerOne.particles:stop()
  end

  if love.keyboard.isDown("k") then
    playerTwo.y = math.max(0, playerTwo.y - playerTwo.speed * dt)
    playerTwo.particles:setPosition(playerTwo.x + playerTwo.width*.5, playerTwo.y + playerTwo.height)
    playerTwo.particles:setDirection(math.pi/2)
    playerTwo.particles:setSpeed(800)
    playerTwo.particles:start()
  elseif love.keyboard.isDown("m") then
    playerTwo.y = math.min(SCREEN_Y - playerTwo.height, playerTwo.y + playerTwo.speed * dt)
    playerTwo.particles:setPosition(playerTwo.x+playerTwo.width*.5, playerTwo.y+(dir == -1 and playerTwo.height or 0))
    playerTwo.particles:setDirection(3 * math.pi / 2)
    playerTwo.particles:setSpeed(800)
    playerTwo.particles:start()
  else
    playerTwo.particles:stop()
  end

  ball.x = ball.x + ball.dx * dt
  ball.y = ball.y + ball.dy * dt

  table.insert(ball.trails, { x = ball.x, y = ball.y })
  if #ball.trails > 35 then
    table.remove(ball.trails, 1)
  end

  if ball.y < 0 then
    ball.y = 0
    ball.dy = ball.dy * -1
  end

  if ball.y + ball.height > SCREEN_Y then
    ball.y = SCREEN_Y - ball.height
    ball.dy = ball.dy * -1
  end

  if collides(ball, playerOne) then
    ball.x = playerOne.x + playerOne.width + 1
    ball.dx = ball.dx * -1
    flux.to(ball, 0.1, { dx = ball.dx * 3, width = ball.width * 1.25, height = ball.height * 1.25 }):ease("circout"):after(ball, 0.25, { dx = math.min(750, ball.dx * 1.25), width = ball.width, height = ball.height })
    flux.to(divider, 0.1, { width = divider.width * 2, height = divider.height * 1.1 }):after(divider, 0.1, { width = divider.width, height = divider.height})
    flux.to(playerOne, 0.2, { width = playerOne.width * .9, height = playerOne.height * 1.05, x = playerOne.x + playerOne.width }):ease("circout"):after(playerOne, 0.1, { width = playerOne.width, height = playerOne.height, x = playerOne.x }):ease("sinein")
    ball.particles:setPosition(ball.x + playerOne.width + ball.width, ball.y + ball.height*.5)
    ball.particles:setDirection(math.pi)
    ball.particles:emit(32)
    shack:setShake(shake)
    shake = shake + 1
  end

  if collides(ball, playerTwo) then
    ball.x = playerTwo.x - playerTwo.width - ball.width - 1
    ball.dx = ball.dx * -1
    flux.to(ball, 0.1, { dx = ball.dx * 3, width = ball.width * 1.25, height = ball.height * 1.25 }):ease("circout"):after(ball, 0.25, { dx = math.min(750, ball.dx * 1.25), width = ball.width, height = ball.height })
    flux.to(divider, 0.1, { width = divider.width * 2, height = divider.height * 1.1 }):after(divider, 0.1, { width = divider.width, height = divider.height})
    flux.to(playerTwo, 0.3, { width = playerTwo.width * .9, height = playerTwo.height * 1.05, x = playerTwo.x - playerTwo.width }):ease("circout"):after(playerTwo, 0.1, { width = playerTwo.width, height = playerTwo.height, x = playerTwo.x }):ease("sinein")
    ball.particles:setPosition(ball.x, ball.y + ball.height*.5)
    ball.particles:setDirection(2 * math.pi)
    ball.particles:emit(32)
    shack:setShake(shake)
    shake = shake + 1
  end

  if ball.x + ball.width > SCREEN_X then
    playerOne.score = playerOne.score + 1
    score.particles:setPosition(SCREEN_X, ball.y)
    score.particles:setDirection(math.pi)
    score.particles:start()
    shack:setShake(25)
    ball.dy = love.math.random(-240, 240)
    ball.dx = 120
    ball.x = SCREEN_X*.5 - ball.width*.5
    ball.y = SCREEN_Y*.5 - ball.height*.5
    shake = 3
  end

  if ball.x < 0 then
    playerTwo.score = playerTwo.score + 1
    score.particles:setPosition(0, ball.y)
    score.particles:setDirection(2 * math.pi)
    score.particles:start()
    shack:setShake(25)
    ball.dy = love.math.random(-240, 240)
    ball.dx = 120
    ball.x = SCREEN_X*.5 - ball.width*.5
    ball.y = SCREEN_Y*.5 - ball.height*.5
    shake = 3
  end
end

function collides(a, b)
  -- aabb algorithm
  local collidesX = a.x + a.width >= b.x and b.x + b.width >= a.x
  local collidesY = a.y + a.height >= b.y and b.y + b.height >= a.y
  return collidesX and collidesY
end

function love.draw()
  shack:apply()
  crt(function()
    love.graphics.setColor(51 / 100, 124 / 100, 160 / 100, 0.1)
    love.graphics.rectangle('fill', 0, 0, SCREEN_X, SCREEN_Y)

    background(function()
      love.graphics.setColor(1, 1, 1, 1, 0.2)

      love.graphics.setFont(GAME_FONT)
      love.graphics.print(playerOne.score, SCREEN_X*.5 - GAME_FONT:getWidth(playerOne.score) - 60, 100)
      love.graphics.print(playerTwo.score, SCREEN_X*.5 + 60, 100)

      for i = 5, SCREEN_Y, 20 do
        love.graphics.rectangle('fill', SCREEN_X*.5 - divider.width*.5, i, divider.width, divider.height)
      end

      love.graphics.rectangle('fill', playerOne.x, playerOne.y, playerOne.width, playerOne.height)
      love.graphics.rectangle('fill', playerTwo.x, playerTwo.y, playerTwo.width, playerTwo.height)
    end)

    foreground(function()
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(playerOne.particles, 0, 0)
      love.graphics.draw(playerTwo.particles, 0, 0)
      love.graphics.draw(ball.particles, 0, 0)
      love.graphics.draw(score.particles, 0, 0)

      love.graphics.rectangle('line', playerOne.x, playerOne.y, playerOne.width, playerOne.height)
      love.graphics.rectangle('line', playerTwo.x, playerTwo.y, playerTwo.width, playerTwo.height)

      love.graphics.rectangle('fill', ball.x, ball.y, ball.width, ball.height)
      for i, trail in ipairs(ball.trails) do
        local width, height = ball.width * i / #ball.trails, ball.height * i / #ball.trails
        love.graphics.setColor(1, 1, 1, i / #ball.trails / 10)
        love.graphics.rectangle('fill', trail.x, trail.y, width, height)
      end
    end)
  end)
end

function love.keypressed(key)
end
