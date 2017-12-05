require('game.gameobject')
require('game.game_objects.enemy')
require('list')
require('math_p')
require('game.globals')
require('math')
utils = require('utils')

-- Constructor
Level = class(GameObject, function(t, qt, parent)
	GameObject.init(t, qt, parent)
	t.quad_owner = qt
	t.parent = parent

	--t.levelDoorsTex = content.load_sprite("level_doors")
	t.level_tex = content.load_sprite("level")
	t.level_tex_df = content.load_sprite("level-doorframe")
	t.door_trigger_tex = content.load_sprite("door")
	t.level_rect = Rectangle(0, 0, t.level_tex:width()*world_scale, t.level_tex:height()*world_scale)
	t.level_rect_df = Rectangle(0, -(t.level_tex:height()-19)*world_scale, t.level_tex_df:width()*world_scale, (t.level_tex_df:height())*world_scale)
	t.door_trigger = Rectangle(239*world_scale, 17*world_scale, 24*world_scale, 24*world_scale)
	t.door_trigger_draw = Rectangle(235*world_scale, 0, 32*world_scale, 32*world_scale)
	-- t.level_spawn_a_rect
	t.level_bounds = List()
	t.floor_fade = 255
end)

function Level:get_id()
	return "LEVEL"
end

function Level:get_bounds()
	return self.level_rect
end


-- Invoked on initialization.
function Level:init()
	print("Generating level bounds...")
	self.level_bounds:add(Rectangle(0, 0, (32) * world_scale, 512 * world_scale))

	self.level_bounds:add(Rectangle( self.level_rect.Width-(32*world_scale), 0, 32 * world_scale, 512 * world_scale))
	self.level_bounds:add(Rectangle(0, 0, 512*world_scale, 32*world_scale))
	self.level_bounds:add(Rectangle(0, self.level_rect.Height-(32 * world_scale), 512 * world_scale, 32 * world_scale))


	-- edge rect
	self.level_bounds:add(Rectangle(0, 0, (16) * world_scale, 512 * world_scale))
	self.level_bounds:add(Rectangle( self.level_rect.Width-(16*world_scale), 0, 16 * world_scale, 512 * world_scale))
	self.level_bounds:add(Rectangle(0, 0, 512*world_scale, 16*world_scale))
	self.level_bounds:add(Rectangle(0, self.level_rect.Height-(16 * world_scale), 512 * world_scale, 16 * world_scale))

	-- Coinbounce rect
	self.level_bounds:add(Rectangle(0, 0, (24) * world_scale, 512 * world_scale))
	self.level_bounds:add(Rectangle( self.level_rect.Width-(24*world_scale), 0, 24* world_scale, 512 * world_scale))
	self.level_bounds:add(Rectangle(0, 0, 512*world_scale, 24*world_scale))
	self.level_bounds:add(Rectangle(0, self.level_rect.Height-(24 * world_scale), 512 * world_scale, 24 * world_scale))

	print("Spawning coin...")
	local c = self.level_rect:center()
	self.parent:spawn(Coin(self.quad_owner, self.parent, c.X, c.Y-64, false, 0, 0, 1), Vector2(c.X, c.Y-64))
	self.parent:spawn(Coin(self.quad_owner, self.parent, c.X+7, c.Y-62, false, 0, 0, 1), Vector2(c.X+7, c.Y-62))
	print("Coins spawned")
end


local function get_rand_within_level()
	return math.random(32*world_scale, (((512)-(32))*world_scale))
end

local spawn_timer = 100
local spawn_time = 100

-- Invoked on update
function Level:update()
	if get_wave_started() then
		if spawn_time >= spawn_timer then
			-- TODO: Handle level update (spawn mobs)
			local t = 1
			local sp = Vector2(get_rand_within_level(), get_rand_within_level())
			if get_total_enemies() < get_kills_needed()+get_extra_spawns() then
				self.parent:spawn(Enemy(self.quad_owner, self.parent, get_suitable_enemy_type(), sp), sp)
				add_enemy_spawn()
			end
			spawn_time = 0
		end
		spawn_time = spawn_time + 1
	end

	if self.parent.player.is_dead then
		if self.floor_fade > 0 then
			self.floor_fade = self.floor_fade - 4
			if self.floor_fade < 0 then
				self.floor_fade = 0
			end
		end
	end

	if game_coins == 0 and get_wave() ~= 0 and get_wave_started() then
		local cc = 0
		local coins = self.quad_owner:get_all_items():get_iterator()
		for _, v in pairs(coins) do
			if v:is_a(Coin) then
				cc = cc + 1
			end
		end
		if cc == 0 then
			local c = self.level_rect:center()
			self.parent:spawn(Coin(self.quad_owner, self.parent, c.X, c.Y-64, false, 0, 0, 1), Vector2(c.X, c.Y-64))
			self.parent:spawn(Coin(self.quad_owner, self.parent, c.X+7, c.Y-62, false, 0, 0, 1), Vector2(c.X+7, c.Y-62))
		end
	end
end



function Level:draw_doorframe()
	self.level_tex_df:draw(
		self.level_rect_df:as_primitive(),
		{0, 0, self.level_tex:width(), self.level_tex:height()},
		0,
		{fade_transition(), fade_transition(), fade_transition(), self.floor_fade+fade_transition()})
end

-- Invoked on draw
function Level:draw()
	self.level_tex:draw(
		self.level_rect:as_primitive(),
		{0, 0, self.level_tex:width(), self.level_tex:height()},
		0,
		{fade_transition(),fade_transition(),fade_transition(),self.floor_fade+fade_transition()})
	--if get_wave_started() and get_is_midway_timeout() then
	self.door_trigger_tex:draw(
		self.door_trigger_draw:as_primitive(),
		{0, 0, self.door_trigger_tex:width(), self.door_trigger_tex:height()},
		0,
		{fade_transition(),fade_transition(),fade_transition(),self.floor_fade+fade_transition()})
	--end

	if game_debug_view then
		local m = self.level_bounds:get_iterator()[1]
		utils.draw_debug_sq(m:as_primitive(), {0, 0, 255, 255})
		m = self.level_bounds:get_iterator()[2]
		utils.draw_debug_sq(m:as_primitive(), {0, 0, 255, 255})
		m = self.level_bounds:get_iterator()[3]
		utils.draw_debug_sq(m:as_primitive(), {0, 0, 255, 255})
		m = self.level_bounds:get_iterator()[4]
		utils.draw_debug_sq(m:as_primitive(), {0, 0, 255, 255})

		m = self.level_bounds:get_iterator()[5]
		utils.draw_debug_sq(m:as_primitive(), {255, 255, 0, 255})
		m = self.level_bounds:get_iterator()[6]
		utils.draw_debug_sq(m:as_primitive(), {255, 255, 0, 255})
		m = self.level_bounds:get_iterator()[7]
		utils.draw_debug_sq(m:as_primitive(), {255, 255, 0, 255})
		m = self.level_bounds:get_iterator()[8]
		utils.draw_debug_sq(m:as_primitive(), {255, 255, 0, 255})


		m = self.level_bounds:get_iterator()[9]
		utils.draw_debug_sq(m:as_primitive(), {255, 0, 0, 255})
		m = self.level_bounds:get_iterator()[10]
		utils.draw_debug_sq(m:as_primitive(), {255, 0, 0, 255})
		m = self.level_bounds:get_iterator()[11]
		utils.draw_debug_sq(m:as_primitive(), {255, 0, 0, 255})
		m = self.level_bounds:get_iterator()[12]
		utils.draw_debug_sq(m:as_primitive(), {255, 0, 0, 255})


		utils.draw_debug_sq(self.door_trigger:as_primitive(), {125, 0, 125, 255})
	end

end
