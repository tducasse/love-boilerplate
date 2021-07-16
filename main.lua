local inspect = require("lib.inspect")
Inspect = function(a)
  print(inspect(a))
end
Class = require("lib.classic")

local push = require("lib.push")
local Ldtk = require("lib.ldtk")
local Camera = require("lib.camera")
local bump = require("lib.bump")

local Player = require("src.entities.player")

-- DRAW BOXES
local Object = Class:extend()
function Object:new(e)
  self.x = e.x
  self.y = e.y
  self.w = e.width
  self.h = e.height
  self.visible = e.visible
end
function Object:draw()
  if self.visible then
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
  end
end

-- WINDOW
local res_x = 256
local res_y = 256
local window_x = 1024
local window_y = window_x / (res_x / res_y)
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
push:setupScreen(
    res_x, res_y, window_x, window_y,
    { fullscreen = false, resizable = true, vsync = true })

-- CAMERA
local camera = Camera(res_x / 2, res_y / 2, res_x, res_y)
camera:setFollowStyle("PLATFORMER")

-- VARS
local player = {}
local world = {}
local map = {}

-- GAME
function love.load()
  map = Ldtk("map/boilerplate.ldtk")
  map:loadLevel("Level_0")
  player = Player(map.active.Entities.Player)
  world = bump.newWorld()
  map:addWorld(world)
  map:addCollisions()
  world:add(player, player.x, player.y, player.w, player.h)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.resize(w, h)
  return push:resize(w, h)
end

function love.update(dt)
  require("lib.lurker").update()
  player:move(dt, world)
  camera:follow(player.x, player.y)
  camera:update()
end

function love.draw()
  push:start()
  camera:attach()

  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
  map:draw()
  player:draw()

  camera:detach()
  push:finish()
end
