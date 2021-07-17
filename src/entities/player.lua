local Player = Class:extend()

function Player:draw()
  love.graphics.draw(self.image, self.quad, self.x, self.y)
end

function Player:moveOutOfBounds()
  local dir = nil
  local x, y = self.x, self.y
  if self.x > self.east - self.w / 3 then
    dir = "e"
    x = self.west + self.w / 3
  elseif self.x < self.west - self.w / 3 then
    dir = "w"
    x = self.east - self.w - self.w / 3
  elseif self.y > self.south - self.h / 3 then
    dir = "s"
    y = self.north + self.h + self.h / 3
  elseif self.y < self.north - self.h / 3 then
    dir = "n"
    y = self.south - self.h - self.h / 3
  end
  if dir then
    Signal.emit(SIGNALS.NEXT_LEVEL, dir)
    self.world:remove(self)
    self.x = x
    self.y = y
  end
end

function Player:move(dt, world)
  if not self.world and world then
    self.world = world
  end
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

  self.dy = math.max(
                -self.maxVertSpeed,
                math.min(self.dy + self.gravity * dt, self.maxVertSpeed))

  local cols
  self.x, self.y, cols = world:move(self, self.x + dx, self.y + self.dy)

  for _, col in pairs(cols) do
    if col.normal.y == -1 then
      self.ground = true
    end
    if col.normal.y == 1 then
      self.dy = 0
    end
  end

  self:moveOutOfBounds()
end

function Player:onLevelLoaded()
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:new(p, map_width, map_height, nextLevel)
  self.x = p.x
  self.y = p.y
  self.top = p.top
  self.left = p.left
  self.w = p.w
  self.h = p.h
  self.image = love.graphics.newImage("assets/player.png")
  self.quad = love.graphics.newQuad(
                  self.left, self.top, self.w, self.h,
                  self.image:getDimensions())
  self.dy = 0
  self.gravity = 10
  self.speed = 250
  self.jumpSpeed = -5
  self.ground = false
  self.jumping = false
  self.maxVertSpeed = 5
  self.east = map_width
  self.south = map_height
  self.north = 0
  self.west = 0
  self.nextLevel = nextLevel
end

return Player

