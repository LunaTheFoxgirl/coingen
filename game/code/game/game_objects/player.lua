require('game.gameobject')
require('math_p')
require('game.globals')
require('game.shopworld')
require('game.mainworld')
content = require('content')
input = require('input')
utils = require('utils')

Player = class(GameObject, function(t, qt, parent, start_pos)
	GameObject.init(t, qt, parent)
	t.quad_owner = qt
	t.parent = parent
	t.lives = 3
	t.has_landed = false
	t.position = Rectangle(start_pos.X, start_pos.Y-256, 7, 20)
	t.offset_target = Vector2(start_pos.X, start_pos.Y)
	t.hurt = 0
	t.health = game_player_lives
	t.if_tick = 11
	t.is_dead = false
	t.has_played = false
end)


local anim = 1
local anim_frame = 1
local speed = 0
local last_speed = 0
local anim_tick = 0
local anim_frames = 4

function get_animation_rect(sqsz, flipped)
	if flipped then
		return {(sqsz*anim_frames)-(sqsz*(anim_frame+1)), anim*sqsz, sqsz, sqsz}
	end
	return {anim_frame*sqsz, anim*sqsz, sqsz, sqsz}
end

local function change_animation(anm, spd)
	anim = anm
	anim_frame = 0
	speed = spd
end

local function update_animation(endfunc)
	if speed > 0 then
		if anim_tick >= speed then
			anim_frame = anim_frame + 1
			anim_tick = 0
			if anim_frame > anim_frames then
				anim_frame = 1
				endfunc()
			end
		end
		anim_tick = anim_tick + 1
	end
	if speed ~= last_speed then
		last_speed = speed
	end
end

function Player:get_bounds()
	return self.position
end

function Player:get_order()
	return 2
end

function Player:get_id()
	return "PLAYER"
end

function Player:__tostring()
	return self:get_id()
end

function Player:hitbox()
	return Rectangle(self.position.X, self.position.Y, self.position.Width*world_scale, (self.position.Height-7)*world_scale)
end

function Player:draw_box()
	return Rectangle(self.position.X-(13*world_scale), self.position.Y-(17*world_scale), 32*world_scale, 32*world_scale)
end

function Player:draw_box_lo()
	return Rectangle(self.offset_target.X-(13*world_scale), self.offset_target.Y-(12*world_scale), 32*world_scale, 32*world_scale)
end

function Player:init()
	print("Player initialized!")
	self.spr = game_sprites["player"]
end

local throwing = false
function Player:throw(t)
	if game_coins > 0 then
		if t == 2 then
			if game_coins < 10 then
				return
			end
		end
		throwing = true
		anim_frame = 0
		anim_tick = 0
		local mx, my = input.mouse_position()
		local hb = self:hitbox()
		local ww = game_window:width()
		local wh = game_window:height()
		local direction = (Vector2(mx, my) - Vector2(ww/2, wh/2)):normalize()
		self.parent:spawn(Coin(self.quad_owner, self.parent, hb.X, hb.Y, true, direction.X, direction.Y, t), Vector2(hb.X, hb.Y))
		if direction.X > 0 then
			self.spr:flip_h(false)
		elseif direction.X < 0 then
			self.spr:flip_h(true)
		end
		game_coins = game_coins - 1
	end
end

function Player:get_collide_axis(moved, t)
	local m1 = self.parent.level.level_bounds:get_iterator()[1+t]
	local m2 = self.parent.level.level_bounds:get_iterator()[2+t]
	local hb = self:hitbox()
	local t_rect = Rectangle(hb.X+moved.X, hb.Y+moved.Y, hb.Width, hb.Height)

	if m1:intersects(t_rect) then
		return true
	end
	if m2:intersects(t_rect) then
		return true
	end
	return false
end

function Player:damage(life)
	if not self.is_dead and self.hurt == 0 and self.if_tick == 0 then
		self.health = self.health - life
		self.hurt = 1
		self.if_tick = game_iframe_time
		game_audio["hurt"]:pitch(1+(math.random()/2))
		game_audio["hurt"]:play()
		if self.health <= 0 then
			self.is_dead = true
		end
	end
end

local t = 0
local ot = game_throw_timeout
local cam_rot = 0
local dc_count = 20
local dc_res = 20
function Player:update()
	if not self.is_dead then
		if self.has_landed then
			if self.hurt > 0 then
				self.hurt = self.hurt - 0.05
			else
				if self.hurt < 0 then
					self.hurt = 0
					game_shd_iter = 0
				end
			end

			if self.if_tick > 0 then
				self.if_tick = self.if_tick - 1
			else
				if self.if_tick < 0 then
					self.if_tick = 0
					game_shd_iter = 0
				end
			end


			if input.is_mouse_down(input.mouse_left) then
				if t == 0 then
					self:throw(1)
					t = ot
				end
			end

			if input.is_mouse_up(input.mouse_left) then
				t = 0
			end

			if t ~= 0 then
				t = t - 1
			end

			self:handle_move()
			world_camera:update()
			return
		else
			self.position.Y = self.position.Y + 6
			if self.position.Y > self.offset_target.Y then
				self.position.Y = self.offset_target.Y
				self.has_landed = true
			end
			local hb = self.position:center()
			local cx = (-(self.position.X)*game_zoom_level) + game_window:width()/2
			local cy = (-(self.position.Y)*game_zoom_level) + game_window:height()/2
			world_camera:position(cx, cy)
			world_camera:update()
			return
		end
	end
	if game_zoom_level < 4 then
		game_zoom_level = game_zoom_level + 0.05
		cam_rot = cam_rot - 0.01
		world_camera:origin(self.position.X, self.position.Y+12)
		world_camera:rotation(cam_rot)
		world_camera:update()
		anim_frame = 3
		self.spr:flip_h(true)
		if not self.has_played then
			game_audio["death"]:play()
			self.has_played = true
		end
		return
	end
	anim = 4
	if anim_frame > 1 and dc_count > 0 then
		dc_count = dc_count - 1
		if dc_count <= 0 then
			dc_count = dc_res
			anim_frame = anim_frame - 1
		end
	end
	if input.is_key_pressed(input.key_r) then
		game_coins = 0
		restart_game()
	end
end


function Player:draw()
	local w = (self.spr:width()*world_scale)*game_zoom_level
	local h = (self.spr:height()*world_scale)*game_zoom_level
	local hb = self:hitbox()
	local db = self:draw_box()
	local dbl = self:draw_box_lo()

	game_shaders["hurt"]:set_uniform("hurt", {self.hurt})
	core.begin_camera(world_camera)
	if self.has_landed then
		game_sprites["shadow"]:draw({db.X+(12*world_scale), db.Y+(28*world_scale), 32, 32}, {0, 0, game_sprites["shadow"]:width(), game_sprites["shadow"]:height()}, 0, {255, 255, 255, 255+fade_transition()})
	else
		game_sprites["shadow"]:draw({dbl.X+(12*world_scale), dbl.Y+(28*world_scale), 32, 32}, {0, 0, game_sprites["shadow"]:width(), game_sprites["shadow"]:height()}, 0, {255, 255, 255, 255+fade_transition()})
	end
	if self.hurt > 0 then
		game_shaders["hurt"]:begin_pass()
	elseif self.if_tick > 0 then
		game_shaders["i_frames"]:begin_pass()
	end
	self.spr:draw({db.X, db.Y, db.Width, db.Height}, get_animation_rect(32, self.spr:flip_h()), 0, {fade_transition(), fade_transition(), fade_transition(), fade_transition()})
	self.parent.level:draw_doorframe()
	if game_debug_view then
		utils.draw_debug_sq(get_animation_rect(32, self.spr:flip_h()), {255, 0, 0, 255})
		utils.draw_debug_sq(db:as_primitive(), {255, 0, 0, 255})
		utils.draw_debug_sq(hb:as_primitive(), {0, 0, 255, 255})
		utils.draw_string(self.quad_owner.bounds.X.."::"..self.quad_owner.bounds.Y, self.position.X, self.position.Y, 12, {255, 255, 252, 255})
	end
	game_shaders["hurt"]:end_pass()
	game_shaders["hurt"]:set_uniform("hurt", {0})
end


local function on_throw_end()
	if anim >= 2 then
		anim = anim - 2
		anim_frame = 0
		speed = 10
		throwing = false
	end
end

-- Might be added later.
function Player:handle_shopkeeper_intrance()
	--[[if self.parent.level.door_trigger:intersects(self:hitbox()) then
		if not (get_wave_started() and get_is_midway_timeout()) then
			self.position.Y = self.position.Y - 2
			local door = self.parent.level.door_trigger:center()
			if door.X > self:hitbox():center().X then
				self.position.X = self.position.X + 1
			end
			if door.X < self:hitbox():center().X then
				self.position.X = self.position.X - 1
			end
			reset_fade()
			set_fade_speed(2)
			fade_out(function()
				set_game_world(MainWorld(self))
			end)
		end
	end
	return false]]--
end

function Player:handle_move()
	if self:handle_shopkeeper_intrance() == true then
		return
	end

	local nextY = 0
	local nextX = 0

	-- FIXME: Fix animations

	if input.is_key_down(input.key_w) or input.is_key_down(input.key_s) or input.is_key_down(input.key_a) or input.is_key_down(input.key_d) then
		if anim ~= 1 or (throwing and anim ~= 3) then
			if throwing == true then
				speed = 10
				anim = 3
			else
				change_animation(1, 10)
			end
		end
	else
		if anim ~= 0 or (throwing and anim ~= 2) then
			if throwing == true then
				speed = 10
				anim = 2
			else
				change_animation(0, 10)
			end
		end
	end

	if input.is_key_down(input.key_w) then
		nextY = -3
	elseif input.is_key_down(input.key_s) then
		nextY = 3
	end

	if self:get_collide_axis(Vector2(nextX, nextY), 2) then
		nextY = 0
	end

	if input.is_key_down(input.key_a) then
		self.spr:flip_h(true)
		nextX = -3
	elseif input.is_key_down(input.key_d) then
		self.spr:flip_h(false)
		nextX = 3
	end

	if self:get_collide_axis(Vector2(nextX, nextY), 0) then
		nextX = 0
	end

	update_animation(on_throw_end)

	self.position.X = self.position.X + nextX
	self.position.Y = self.position.Y + nextY

	if nextX ~= 0 or nextY ~= 0 then
		self.parent:relocate_me(self)
	end

	-- FIXME: Better camera pls

	local hb = self.position:center()
	local cx = (-(self.position.X)*game_zoom_level) + game_window:width()/2
	local cy = (-(self.position.Y)*game_zoom_level) + game_window:height()/2
	world_camera:position(cx, cy)

end
