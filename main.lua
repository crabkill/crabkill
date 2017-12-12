function love.conf(t)
  t.window.title = "prblm"
  t.version = "0.1.0"
  t.window.height = 600
  t.window.width = 800
  t.console = true
end

debug = true

num = 0
player = {
  x = 1,
  y = 1,
  cx = 24,
  cy = 33,
  angle = 0,
  speed = 250,
  dir_x = 1,
  dir_y = 1,
  img = nil,
  heat = 0,
	heatp = 0.1
}

bullets = { }

function love.load(arg)
  problem = love.graphics.newImage('assets/problem.png')
  player.img = love.graphics.newImage('assets/player.png')
  car = love.graphics.newImage('assets/car.png')
  sound = love.audio.newSource('assets/shot.ogg')
end

function watch_mouse()
  local distX = love.mouse.getX() - player.x
  local distY = love.mouse.getY() - player.y
  local dist = math.sqrt(distX^2 + distY^2)
  local angle = math.atan2(distY, distX)
  player.angle = angle + math.pi/2
end

function watch_escape()
  if love.keyboard.isDown('escape') then
    love.event.quit()
  end
end

function love.update(dt)

  watch_escape()
  watch_mouse()
  watch_player_move(dt)

  if player.x > 800 then
    player.dir_x = -player.dir_x
  elseif player.x < 0 then
    player.dir_x = -player.dir_x
  elseif player.y > 600 then
    player.dir_y = -player.dir_y
  elseif player.y <= 0 then
    player.dir_y = -player.dir_y
  end

  watch_player_shoot()
  player.heat = math.max(0, player.heat - dt)
  bullets_move(dt)
  bullets_remove()
end

function watch_player_move(dt)
  if love.keyboard.isDown('up','w') then
    player.dir_y = -1
    player.y = player.y + player.speed * player.dir_y * dt
  elseif love.keyboard.isDown('down','s') then
    player.dir_y = 1
    player.y = player.y + player.speed * player.dir_y * dt
  elseif love.keyboard.isDown('left','a') then
    player.dir_x = -1
    player.x = player.x + player.speed * player.dir_x * dt
  elseif love.keyboard.isDown('right','d') then
    player.dir_x = 1
    player.x = player.x + player.speed * player.dir_x * dt
  end
end

function watch_player_shoot()
  if love.mouse.isDown(1) and player.heat <= 0 then
    sound:play()
  	local direction = math.atan2(love.mouse.getY() - player.y, love.mouse.getX() - player.x)
  	table.insert(bullets, {
  		x = player.x,
  		y = player.y,
  		dir = direction,
  		speed = 400
  	})
  	player.heat = player.heatp
  end
end


function bullets_move(dt)
  for i, o in ipairs(bullets) do
  	o.x = o.x + math.cos(o.dir) * o.speed * dt
  	o.y = o.y + math.sin(o.dir) * o.speed * dt
  end
end

function bullets_remove()
  for i = #bullets, 1, -1 do
  	local o = bullets[i]
  	if (o.x < -10) or (o.x > love.graphics.getWidth() + 10)
  	or (o.y < -10) or (o.y > love.graphics.getHeight() + 10) then
  		table.remove(bullets, i)
  	end
  end
end

function draw_player()
  love.graphics.setColor(255,255,255,255);
  love.graphics.draw(player.img,
                     player.x,
                     player.y,
                     player.angle,
                     1,
                     1,
                     player.cx,
                     player.cy)
end

function draw_text()
  love.graphics.setColor(1, 85, 229)
  love.graphics.setNewFont(18)
  love.graphics.print("Hello, username", 500, 200)
  love.graphics.print("Sure you wanna play this game?", 500, 250)
  love.graphics.print("money: " .. tostring(num), 500, 300)
  love.graphics.setColor(255, 255, 255)
end

function draw_face()
  love.graphics.setColor(0,0,0);
  love.graphics.draw(problem, 100, 100)
  love.graphics.setColor(255,255,255);
end

function draw_canvas()
  love.graphics.setBackgroundColor(253, 250, 232)
end

function draw_bullets()
  love.graphics.setColor(50, 50, 150, 255)
	for i, o in ipairs(bullets) do
		love.graphics.circle('fill', o.x, o.y, 10, 8)
	end
end

function draw_car()
  love.graphics.draw(car, 200, 200)
end

function love.draw(dt)
  draw_canvas()
  draw_face()
  draw_text()
  draw_car()
  draw_player()
  draw_bullets()
end
