local player = {}

local function draw(self)
    love.graphics.draw(self.image, self.x, self.y)
end

function player.new(p)
    local sprite = "images/player.png"
    return {
        image = love.graphics.newImage(sprite),
        x = p.x,
        y = p.y,
        draw = draw,
    }
end

return player
