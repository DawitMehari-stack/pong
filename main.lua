push = require 'push'
Class = require 'class'
local moonshine = require 'moonshine'

require 'Ball'
require 'Paddle'
require 'dashedLine'

-- WINDOW_WIDTH = 1280
-- WINDOW_HEIGHT = 720

WINDOW_WIDTH = 432
WINDOW_HEIGHT = 243

VIRTUAL_HEIGHT = WINDOW_HEIGHT
VIRTUAL_WIDTH = WINDOW_WIDTH

--VIRTUAL_WIDTH = 432
--VIRTUAL_HEIGHT = 243


--[[------------VARIABLES FOR 1920x1080-----------------------
WINDOW_WIDTH = VIRTUAL_WIDTH = 1920
WINDOW_HEIGHT = VIRTUAL_HEIGHT = 1080

PADDLE_SPEED = 900

BALL_SIZE = 18
PADDLE_WIDTH = 25
PADDLE_HEIGHT = 90

smallFont = love.graphics.newFont('font.ttf', 36)
largeFont = love.graphics.newFont('font.ttf', 72)
scoreFont = love.graphics.newFont('font.ttf', 144)

player1 = Paddle(45, 135, PADDLE_WIDTH, PADDLE_HEIGHT)
player2 = Paddle(VIRTUAL_WIDTH - 45, VIRTUAL_HEIGHT - 135, PADDLE_WIDTH, PADDLE_HEIGHT)

ball = Ball((VIRTUAL_WIDTH / 2) - (BALL_SIZE / 2), (VIRTUAL_HEIGHT / 2) - (BALL_SIZE / 2), BALL_SIZE, BALL_SIZE)

]]
PADDLE_SPEED = 200

function love.load()
    --love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('PONG')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    --[[
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    }) ]]

    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = false
    })

    -- Initialize score variables
    player1score = 0
    player2score = 0

    -- Set player 1 to serve first
    servingPlayer = 1

    -- Call paddle and ball constructors
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    -- Load effects
    effect = moonshine(moonshine.effects.scanlines).chain(moonshine.effects.crt)
    --effect = moonshine(moonshine.effects.crt).chain(moonshine.effects.scanlines)
    -- effect.crt.distortionFactor = {1.05, 1.05}
    -- Initialize game state
    gameState = 'start'
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
            -- Reverse ball x-direction and speed it up
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            -- Reverse ball y-direction and randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10,150)
            end
        end

        if ball:collides(player2) then
            -- Reverse ball x-direction and speed it up
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            -- Reverse ball y-direction and randomize it
            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else
                ball.dy = math.random(10,150)
            end
        end

        -- Detect top screen collision
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        -- Detect bottom screen collision, accounting for ball size
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end

        -- Detect left screen collision for scoring
        if ball.x < -3 then
            servingPlayer = 1
            player2score = player2score + 1
            ball:reset()
            gameState = 'serve'
        end

        -- Detect right screen collision for scoring
        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1score = player1score + 1
            ball:reset()
            gameState = 'serve'
        end
    end

    -- Handle player 1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then 
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    -- Handle player 2 movement
    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    -- Update ball position and velocity if in play state
    if gameState == 'play' then
        ball:update(dt)
    end

    -- Update paddle positions
    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' or key == 'space' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        end
    end
end

function love.draw()
    -- push:apply('start')

    -- Set background color
    effect(function()
    love.graphics.clear(0.16, 0.18, 0.2, 1)
 
    displayScore()

    -- dashedLine(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT + 4, 4, 8)
    love.graphics.setColor(0,1,0,1)
    dashedLine(VIRTUAL_WIDTH / 2, 0, VIRTUAL_WIDTH / 2, 4, 4, 8)
    dashedLine(VIRTUAL_WIDTH / 2, 32, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT + 8, 4, 8)
    love.graphics.setColor(1,1,1,1)

    -- Draw text
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to PONG', 0, 10, VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press space to play', 0, 20, VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. servingPlayer .. ' is serving', 0, 10, VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press space to serve!', 0, 20, VIRTUAL_WIDTH,'center')
    elseif gameState == 'play' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('PONG', 0, 10, VIRTUAL_WIDTH, 'center')
    end

    -- Draw left and right paddles
    player1:render()
    player2:render()

    -- Draw ball
    ball:render()

    -- Display FPS counter
    displayFPS()

    end)

    --push:apply('end')
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), VIRTUAL_WIDTH - 40, 10)
end