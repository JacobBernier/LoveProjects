function love.load()
    wf = require 'librairies/windfield/windfield'
    world = wf.newWorld(0, 100)

    player = world:newRectangleCollider(360, 100, 80, 80)

end


function love.update(dt)

end

function love.draw()

end