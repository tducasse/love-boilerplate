local json = require "lib.json"

local ogmo = {}

local function draw(self)
    for rowIndex = 1, #self.tiles do
        local row = self.tiles[rowIndex]
        for columnIndex = 1, #row do
            local number = row[columnIndex]
            if number >= 0 then
                love.graphics.draw(
                    self.tileset, self.quads[number],
                    (columnIndex - 1) * self.width, (rowIndex - 1) * self.height)
            end
        end
    end
end

local function mergeLayers(layers)
    local tiles = {}
    local colNum = layers[1].gridCellsX
    local rowNum = layers[1].gridCellsY
    for row = 1, rowNum do
        for col = 1, colNum do
            for i = #layers, 1, -1 do
                local val = layers[i].data2D[row][col]
                if val > -1 then
                    if not tiles[row] then
                        tiles[row] = {}
                    end
                    tiles[row][col] = val
                    break
                end
            end
        end
    end
    return tiles
end

local function makeQuads(tileset, quadInfo, width, height)
    local quads = {}
    for i, info in ipairs(quadInfo) do
        quads[i] = love.graphics.newQuad(
                       info[1], info[2], width, height, tileset:getWidth(),
                       tileset:getHeight())
    end
    return quads
end

local function Map(layers, collisions, entities, image, quadInfo)
    local tileset = love.graphics.newImage(image)
    local firstLayer = layers[1]
    local width, height = firstLayer.gridCellWidth, firstLayer.gridCellHeight
    return {
        quads = makeQuads(tileset, quadInfo, width, height),
        tiles = mergeLayers(layers),
        width = width,
        height = height,
        tileset = tileset,
        collisions = collisions,
        entities = entities,
        draw = draw,
    }
end

function ogmo.getMap(path, collisionsLayer, image, quadInfo)
    local file = love.filesystem.read(path)
    local map = json.decode(file)
    local layers = {}
    local entities = {}
    local collisions = {}
    for i = 1, #map.layers do
        local layer = map.layers[i]
        if layer.tileset then
            layers[#layers + 1] = layer
        elseif layer.entities then
            for j = 1, #layer.entities do
                local entity = layer.entities[j]
                entities[entity.name] = entity
            end
        elseif layer.name == collisionsLayer then
            collisions = layer.grid2D
        end
    end
    return Map(layers, collisions, entities, image, quadInfo)
end

return ogmo
