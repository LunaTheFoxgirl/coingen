require('game.game_objects.level')
require('game.gameobject')
require('game.gameworld')
require('game.globals')
utils = require('utils')
core = require('core')
require('quadtree')
require('content')
require('other')
require('list')

world_camera = Camera2D({32, 32}, {0, 0}, 0, game_zoom_level)


MainWorld = class(GameWorld, function (t)
	GameWorld.init(t)
	t.obj_list = Quadtree(Rectangle(0, 0, 512*4, 512*4), nil)
	t.has_done_init = false
	if world_camera ~= nil then
		game_zoom_level = 1
		world_camera:zoom(1)
		world_camera:position(32, 32)
		world_camera:rotation(0)
		world_camera:update()
	end
end)

function MainWorld:spawn(obj, pos)
	if obj.is_a ~= nil and obj:is_a(GameObject) then
		self.obj_list:insert(obj, pos)
		if self.has_done_init then
			obj:init()
		end
	end
end

function MainWorld:change_level(level)
	if level.is_a ~= nil and level:is_a(Level) then
		self.level = level
	end
end

function MainWorld:get_of_type(t)
	o = List()
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i:is_a(t) then
			o:add(i)
		end
	end
	return o
end

function MainWorld:draw()
	core.begin_camera(world_camera)
	self.level:draw()
	if game_debug_view then
		self.obj_list:visualize()
	end
	core.end_camera()
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			if i:get_order() == 0 then
				i:draw()
			end
		else
			print("Object was not GameObject, ERROR")
			core:exit()
			return
		end
	end
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			if i:get_order() == 1 then
				i:draw()
			end
		else
			print("Object was not GameObject, ERROR")
			core:exit()
			return
		end
	end
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			if i:get_order() == 2 then
				i:draw()
			end
		else
			print("Object was not GameObject, ERROR")
			core:exit()
			return
		end
	end
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			if i:get_order() == 3 then
				i:draw()
			end
		else
			print("Object was not GameObject, ERROR")
			core:exit()
			return
		end
	end
	core.begin_camera(world_camera)
	self.level:draw_doorframe()
	if self.player.is_dead then
		utils.draw_string("YOU DIED", (self.player.position.X)-64, (self.player.position.Y)-32, 32, {255, 0, 0, 255})
		utils.draw_string("Press R to restart", (self.player.position.X)-64, (self.player.position.Y), 16, {255, 0, 0, 255})

	end
	core.end_camera()
	local cx, cy = input.mouse_position()
	--utils.draw_string(self.quad_owner:__tostring(), 0, 64, 20, {255, 255, 0, 255})
	utils.draw_string(""..game_coins, cx+6, cy+6, 20, {255, 255, 0, 255})
	utils.draw_string("+", cx-6, cy-6, 20, {255, 255, 252, 255})

	--game_sprites["spook"]:draw({0, 0, game_window:width(), game_window:height()}, {0,0, game_sprites["spook"]:width(), game_sprites["spook"]:height()}, 0, {255, 255, 255, 255})
	utils.draw_string("COINS: "..game_coins, 8, game_window:height()-28, 32, {255, 255, 0, 255})
	if not self.player.is_dead then
		if get_wave() > 0 then
			if get_wave_started() then
				local lx = utils.measure_string("WAVE "..get_wave(), 67)*world_scale
				utils.draw_string("WAVE "..get_wave(), (game_window:width()/2)-(lx/2), 0, 67, {255, 255, 0, 255})
			else
				local lx = utils.measure_string("WAVE TIMEOUT", 67)*world_scale
				utils.draw_string("READY UP", (game_window:width()/2)-(lx/2), 0, 67, {255, 255, 0, 255})
			end
		end
	end
end

function MainWorld:relocate_me(me)
	self.obj_list:relocate(me)
end


function MainWorld:update()
	game_shaders["i_frames"]:set_uniform("state", {game_shd_iter})
	game_shd_iter = game_shd_iter + 0.2
	self.level:update()
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			i:update()
		else
			print("Object was not GameObject, ERROR")
			core:exit()
			return
		end
	end

	-- Cleanup of dead entities
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			if i.alive == false then
				self.obj_list:delete(i)
			end
		end
	end
	update_wave_handler()
	world_camera:zoom(game_zoom_level)
end

function MainWorld:init()
	game_audio["shopmus"]:volume(1)
	game_audio["shopmus"]:play()

	self.level = Level(self.obj_list, self)
	self.level:init()
	print("Initialized level...")

	self.player = Player(self.obj_list, self, self.level.level_rect:center())
	self:spawn(self.player, self.level.level_rect:center())
	print("Spawned player...")


	print("Running init on other entities...")
	--print(#r)
	for _, i in pairs(self.obj_list:get_all_items():get_iterator()) do
		if i.is_a ~= nil and i:is_a(GameObject) then
			i:init()
		else
			print("Object was not GameObject, ERROR")
			core:exit()
			return
		end
	end
	self.has_done_init = true
	print("Gameworld initiated...")
	reset_fade()
	set_fade_speed(10)
	fade_in(function()
	end)
end
