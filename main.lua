function love.conf(t)
  t.window.title = "crabkill"
  t.version = "0.1.1"
  t.window.height = 600
  t.window.width = 800
  t.console = true
end


debug = true
player = {
  x = 200,
  y = 300,
  cx = 24,
  cy = 33,
  angle = 0,
  speed = 250,
  speed_factor = 1,
  img = nil,
  score = 0,
  heat = 0,
  heatp = 0.05 -- bullet rate
}

car = { x = 200, y = 200, angle = math.pi /3, img = nil }

bullets = {}
ennemies = {}
en_spawn_rate=5
en_spawn_timer=10


function ennemies_spawn(tick)
   if en_spawn_timer == 0 then
       table.insert(ennemies, {
           x = love.math.random( 800 ),
           y = love.math.random( 600 ),
           dir = 0,
           speed = 150
       })
       en_spawn_timer = en_spawn_rate
   end
   en_spawn_timer = math.max(0, en_spawn_timer - tick)
end


function ennemies_move(tick)
  for i, o in ipairs(ennemies) do
   o.dir = math.pi/6 + math.atan2(player.y - o.y, player.x - o.x)
    o.x = o.x + math.cos(o.dir) * o.speed * tick
    o.y = o.y + math.sin(o.dir) * o.speed * tick
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


function love.update(tick)
  watch_escape()
  watch_mouse()
  watch_player_move(tick)
  watch_player_shoot()
  player.heat = math.max(0, player.heat - tick)
  bullets_move(tick)
  bullets_remove()
  ennemies_spawn(tick)
  ennemies_move(tick)
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


function move(tick, obj, dirX, dirY, vfx, vfy)
  local new_obj = obj
  local fx = vfx or 1
  local fy = vfy or 1

  if new_obj.x > 0 and dirX < 0 then
    new_obj.x = new_obj.x + new_obj.speed * tick * dirX * fx
  end

  if new_obj.x < love.graphics.getWidth() and dirX > 0 then
    new_obj.x = new_obj.x + new_obj.speed * tick * dirX * fx
  end

  if new_obj.y > 0 and dirY < 0 then
    new_obj.y = new_obj.y + new_obj.speed * tick * dirY * fy
  end

  if new_obj.y < love.graphics.getHeight() and dirY > 0 then
    new_obj.y = new_obj.y + new_obj.speed * tick * dirY * fy
  end

  return new_obj.x, new_obj.y
end


function watch_player_move(tick)
  local w_key = love.keyboard.isDown('up','w')
  local s_key = love.keyboard.isDown('down','s')
  local a_key = love.keyboard.isDown('left','a')
  local d_key = love.keyboard.isDown('right','d')
  local v_factor = 1

  if (w_key and (a_key or d_key)) or (s_key and (a_key or d_key)) then
    v_factor = 1 / math.sqrt(2)
  end

  if w_key then
    player.x, player.y = move(tick, player, 0, -1, v_factor, v_factor)
  end

  if s_key then
    player.x, player.y = move(tick, player, 0, 1, v_factor, v_factor)
  end

  if a_key then
    player.x, player.y = move(tick, player, -1, 0, v_factor, v_factor)
  end

  if d_key then
    player.x, player.y = move(tick, player, 1, 0, v_factor, v_factor)
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


function bullets_move(tick)
  for i, o in ipairs(bullets) do
    o.x = o.x + math.cos(o.dir) * o.speed * tick
    o.y = o.y + math.sin(o.dir) * o.speed * tick
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


function draw_scene()
  love.graphics.draw(scene, 0 ,0)
end


function draw_score()
  love.graphics.setColor(1, 85, 229)
  love.graphics.setNewFont(18)
  love.graphics.print("crabs killed: " .. tostring(player.score), 50, 30)
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


function love.draw(tick)
  draw_scene()
  draw_score()
  draw_car()
  draw_player()
  draw_bullets()
  draw_ennemies()
end
