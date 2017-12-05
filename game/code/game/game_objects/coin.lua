require('game.globals')
core = require('core')
--[[
COIN TYPES:
1 - Coin
2 - Gold bar
3 - Artifact
]]--
Coin = class(GameObject, function(t, qt, parent, posX, posY, throwable, velX, velY, ty)
	GameObject.init(t, qt, parent)
	t.quad_owner = qt
	t.parent = parent
	t.throwable = throwable
	t.throw_velocity = Vector2(velX*5, velY*5)
	t.position = Rectangle(posX, posY, 6*world_scale, 6*world_scale)
	t.rotation = 0
	t.rot_speed = 5
	t.lifetime = 0
	t.coin_type = ty
	t.has_given = false
	t.has_hit = false
	t.fade = 255
end)

function Coin:get_id()
	return "COIN"
end

function Coin:get_bounds()
	return self:hitbox()
end

function Coin:get_order()
	return 0
end

function Coin:hitbox()
	return Rectangle(self.position.X-((6*world_scale)/2), self.position.Y-((6*world_scale)/2), self.position.Width, self.position.Height)
end

function Coin:__tostring()
	return self:get_id()
end

function Coin:init()
	if self.coin_type == 1 then
		self.sprite = game_sprites["coin1"]
	elseif self.coin_type == 2 then
		self.sprite = game_sprites["coin2"]
	end
	self.sprite:rot_origin({6*world_scale, 6*world_scale})
	if self.throwable then
		self.rotation = 1
	end
end

function Coin:draw()
	core.begin_camera(world_camera)
		self.sprite:draw(
		Rectangle(self.position.X, self.position.Y, 12*world_scale, 12*world_scale):as_primitive(),
		{0, 0, 16, 16},
		self.rotation,
		{255, 255, 255, self.fade+fade_transition()})
	if game_debug_view then
		utils.draw_debug_sq(self:hitbox():as_primitive(), {0, 0, 255, 255})
		utils.draw_string(self.quad_owner.bounds.X.."::"..self.quad_owner.bounds.Y, self.position.X-6, self.position.Y-24, 12, {255, 255, 252, 255})
	end
	core.end_camera()
	--utils.draw_string(self.position.X.."::"..self.position.Y, self.position.X, self.position.Y, 20, {255, 255, 252, 255})

end

function Coin:get_collide_axis(moved, t)
	local m1 = self.parent.level.level_bounds:get_iterator()[9+t]
	local m2 = self.parent.level.level_bounds:get_iterator()[10+t]
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

function Coin:get_collide_index(tx)
	local m1 = self.parent.level.level_bounds:get_iterator()[tx]
	local hb = self:hitbox()
	local t_rect = Rectangle(hb.X, hb.Y, hb.Width, hb.Height)

	if m1:intersects(t_rect) then
		return true
	end
	return false
end

function Coin:update()
	self.lifetime = self.lifetime + 1
	if self.has_hit then
		self.fade = self.fade - 4
		if self.fade <= 0 then
			self.alive = false
		end
	end

	if self.throwable and self.lifetime == 200 then
		self.throwable = false
		return
	end

	if self.throwable then
		self.parent:relocate_me(self)
		self:update_t()
		return
	end
	if self.quad_owner:contains_id("PLAYER") then
		if self:get_collide_index(1) then
			self.position.X = self.position.X + 2
		end

		if self:get_collide_index(2) then
			self.position.X = self.position.X - 2
		end

		if self:get_collide_index(3) then
			self.position.Y = self.position.Y + 2
		end

		if self:get_collide_index(4) then
			self.position.Y = self.position.Y - 2
		end

		self:update_n()
	end
end


function Coin:update_t()
	self.rotation = self.rotation + self.rot_speed
	if self:get_collide_axis(self.throw_velocity, 0) then
		self.throw_velocity.X = -(self.throw_velocity.X/2)
		self.rot_speed = self.rot_speed - 1
		if not game_player_bounce_shot then
			self.throw_velocity.X = 0
			self.throw_velocity.Y = 0
			self.rot_speed = 0
			self.throwable = false
		end
	end
	self.position.X = self.position.X + self.throw_velocity.X
	if self:get_collide_axis(self.throw_velocity, 2) then
		self.throw_velocity.Y = -(self.throw_velocity.Y/2)
		self.rot_speed = self.rot_speed - 1
		if not game_player_bounce_shot then
			self.throw_velocity.X = 0
			self.throw_velocity.Y = 0
			self.rot_speed = 0
			self.throwable = false
		end
	end
	self.position.Y = self.position.Y + self.throw_velocity.Y
	local enemies = self.quad_owner:get_all_items():get_iterator()
	for _, v in pairs(enemies) do
		if v:is_a(Enemy) then
			if self:hitbox():intersects(v:hitbox()) then
				if self.coin_type == 1 then
					v:damage(1)
				elseif self.coin_type == 2 then
					v:damage(5)
				end
				self.throw_velocity.X = 0
				self.throw_velocity.Y = 0
				self.rot_speed = 0
				self.throwable = false
				self.has_hit = true
				return
			end
		end
	end

end


function Coin:update_n()
	if not self.has_hit and self.parent.player.has_landed then
		local hb = self.parent.player:hitbox()
		local players = self.quad_owner:get_all_items():get_iterator()
		for _, v in pairs(players) do
			if v:is_a(Player) then
				if self:hitbox():intersects(v:hitbox()) then
					self.has_given = true
					self.alive = false
					game_coins = game_coins + 1
					game_audio["coin"]:play()
					if get_wave() == 0 then
						next_wave()
						start_wave()
					end
					return
				end
			end
		end
	end
end

