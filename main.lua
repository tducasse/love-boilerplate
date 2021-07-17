require("src.globals")
require("lib.audio")

local inspect = require("lib.inspect")
Inspect = function(a)
  print(inspect(a))
end
Class = require("lib.classic")
Signal = require("lib.signal")

local push = require("lib.push")
local Ldtk = require("lib.ldtk")
local Camera = require("lib.camera")
local bump = require("lib.bump")

local Player = require("src.entities.player")

-- WINDOW
local res_x = 512
local res_y = 288
local window_x = 1024
local window_y = window_x / (res_x / res_y)
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")
push:setupScreen(
    res_x, res_y, window_x, window_y,
    { fullscreen = false, resizable = true, vsync = true, pixelperfect = true })

-- CAMERA
local camera = Camera(res_x / 2, res_y / 2, res_x, res_y)
camera:setFollowStyle("PLATFORMER")

-- VARS
local player = {}
local world = {}
local map = {}
local paused = false

-- GAME
function love.load()
  love.audio.play("assets/music.ogg", "stream", true)
  -- MAP
  map = Ldtk("assets/boilerplate.ldtk", { aseprite = true })
  world = bump.newWorld()
  map:loadLevel("Level_0", world)
  camera:setBounds(0, 0, map.active.width, map.active.height)

  -- PLAYER
  player = Player(
               map.active.Entities.Player, map.active.width, map.active.height)
  world:add(player, player.x, player.y, player.w, player.h)

  -- SIGNALS
  Signal.register(
      SIGNALS.NEXT_LEVEL, function(params)
        paused = true
        camera:fade(
            0.1, { 0, 0, 0, 1 }, function()
              map:nextLevel(
                  params, function()
                  end)
              Signal.emit(SIGNALS.LEVEL_LOADED)
            end)
      end)
  Signal.register(
      SIGNALS.LEVEL_LOADED, function()
        camera:fade(
            0.1, { 0, 0, 0, 0 }, function()
              paused = false
              player:onLevelLoaded()
            end)
      end)
end

function love.resize(w, h)
  return push:resize(w, h)
end

function love.update(dt)
  require("lib.lurker").update()
  love.audio.update()
  if not paused then
    player:update(dt, world)
  end
  camera:follow(player.x, player.y)
  camera:update(dt)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

function love.draw()
  push:start()
  camera:attach()

  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
  map:draw()
  if not paused then
    player:draw()
  end

  -- local items = world:getItems()
  -- for i = 1, #items do
  --   local item = items[i]
  --   love.graphics.rectangle("line", item.x, item.y, item.w, item.h)
  -- end

  camera:detach()
  camera:draw()
  push:finish()
end
