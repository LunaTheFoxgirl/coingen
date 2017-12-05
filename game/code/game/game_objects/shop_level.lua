require('game.gameobject')
require('game.game_objects.enemy')
require('list')
require('math_p')
require('game.globals')
require('math')
utils = require('utils')

-- Constructor
ShopLevel = class(GameObject, function(t, qt, parent)
	GameObject.init(t, qt, parent)
	t.quad_owner = qt
	t.parent = parent

	--t.levelDoorsTex = content.load_sprite("level_doors")
	t.level_tex = content.load_sprite("shoplevel")
	t.level_tex_df = content.load_sprite("shoplevel-doorframe")
	t.door_trigger_tex = content.load_sprite("shoplevel-door")
	t.level_rect = Rectangle(0, 0, t.level_tex:width()*world_scale, t.level_tex:height()*world_scale)
	t.level_rect_df = Rectangle(0, -(t.level_tex:height()-19)*world_scale, t.level_tex_df:width()*world_scale, (t.level_tex_df:height())*world_scale)
	t.door_trigger = Rectangle(239*world_scale, 17*world_scale, 24*world_scale, 24*world_scale)
	t.door_trigger_draw = Rectangle(235*world_scale, 0, 32*world_scale, 32*world_scale)
	-- t.level_spawn_a_rect
	t.level_bounds = List()
	t.floor_fade = 255
end)

function ShopLevel:get_id()
	return "LEVEL"
end

function ShopLevel:get_bounds()
	return self.level_rect
end


-- Invoked on initialization.
function ShopLevel:init()
	print("Generating level bounds...")
	self.level_bounds:add(Rectangle(0, 0, (32) * world_scale, 256 * world_scale))

	self.level_bounds:add(Rectangle( self.level_rect.Width-(32*world_scale), 0, 32 * world_scale, 256 * world_scale))
	self.level_bounds:add(Rectangle(0, 0, 256*world_scale, 32*world_scale))
	self.level_bounds:add(Rectangle(0, self.level_rect.Height-(32 * world_scale), 256 * world_scale, 32 * world_scale))

	-- Coinbounce rect
	self.level_bounds:add(Rectangle(0, 0, (24) * world_scale, 256 * world_scale))
	self.level_bounds:add(Rectangle( self.level_rect.Width-(24*world_scale), 0, 24* world_scale, 256 * world_scale))
	self.level_bounds:add(Rectangle(0, 0, 256*world_scale, 24*world_scale))
	self.level_bounds:add(Rectangle(0, self.level_rect.Height-(24 * world_scale), 256 * world_scale, 24 * world_scale))
end


local function get_rand_within_level()
	return math.random(32*world_scale, (((256)-(32))*world_scale))
end

local spawn_timer = 100
local spawn_time = 100

-- Invoked on update
function ShopLevel:update()

end



function ShopLevel:draw_doorframe()
	self.level_tex_df:draw(
		self.level_rect_df:as_primitive(),
		{0, 0, self.level_tex:width(), self.level_tex:height()},
		0,
		{fade_transition(), fade_transition(), fade_transition(), self.floor_fade+fade_transition()})
end

-- Invoked on draw
function ShopLevel:draw()
	self.level_tex:draw(
		self.level_rect:as_primitive(),
		{0, 0, self.level_tex:width(), self.level_tex:height()},
		0,
		{fade_transition(),fade_transition(),fade_transition(),self.floor_fade+fade_transition()})


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

	end

end
