function love.load()
    math.randomseed(os.time())

    sprites = {}
    sprites.background = love.graphics.newImage('sprites/grassTopDown.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet2.png')
    sprites.player = love.graphics.newImage('sprites/player2.png')
    sprites.zombie = love.graphics.newImage('sprites/robots.png')

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 180

    zombies = {}
    bullets = {}
    bulletsSpin = {}

    zombieSpeedRange = {}
    zombieSpeedRange.MinSpeed = 120
    zombieSpeedRange.MaxSpeed = 220


    

    gamestate = 1
    myFont = love.graphics.newFont(30)

    maxTimeConst = 2
    maxTime = maxTimeConst
    timer = maxTime
    score = 0
    highscore = 0
    bulletSpinCharges = 0
    bulletSpinChargeMaxTime = 4
    bulletSpinChargeTimer = bulletSpinChargeMaxTime

end

function love.update(dt)
    if gamestate == 2 then
        if love.keyboard.isDown('d') and player.x < love.graphics.getWidth() then
            player.x = player.x + player.speed*dt
        end
        if love.keyboard.isDown('a') and player.x > 0 then
            player.x = player.x - player.speed*dt
        end
        if love.keyboard.isDown('w') and player.y > 0 then
            player.y = player.y - player.speed*dt
        end
        if love.keyboard.isDown('s') and player.y < love.graphics.getHeight() then
            player.y = player.y + player.speed*dt
        end
    end

    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
        z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)

        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            for i,z in ipairs(zombies) do
                zombies[i] = nil
                gamestate = 1
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()/2
                if highscore < score then
                    highscore = score
                end
            end
        end
    end

    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end
    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end
    for i,z in ipairs(zombies) do
        for g,b in ipairs(bullets) do
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                z.dead = true
                b.dead = true
                score = score + 1
            end
        end
    end


    for i,bs in ipairs(bulletsSpin) do
        bs.time = bs.time + dt


        local oscillation = math.sin((bs.time * bs.frequency) + (math.pi / 2)) * bs.amplitude
        local oscillation_direction = bs.direction + math.pi / 2


        bs.x = bs.x + (math.cos(bs.direction) * bs.speed * dt) + math.cos(oscillation_direction) * oscillation
        bs.y = bs.y + (math.sin(bs.direction) * bs.speed * dt) + math.sin(oscillation_direction) * oscillation


    end
    for i=#bulletsSpin, 1, -1 do
        local bs = bulletsSpin[i]
        if bs.x < -50 or bs.y < -50 or bs.x > love.graphics.getWidth() + 50 or bs.y > love.graphics.getHeight() + 50 then
            table.remove(bulletsSpin, i)
        end
    end
    for i,z in ipairs(zombies) do
        for g,bs in ipairs(bulletsSpin) do
            if distanceBetween(z.x, z.y, bs.x, bs.y) < 20 then
                z.dead = true
                score = score + 1
            end
        end
    end



    

    

    for i=#zombies,1,-1 do
        local z = zombies[i]
        if z.dead == true then
            table.remove(zombies, i)
        end
    end

    for i=#bullets,1,-1 do
        local b = bullets[i]
        if b.dead == true then
            table.remove(bullets, i)
        end
    end

    if gamestate == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            if maxTime > 0.75 then
                maxTime = 0.9 * maxTime
                timer = maxTime
            else 
                maxTime = maxTime - 0.005
                timer = maxTime
            end
            
        end

        bulletSpinChargeTimer = bulletSpinChargeTimer - dt
        if bulletSpinChargeTimer <= 0 and bulletSpinCharges < 5 then
            bulletSpinCharges = bulletSpinCharges + 1
            bulletSpinChargeTimer = bulletSpinChargeMaxTime
        end
    end


end



function love.draw()
    love.graphics.draw(sprites.background,0,0)

    if gamestate == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    end
    love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
    love.graphics.printf("Highscore: " .. highscore, 0, love.graphics.getHeight() - 50, love.graphics.getWidth(), "center")

    if gamestate == 2 then 
        love.graphics.printf("Wave bullets: " .. bulletSpinCharges .. "/5", 0, 0, love.graphics.getWidth(), "right")
    end


    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, b.direction, 0.25, 0.1, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
    for i,bs in ipairs(bulletsSpin) do
        love.graphics.draw(sprites.bullet, bs.x, bs.y, bs.direction, 0.25, 0.1, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
end



function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    end
end

function love.mousepressed( x, y, button )
    if button == 1 and gamestate == 2 then
        spawnBullet()
    elseif button == 1 and gamestate == 1 then
        gamestate = 2
        maxTime = maxTimeConst
        timer = maxTime
        score = 0
        bulletSpinCharges = 0
        bulletSpinChargeMaxTime = 4
        bulletSpinChargeTimer = bulletSpinChargeMaxTime
    end

    if button == 2 and gamestate == 2 and bulletSpinCharges > 0 then
        spawnBulletSpin()
        bulletSpinCharges = bulletSpinCharges - 1
    end
end

function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

function zombiePlayerAngle(enemy)
    return math.atan2(player.y - enemy.y, player.x - enemy.x)
end

function spawnZombie()
    local zombie = {}
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = math.random(0, love.graphics.getHeight())
    --zombie.speed = math.random(zombieSpeedRange.MinSpeed, zombieSpeedRange.MaxSpeed)
    zombie.speed = generateBiasedSpeed(zombieSpeedRange.MinSpeed, zombieSpeedRange.MaxSpeed)
    zombie.dead = false

    local side = math.random(1, 4)
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end


    table.insert(zombies, zombie)
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    bullet.dead = false
    table.insert(bullets, bullet)
end

function spawnBulletSpin()
    local bulletSpin = {}
    bulletSpin.x = player.x
    bulletSpin.y = player.y
    bulletSpin.speed = 400
    bulletSpin.direction = playerMouseAngle()
    bulletSpin.time = 0
    bulletSpin.amplitude = 20
    bulletSpin.frequency = 40

    table.insert(bulletsSpin, bulletSpin)
end



function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function generateBiasedSpeed(min, max)
    local mean = (max + min) / 2 -- Mean skewed towards the lower value
    local stdDev = (max - min) / 3 -- Standard deviation for the distribution
    return math.floor(math.max(min, math.min(max, math.random_normal(mean, stdDev))))
end

function math.random_normal(mean, stdDev)
    local u1 = math.random()
    local u2 = math.random()
    local randStdNormal = math.sqrt(-2 * math.log(u1)) * math.sin(2 * math.pi * u2)
    return mean + stdDev * randStdNormal
end