require 'dependencies'
require 'src/constants'
require 'src/ball'
require 'src/net'
require 'src/paddle'
require 'src/utils'

function love.load()
  love.window.setTitle("PONG")
  love.math.setRandomSeed(os.time())

  local paddleWidth, paddleHeight = 10, 90
  local paddleSpeed = 1200

  playerOne = Paddle.new(20, center(SCREEN_Y, paddleHeight), paddleWidth, paddleHeight, paddleSpeed, "a", "z")
  playerTwo = Paddle.new(SCREEN_X - paddleWidth - 20, center(SCREEN_Y, paddleHeight), paddleWidth, paddleHeight, paddleSpeed, "k", "m")
  ball = Ball.new()
  net = Net.new()

  shake = 3
  shack:setDimensions(love.graphics.getDimensions())
  crt = moonshine(moonshine.effects.crt)
  background = moonshine(moonshine.effects.glow).chain(moonshine.effects.scanlines)
  foreground = moonshine(moonshine.effects.glow)
  foreground.glow.strength = 10
end

function love.update(dt)
  flux.update(dt)
  shack:update(dt)
  playerOne:update(dt)
  playerTwo:update(dt)

  ball:update(dt)

  if collides(ball, playerOne) then
    ball.x = playerOne.x + playerOne.width + 1
    ball:bounce(ball.x + playerOne.width + ball.width, ball.y + ball.height*.5, math.pi)
    net:bounce()
    flux.to(playerOne, 0.2, { width = playerOne.width * .9, height = playerOne.height * 1.05, x = playerOne.x + playerOne.width }):ease("circout"):after(playerOne, 0.1, { width = playerOne.width, height = playerOne.height, x = playerOne.x }):ease("sinein")
    shack:setShake(shake)
    shake = shake + 1
  end

  if collides(ball, playerTwo) then
    ball.x = playerTwo.x - playerTwo.width - ball.width - 1
    ball:bounce(ball.x, ball.y + ball.height*.5, 2 * math.pi)
    net:bounce()
    flux.to(playerTwo, 0.3, { width = playerTwo.width * .9, height = playerTwo.height * 1.05, x = playerTwo.x - playerTwo.width }):ease("circout"):after(playerTwo, 0.1, { width = playerTwo.width, height = playerTwo.height, x = playerTwo.x }):ease("sinein")
    shack:setShake(shake)
    shake = shake + 1
  end

  if ball.x + ball.width > SCREEN_X then
    playerOne.score = playerOne.score + 1
    ball:explode(SCREEN_X, ball.y, math.pi)
    shack:setShake(25)
    shake = 3
    ball:reset()
  end

  if ball.x < 0 then
    playerTwo.score = playerTwo.score + 1
    ball:explode(0, ball.y, 2 * math.pi)
    shack:setShake(25)
    shake = 3
    ball:reset()
  end
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
      net:draw()

      love.graphics.rectangle('fill', playerOne.x, playerOne.y, playerOne.width, playerOne.height)
      love.graphics.rectangle('fill', playerTwo.x, playerTwo.y, playerTwo.width, playerTwo.height)
    end)

    foreground(function()
      playerOne:draw()
      playerTwo:draw()
      ball:draw()
    end)
  end)
end

function love.keypressed(key)
end
