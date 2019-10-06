Net = {}
Net.__index = Net

function Net.new()
  local net = {}
  setmetatable(net, Net)
  net.width = 10
  net.height = 10

  return net
end

function Net:bounce()
  flux.to(self, 0.1, { width = self.width * 2, height = self.height * 1.1 }):after(self, 0.1, { width = self.width, height = self.height})
end

function Net:draw()
  for i = 5, SCREEN_Y, 20 do
    love.graphics.rectangle('fill', center(SCREEN_X, self.width), i, self.width, self.height)
  end
end
