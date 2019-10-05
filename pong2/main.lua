screenX, screenY = love.graphics.getDimensions()
font = love.graphics.newFont("assets/fonts/sharp-retro.ttf", 96, "mono")
local moonshine = require 'moonshine'
local flux = require 'flux'
local shack = require 'shack'

function love.load()
  love.window.setTitle("PONG")
  love.math.setRandomSeed(os.time())

  playerOne = {}
  playerOne.width = 10
  playerOne.height = 90
  playerOne.y = screenY*.5 - playerOne.height*.5
  playerOne.x = 20
  playerOne.speed = 1200
  playerOne.score = 0

  playerTwo = {}
  playerTwo.width = 10
  playerTwo.height = 90
  playerTwo.y = screenY*.5 - playerTwo.height*.5
  playerTwo.x = screenX - playerTwo.width - 20
  playerTwo.speed = 1200
  playerTwo.score = 0

  ball = {}
  ball.width = 16
  ball.height = 16
  ball.speed = 120
  ball.dy = love.math.random(-240, 240)
  ball.dx = 120
  ball.x = screenX*.5 - ball.width*.5
  ball.y = screenY*.5 - ball.height*.5

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

  if love.keyboard.isDown("a") then
    playerOne.y = math.max(0, playerOne.y - playerOne.speed * dt)
  elseif love.keyboard.isDown("z")then
    playerOne.y = math.min(screenY - playerOne.height, playerOne.y + playerOne.speed * dt)
  end

  if love.keyboard.isDown("k") then
    playerTwo.y = math.max(0, playerTwo.y - playerTwo.speed * dt)
  elseif love.keyboard.isDown("m") then
    playerTwo.y = math.min(screenY - playerTwo.height, playerTwo.y + playerTwo.speed * dt)
  end

  ball.x = ball.x + ball.dx * dt
  ball.y = ball.y + ball.dy * dt

  if ball.y < 0 then
    ball.y = 0
    ball.dy = ball.dy * -1
  end

  if ball.y + ball.height > screenY then
    ball.y = screenY - ball.height
    ball.dy = ball.dy * -1
  end

  if collides(ball, playerOne) then
    ball.x = playerOne.x + playerOne.width + 1
    ball.dx = ball.dx * -1
    flux.to(ball, 0.1, { dx = ball.dx * 3, width = ball.width * 1.25, height = ball.height * 1.25 }):ease("circout"):after(ball, 0.25, { dx = math.min(750, ball.dx * 1.25), width = ball.width, height = ball.height })
    flux.to(divider, 0.1, { width = divider.width * 2, height = divider.height * 1.1 }):after(divider, 0.1, { width = divider.width, height = divider.height})
    shack:setShake(shake)
    shake = shake + 1
  end

  if collides(ball, playerTwo) then
    ball.x = playerTwo.x - ball.width - 1
    ball.dx = ball.dx * -1
    flux.to(ball, 0.1, { dx = ball.dx * 3, width = ball.width * 1.25, height = ball.height * 1.25 }):ease("circout"):after(ball, 0.25, { dx = math.min(750, ball.dx * 1.25), width = ball.width, height = ball.height })
    flux.to(divider, 0.1, { width = divider.width * 2, height = divider.height * 1.1 }):after(divider, 0.1, { width = divider.width, height = divider.height})
    shack:setShake(shake)
    shake = shake + 1
  end

  if ball.x + ball.width > screenX then
    playerOne.score = playerOne.score + 1
    ball.dy = love.math.random(-240, 240)
    ball.dx = 120
    ball.x = screenX*.5 - ball.width*.5
    ball.y = screenY*.5 - ball.height*.5
    shake = 3
  end

  if ball.x < 0 then
    playerTwo.score = playerTwo.score + 1
    ball.dy = love.math.random(-240, 240)
    ball.dx = 120
    ball.x = screenX*.5 - ball.width*.5
    ball.y = screenY*.5 - ball.height*.5
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
    love.graphics.rectangle('fill', 0, 0, screenX, screenY)

    background(function()
      love.graphics.setColor(1, 1, 1, 1, 0.2)

      love.graphics.setFont(font)
      love.graphics.print(playerOne.score, screenX*.5 - font:getWidth(playerOne.score) - 60, 100)
      love.graphics.print(playerTwo.score, screenX*.5 + 60, 100)

      for i = 5, screenY, 20 do
        love.graphics.rectangle('fill', screenX*.5 - divider.width*.5, i, divider.width, divider.height)
      end

      love.graphics.rectangle('fill', playerOne.x, playerOne.y, playerOne.width, playerOne.height)
      love.graphics.rectangle('fill', playerTwo.x, playerTwo.y, playerTwo.width, playerTwo.height)
    end)

    foreground(function()
      love.graphics.setColor(1, 1, 1, 1)

      love.graphics.rectangle('line', playerOne.x, playerOne.y, playerOne.width, playerOne.height)
      love.graphics.rectangle('line', playerTwo.x, playerTwo.y, playerTwo.width, playerTwo.height)

      love.graphics.rectangle('fill', ball.x, ball.y, ball.width, ball.height)
    end)
  end)
end

function love.keypressed(key)
end

