local json = require("lib.json")

-- params: a path + a bump world

-- get json
-- parse with decode
-- get all layers
-- for each layer, based on type, call parseType
-- return {
--   entities: put entities in a struct so that we can do struct.Player
--   collision: if layer called collision or layer custom data collision, get intGridCsv
--   from intGridCsv, get the coordinates
--   create the collisions, add them to the world
--   tiles: if tiles/autotiles/gridTiles, put in a consolidated list
--   quads: create all the quads from a tileset
--   draw: draw all tiles, based on quads and tiles list 
-- }

local Ldtk = Class:extend()

local Layer = Class:extend()
function Layer:new(tiles, name)
  self.tiles = tiles
  self.name = name
end

local IntGrid = Layer:extend()
function IntGrid:new(tiles, name, size)
  IntGrid.super.new(self, tiles, name)
  self.type = "int"
  self.size = size
end

local AutoLayer = Layer:extend()
function AutoLayer:new(tiles, name, tileset, size)
  AutoLayer.super.new(self, tiles, name)
  self.type = "auto"
  self.tileset = love.graphics.newImage(tileset)
  self.size = size
  local quadInfo = {}
  for i = 1, #tiles do
    local tile = tiles[i]
    if not quadInfo[tile.t] then
      quadInfo[tile.t] = tile.src
    end
  end
  local quads = {}
  for k, info in pairs(quadInfo) do
    quads[k] = love.graphics.newQuad(
                   info[1], info[2], size, size, self.tileset:getWidth(),
                   self.tileset:getHeight())
  end
  self.quads = quads
end

local function getIntGrid(layer)
  local width = layer.__cWid
  local size = layer.__gridSize
  local grid = layer.intGridCsv
  local tiles = {}
  local size = layer.__gridSize
  for i = 0, #grid - 1 do
    if grid[i + 1] > 0 then
      local y = math.floor(i / width)
      local x = i - y * width
      tiles[#tiles + 1] = {
        x = x * size,
        y = y * size,
        v = grid[i + 1],
        h = size,
        w = size,
      }
    end
  end
  return IntGrid(tiles, layer.__identifier, size)
end

local function getAutoLayer(layer, root)
  return AutoLayer(
             layer.autoLayerTiles, layer.__identifier,
             root .. layer.__tilesetRelPath, layer.__gridSize)
end

local function getEntities(layer)
  local instances = layer.entityInstances
  local entities = {}
  for i = 1, #instances do
    local entity = instances[i]
    entities[entity.__identifier] = {
      x = entity.px[1],
      y = entity.px[2],
      w = entity.width,
      h = entity.height,
    }
  end
  entities.name = layer.__identifier
  return entities
end

local layerTypes = {
  AutoLayer = getAutoLayer,
  IntGrid = getIntGrid,
  Entities = getEntities,
}

local function getLayer(_layer, root)
  local layer = {}
  local getLayerByType = layerTypes[_layer.__type]
  if getLayerByType then
    layer = getLayerByType(_layer, root)
  else
    layer.name = _layer.__identifier
  end
  return layer
end

local function getLayers(_layers, root)
  local layers = {}
  for i = 1, #_layers do
    local _layer = _layers[i]
    local layer = getLayer(_layer, root)
    layers[layer.name] = layer
  end
  return layers
end

local function getLevel(_level, root)
  local level = getLayers(_level.layerInstances, root)
  level.name = _level.identifier
  return level
end

local function getLevels(_levels, root)
  local levels = {}
  for i = 1, #_levels do
    local _level = _levels[i]
    local level = getLevel(_level, root)
    levels[level.name] = level
  end
  return levels
end

function Ldtk:new(path)
  local root = path:gsub("[^/]+.ldtk", "")
  local data = love.filesystem.read(path)
  local raw = json.decode(data)
  local _levels = raw.levels
  local levels = getLevels(_levels, root)
  self.levels = levels
end

function IntGrid:addCollisions(world)
  local tiles = self.tiles
  for i = 1, #tiles do
    local tile = tiles[i]
    world:add(tile, tile.x, tile.y, tile.w, tile.h)
  end
end

function Ldtk:addCollisions()
  local layers = self.active
  for _, layer in pairs(layers) do
    local meta = getmetatable(layer)
    if meta and meta.addCollisions then
      layer:addCollisions(self.world)
    end
  end
end

function Ldtk:addWorld(world)
  self.world = world
end

function AutoLayer:draw()
  local tiles = self.tiles
  for i = 1, #tiles do
    local tile = tiles[i]
    love.graphics.draw(self.tileset, self.quads[tile.t], tile.px[1], tile.px[2])
  end
end

function Ldtk:loadLevel(name)
  if not self.levels[name] then
    print("Could not find the level " .. name)
    return false
  end
  self.current = name
  self.active = self.levels[self.current]
end

function Ldtk:draw()
  local layers = self.active
  for _, layer in pairs(layers) do
    local meta = getmetatable(layer)
    if meta and meta.draw then
      layer:draw()
    end
  end
end

return Ldtk
