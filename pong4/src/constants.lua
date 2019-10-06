SCREEN_X, SCREEN_Y = love.graphics.getDimensions()
GAME_FONT = love.graphics.newFont("assets/fonts/sharp-retro.ttf", 96, "mono")

PARTICLE = love.graphics.newCanvas(2, 6)
love.graphics.setCanvas(PARTICLE)
love.graphics.setColor(1, 1, 1, 1)
love.graphics.rectangle('fill', 0, 0, 2, 10)
love.graphics.setCanvas()

EXPLOSION = love.graphics.newCanvas(16, 16)
love.graphics.setCanvas(EXPLOSION)
love.graphics.setColor(1, 1, 1, 1)
love.graphics.rectangle('fill', 0, 0, 16, 16)
love.graphics.setCanvas()
