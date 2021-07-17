local peachy = require("lib.peachy")
local Player = Class:extend()

function Player:draw()
  self.sprite:draw(self.x - self.left, self.y - self.top)
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

function Player:update(dt, world)
  self.sprite:update(dt)

  if not self.world and world then
    self.world = world
  end

  local dx = 0
  if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
    self.sprite:setTag("Right")
    dx = self.speed * dt
    self.last_dir = self.sprite.tagName
  elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
    self.sprite:setTag("Left")
    dx = -self.speed * dt
    self.last_dir = self.sprite.tagName
  end

  if love.keyboard.isDown("space") or love.keyboard.isDown("z") then
    if self.ground and not self.jumping then
      self.jumping = true
      self.dy = self.jumpSpeed
    end
  else
    self.jumping = false
  end

  self.dy = math.max(
                -self.maxVertSpeed,
                math.min(self.dy + self.gravity * dt, self.maxVertSpeed))

  local cols
  self.x, self.y, cols = world:move(self, self.x + dx, self.y + self.dy)

  local grounded = false
  for _, col in pairs(cols) do
    if col.normal.y == -1 then
      grounded = true
      self.ground = true
    elseif col.normal.y == 1 then
      self.dy = 0
    end
  end

  if not grounded then
    self.sprite:setTag("Jump")
    self.ground = false
  else
    self.sprite:setTag(self.last_dir)
  end

  self:moveOutOfBounds()
end

function Player:onLevelLoaded()
  self.world:add(self, self.x, self.y, self.w, self.h)
end

function Player:new(p, map_width, map_height)
  self.x = p.x
  self.y = p.y
  self.top = p.top
  self.left = p.left
  self.w = p.w
  self.h = p.h
  self.gravity = 10
  self.speed = 250
  self.jumpSpeed = -5
  self.ground = false
  self.jumping = false
  self.maxVertSpeed = 5
  self.dy = self.maxVertSpeed
  self.east = map_width
  self.south = map_height
  self.north = 0
  self.west = 0
  self.sprite = peachy.new(
                    "assets/player.json",
                    love.graphics.newImage("assets/player.png"), "Right")
  self.last_dir = self.sprite.tagName

  self.sprite:play()
end

return Player

