require("lib.utils")
local ogmo = require("lib.ogmo")
local Player = require("entities.player")
local push = require("lib.push")

local gameWidth, gameHeight = 800, 600
local windowWidth, windowHeight = 800, 600
windowWidth, windowHeight = windowWidth * .7, windowHeight * .7

push:setupScreen(
    gameWidth, gameHeight, windowWidth, windowHeight,
    { fullscreen = false, resizable = true })

local map = {}
local player = {}

function love.load()
    map = ogmo.getMap(
              "map/map.json", "collisions", "map/map.png",
              { { 16, 0 }, { 32, 0 } })
    local entities = map.entities
    player = Player.new(entities.player)
end

function love.resize(w, h)
    return push:resize(w, h)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.update()
    require("lib.lurker").update()
end

function love.draw()
    push:start()
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)
    map:draw()
    player:draw()
    push:finish()
end
