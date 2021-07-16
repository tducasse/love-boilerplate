local Player = Class:extend()

function Player:draw()
  love.graphics.draw(self.image, self.x, self.y)
end

function Player:move(dt, world)
  local dx = 0
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    dx = self.speed * dt
  elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    dx = -self.speed * dt
  end

  if love.keyboard.isDown("space") or love.keyboard.isDown("z") then
    if self.ground and not self.jumping then
      self.jumping = true
      self.ground = false
      self.dy = self.jumpSpeed
    end
  else
    self.jumping = false
    if self.dy < self.jumpSpeed / 2 then
      self.dy = self.jumpSpeed / 2
    end
  end

  self.dy = self.dy + math.min(self.gravity * dt, 20)
  local cols
  self.x, self.y, cols = world:move(self, self.x + dx, self.y + self.dy)
  for _, col in pairs(cols) do
    if col.normal.y == -1 then
      self.ground = true
      self.dy = 0
    end
  end
end

function Player:new(p)
  self.image = love.graphics.newImage("images/player.png")
  self.x = p.x
  self.y = p.y
  self.w = p.w
  self.h = p.h
  self.dy = 0
  self.gravity = 10
  self.speed = 150
  self.jumpSpeed = -5
  self.ground = false
  self.jumping = false
end

return Player

