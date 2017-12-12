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
  x = 200,
  y = 300,
  cx = 24,
  cy = 33,
  angle = 0,
  speed = 250,
  img = nil,
  score = 0,
  heat = 0,
	heatp = 0.05 -- bullet rate
}

car = { x = 200, y = 200, angle = math.pi /3, img = nil }

bullets = { }

ennemies = {}
en_spawn_rate=5
en_spawn_timer=10

function ennemies_spawn(dt)
   if en_spawn_timer == 0 then
       table.insert(ennemies, {
           x = love.math.random( 800 ),
           y = love.math.random( 600 ),
           dir = 0,
           speed = 150
       })
       en_spawn_timer = en_spawn_rate
   end
   en_spawn_timer = math.max(0, en_spawn_timer - dt)
end

function ennemies_move(dt)
  for i, o in ipairs(ennemies) do
   o.dir = math.pi/6 + math.atan2(player.y - o.y, player.x - o.x)
  	o.x = o.x + math.cos(o.dir) * o.speed * dt
  	o.y = o.y + math.sin(o.dir) * o.speed * dt
  end
end

function bullets_hit()
  for i = #ennemies, 1, -1 do
  	local e = ennemies[i]
    for j = #bullets, 1, -1 do
      local b = bullets[j]
      local dist = (e.x - b.x)^2 + (e.y - b.y)^2
      if dist < 100 then
          player.score = player.score + 1
          table.remove(ennemies, i)
          table.remove(bullets, j)
      end
    end
  end
end

function love.load(arg)
  scene = love.graphics.newImage('assets/scene.png')
  player.img = love.graphics.newImage('assets/player.png')
  car.img = love.graphics.newImage('assets/car.png')
  sound = love.audio.newSource('assets/shot.ogg')
  crab_img = love.graphics.newImage('assets/crab.png')
end

function love.update(dt)

  watch_escape()
  watch_mouse()
  watch_player_move(dt)
  watch_player_shoot()
  player.heat = math.max(0, player.heat - dt)
  bullets_move(dt)
  bullets_remove()
  ennemies_spawn(dt)
  ennemies_move(dt)
  bullets_hit()
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

function watch_player_move(dt)
  if love.keyboard.isDown('up','w') then
    if player.y > 0 then
      player.y = player.y - player.speed * dt
    end
  elseif love.keyboard.isDown('down','s') then
    if player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt
    end
  elseif love.keyboard.isDown('left','a') then
    if player.x > 0 then
      player.x = player.x - player.speed * dt
    end
  elseif love.keyboard.isDown('right','d') then
    if player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt
    end
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

function draw_canvas()
  -- love.graphics.setBackgroundColor(253, 250, 232)
end

function draw_scene()
  love.graphics.draw(scene, 0 ,0)
end

function draw_score()
  love.graphics.setColor(1, 85, 229)
  love.graphics.setNewFont(18)
  love.graphics.print("crabs killed: " .. tostring(player.score), 50, 30)
  love.graphics.setColor(255, 255, 255)
end


function draw_text()
  love.graphics.setColor(1, 85, 229)
  love.graphics.setNewFont(18)
  love.graphics.print("Hello, username", 500, 200)
  love.graphics.print("Sure you wanna play this game?", 500, 250)
  love.graphics.print("money: " .. tostring(num), 500, 300)
  love.graphics.setColor(255, 255, 255)
end

function draw_car()
  love.graphics.draw(car.img, car.x, car.y, car.angle)
end

function draw_player()
  love.graphics.draw(player.img,
                     player.x, player.y,
                     player.angle,
                     1, 1,
                     player.cx, player.cy)
  love.graphics.setColor(255,255,255);
end

function draw_bullets()
  love.graphics.setColor(50, 50, 150)
	for i, o in ipairs(bullets) do
		love.graphics.circle('fill', o.x, o.y, 10, 8)
	end
  love.graphics.setColor(255, 255, 255)
end

function draw_ennemies()
	for i, o in ipairs(ennemies) do
		love.graphics.draw(crab_img,
                     o.x, o.y,
                     o.dir,
                     1, 1,
                     20, 10)
	end
end

function love.draw(dt)
  draw_canvas()
  draw_scene()
  draw_score()
  -- draw_text()
  draw_car()
  draw_player()
  draw_bullets()
  draw_ennemies()
end
