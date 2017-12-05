require('game.gameobject')
require('game.game_objects.coin')
require('math_p')
require('game.globals')
require('math')
content = require('content')
input = require('input')
utils = require('utils')

Enemy = class(GameObject, function(t, qt, world_parent, c_tpe, p)
	GameObject.init(t, qt, world_parent)
	t.quad_owner = qt
	t.parent = world_parent
	t.c_type = c_tpe
	t.offset_target = Vector2(p.X, p.Y)
	t.has_landed = false
	t.position = Rectangle(p.X, p.Y-256, 7, 20)
	t.health = 2
	t.hurt = 0
	t.if_tick = 11
	if t.c_type == "RAIDER" then
		t.spr = game_sprites["enemy1_1"]
	else
		t.spr = game_sprites["enemy2_1"]
	end
	t.anim = 1
	t.anim_frame = 1
	t.speed = 1
	t.last_speed = 0
	t.anim_tick = 0
	t.anim_frames = 4
end)

function Enemy:get_id()
	return "ENEMY"
end

function Enemy:get_bounds()
	return self:hitbox()
end

function Enemy:get_order()
	if self.position.Y < self.parent.player.position.Y then
		return 1
	else
		return 3
	end
end

function Enemy:__tostring()
	return self:get_id()
end

function Enemy:init()

end

function Enemy:hitbox()
	return Rectangle(self.position.X, self.position.Y, self.position.Width*world_scale, (self.position.Height-7)*world_scale)
end

function Enemy:draw_box()
	return Rectangle(self.position.X-(13*world_scale), self.position.Y-(12*world_scale), 32*world_scale, 32*world_scale)
end

function Enemy:draw_box_lo()
	return Rectangle(self.offset_target.X-(13*world_scale), self.offset_target.Y-(12*world_scale), 32*world_scale, 32*world_scale)
end

function Enemy:get_collide_axis(moved, t)
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

function Enemy:damage(dmg)
	if self.hurt == 0 and self.if_tick == 0 then
		self.health = self.health - dmg
		self.hurt = 1
		self.if_tick = 30
		game_audio["hurt"]:pitch(1+(math.random()/2))
		game_audio["hurt"]:play()
		if self.health < 1 then
			add_kill()
			self.alive = false
			local hb = self.position
			self.parent:spawn(Coin(self.parent.i_list, self.parent, (hb.X+(math.random()*32)-16), (hb.Y+(math.random()*32)-16), false, 0, 0, 1), Rectangle(0, 0, 16, 16))
			self.parent:spawn(Coin(self.parent.i_list, self.parent, (hb.X+(math.random()*32)-16), (hb.Y+(math.random()*32)-16), false, 0, 0, 1), Rectangle(0, 0, 16, 16))
			self.parent:spawn(Coin(self.parent.i_list, self.parent, (hb.X+(math.random()*32)-16), (hb.Y+(math.random()*32)-16), false, 0, 0, 1), Rectangle(0, 0, 16, 16))
			self.parent:spawn(Coin(self.parent.i_list, self.parent, (hb.X+(math.random()*32)-16), (hb.Y+(math.random()*32)-16), false, 0, 0, 1), Rectangle(0, 0, 16, 16))
		end
	end
end

function Enemy:get_animation_rect(sqsz, flipped)
	if flipped then
		return {(sqsz*self.anim_frames)-(sqsz*(self.anim_frame+1)), self.anim*sqsz, sqsz, sqsz}
	end
	return {self.anim_frame*sqsz, self.anim*sqsz, sqsz, sqsz}
end

function Enemy:change_animation(anm, spd)
	self.anim = anm
	self.anim_frame = 0
	self.speed = spd
end

function Enemy:update_animation(endfunc)
	if self.speed > 0 then
		if self.anim_tick >= self.speed then
			self.anim_frame = self.anim_frame + 1
			self.anim_tick = 0
			if self.anim_frame > self.anim_frames then
				self.anim_frame = 1
				if endfunc ~= nil then
					endfunc()
				end
			end
		end
		self.anim_tick = self.anim_tick + 1
	end
	if self.speed ~= self.last_speed then
		self.last_speed = self.speed
	end
end

function Enemy:draw()
	local cx, cy = input.mouse_position()
	local w = (self.spr:width()*world_scale)*game_zoom_level
	local h = (self.spr:height()*world_scale)*game_zoom_level
	local hb = self:hitbox()
	local db = self:draw_box()
	local dbl = self:draw_box_lo()

	core.begin_camera(world_camera)

	-- TODO: add fancy shadow scaling on fall.
	if self.has_landed then
		game_sprites["shadow"]:draw({db.X+(12*world_scale), db.Y+(28*world_scale), 32, 32}, {0, 0, game_sprites["shadow"]:width(), game_sprites["shadow"]:height()}, 0, {255, 255, 255, fade_transition()})
	else
		game_sprites["shadow"]:draw({dbl.X+(12*world_scale), dbl.Y+(28*world_scale), 32, 32}, {0, 0, game_sprites["shadow"]:width(), game_sprites["shadow"]:height()}, 0, {255, 255, 255, fade_transition()})
	end

	game_shaders["hurt"]:set_uniform("hurt", {self.hurt})
	if self.hurt > 0 then
		game_shaders["hurt"]:begin_pass()
	elseif self.if_tick > 0 then
		game_shaders["i_frames"]:begin_pass()
	end
	self.spr:draw({db.X, db.Y, db.Width, db.Height}, self:get_animation_rect(32, self.spr:flip_h()), 0, {255, 255, 255, fade_transition()})
	game_shaders["i_frames"]:end_pass()
	if game_debug_view then
		utils.draw_debug_sq(get_animation_rect(32, self.spr:flip_h()), {255, 0, 0, 255})
		utils.draw_debug_sq(db:as_primitive(), {255, 0, 0, 255})
		utils.draw_debug_sq(hb:as_primitive(), {0, 0, 255, 255})
		utils.draw_string(self.quad_owner.bounds.X.."::"..self.quad_owner.bounds.Y, self.position.X, self.position.Y, 12, {255, 255, 252, 255})
	end
	core.end_camera()
end

function Enemy:update()
	self.spr:flip_h(false)
	if self.parent.player.position.X < self.position.X then
		self.spr:flip_h(true)
	end

	if not self.parent.player.is_dead then
		if self.has_landed then
		self:update_animation(function()
				self:change_animation(1, 10)
		end)
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
			local nextX = 0
			local nextY = 0

			if self.position.Y < self.parent.player.position.Y then nextY = 1 end
			if self.position.Y > self.parent.player.position.Y then nextY = -1 end

			if self:get_collide_axis(Vector2(nextX, nextY), 2) then
				nextY = 0
			end

			if self.position.X < self.parent.player.position.X then nextX = 1 end
			if self.position.X > self.parent.player.position.X then nextX = -1 end

			if self:get_collide_axis(Vector2(nextX, nextY), 0) then
				nextX = 0
			end
			if self.c_type == "SERIAL_KILLER" then
				nextX = nextX * 2
				nextY = nextY * 2
			end
			self.position.X = self.position.X + nextX
			self.position.Y = self.position.Y + nextY

			self.parent:relocate_me(self)
			self:handle_attack()
			return
		end

		self.position.Y = self.position.Y + 3
		if self.position.Y > self.offset_target.Y then
			self.position.Y = self.offset_target.Y
			self.has_landed = true
		end
	end
end

function Enemy:handle_attack()

	-- MEELE ATTACK
	local enemies = self.quad_owner:get_all_items():get_iterator()
	for _, v in pairs(enemies) do
		if v:is_a(Player) then
			if self:hitbox():intersects(v:hitbox()) then
				if self.ctype == "SERIAL_KILLER" then
					v:damage(2)
				end
				v:damage(1)
				self:change_animation(2, 10)
				return
			end
		end
	end
end

function Enemy:handle_move()
	local nextY = 0
	local nextX = 0

	if self:get_collide_axis(Vector2(nextX, nextY), 2) then
		nextY = 0
	end


	if self:get_collide_axis(Vector2(nextX, nextY), 0) then
		nextX = 0
	end


	self.position.X = self.position.X + nextX
	self.position.Y = self.position.Y + nextY

	local hb = self.position:center()
	local cx = (-(self.position.X)*game_zoom_level) + game_window:width()/2
	local cy = (-(self.position.Y)*game_zoom_level) + game_window:height()/2
	world_camera:position(cx, cy)

end
