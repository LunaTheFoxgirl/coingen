utils = require('utils')
require('math_p')
require('list')

--[[
	QUADTREE
]]--

QuadtreeItem = class(function(t, owner)
	t.quad_owner = owner
end)

function QuadtreeItem:get_bounds() end
function QuadtreeItem:get_id() end

function QuadtreeItem:__tostring()
	return "[NO_DATA]"
end


Quadtree = class(function(t, bnds, parnt)
	t.qt_capacity = 100
	t.qt_max_level = 2
	t.bounds = bnds
	t.parent = parnt
	t.objects = List()
	t.id_list = List()
end)

function Quadtree:__tostring()
	return "["..self.qt_capacity..", "..self.qt_max_level..", "..self.bounds:__tostring().."]"
end

function Quadtree:is_q_empty()
	if self.north_west == nil and self.objects:count() < 1 then
		return true
	end
	return false
end

function Quadtree:is_empty()
	if self.north_west ~= nil then
		if self.north_west:is_q_empty() and
		   self.north_east:is_q_empty() and
		   self.south_east:is_q_empty() and
		   self.south_west:is_q_empty() then
			return true
		end
	end
	return false
end

function Quadtree:clean_up()
	if self.north_west ~= nil then
		if self:is_empty() then
			self.north_west = nil
			self.north_east = nil
			self.south_east = nil
			self.south_west = nil
			if self.parent ~= nil and self:total_count() == 0 then
				self.parent:clean_up()
			end
		end
	else
		if self.parent ~= nil and self:total_count() == 0 then
			self.parent:clean_up()
		end
	end
end

function Quadtree:get_destination(item)
	local d_tree = self


	if self.north_west.bounds:intersects(item:get_bounds()) then
		d_tree = self.north_west
	end
	if self.north_east.bounds:intersects(item:get_bounds()) then
		d_tree = self.north_east
	end
	if self.south_east.bounds:intersects(item:get_bounds()) then
		d_tree = self.south_east
	end
	if self.south_west.bounds:intersects(item:get_bounds()) then
		d_tree = self.south_west
	end

	return d_tree
end

local rel_i = 0

function Quadtree:relocate(item)
	if item == nil then
		return
	end
	if self.bounds:intersects(item:get_bounds()) then
		if self.north_west ~= nil then
			local dest = self:get_destination(item)
			if item.quad_owner ~= dest then
				local f_owner = item.quad_owner
				self:delete(item, false)
				dest:insert(item, item:get_bounds())

				print(item:get_id().. " relocated item to "..dest.bounds:__tostring())
				f_owner:clean_up()
				rel_i = rel_i+1
			end
		end
	else
		if self.parent ~= nil then
			self.parent:relocate(item)
		end
	end
end

function Quadtree:get_all_items()
	local i = List()
	i:add_range(self.objects)
	if self.north_west ~= nil then
		i:add_range(self.north_west:get_all_items())
		i:add_range(self.north_east:get_all_items())
		i:add_range(self.south_east:get_all_items())
		i:add_range(self.south_west:get_all_items())
		--print("adding subgrid")
	end
	return i
end

function Quadtree:get_item_ids()
	local i = self:get_all_items()
	local l = List()
	if i ~= nil then
		for _, v in pairs(i:get_iterator()) do
			if not l:contains(v:get_id()) then
				l:add(v)
			end
		end
	end
	return l
end

function Quadtree:contains_id(id)
	return self.id_list:contains(id)
end

function Quadtree:debug_contains_content()
	print(self.id_list:__tostring())
end

function Quadtree:move(item)
	if item.quad_owner ~= nil then
		item.quad_owner:relocate(item)
		return
	end
	self:relocate(item)
end

function Quadtree:total_count()
	local c = self.objects:count()
	c = c + self.north_west:total_count()
	c = c + self.north_east:total_count()
	c = c + self.south_east:total_count()
	c = c + self.south_west:total_count()
	return c
end

function Quadtree:subdivide()
	if parent.parent ~= nil then
		self.north_west = Quadtree(Rectangle(self.bounds.X, self.bounds.Y, self.bounds.Width/2, self.bounds.Height/2))
		self.north_east = Quadtree(Rectangle(self.bounds.X+(self.bounds.Width/2), self.bounds.Y, self.bounds.Width/2, self.bounds.Height/2))
		self.south_east = Quadtree(Rectangle(self.bounds.X+(self.bounds.Width/2), self.bounds.Y+(self.bounds.Height/2), self.bounds.Width/2, self.bounds.Height/2))
		self.south_west = Quadtree(Rectangle(self.bounds.X, self.bounds.Y+(self.bounds.Height/2), self.bounds.Width/2, self.bounds.Height/2))
		for i, v in pairs(self.objects:get_iterator()) do
			local obj = v
			local dst_tree = self:get_destination(obj)
			if dst_tree ~= self then
				dst_tree:insert(obj, obj:get_bounds())
				self:remove(obj)
			end
		end
	end
end

function Quadtree:insert(item, ps, i)

	if i == nil then
		i = 1
	end

	-- If nil, ignore.
	if ps == nil then
		return false
	end

	-- If not inside, ignore
	if not self.bounds:intersects(ps) then
		return false
	end

	-- If inside, and there's space, add.
	if self.objects:count() < self.qt_capacity or i > self.qt_max_level  then
		item.quad_owner = self
		self.objects:add(item)
		self.id_list = self:get_item_ids()
		return true
	end

	if self.north_west == nil then
		self:subdivide()
	end

	if self.north_west:insert(item, ps, i+1) then return true end
	if self.north_east:insert(item, ps, i+1) then return true end
	if self.south_east:insert(item, ps, i+1) then return true end
	if self.south_west:insert(item, ps, i+1) then return true end

	return false
end

function Quadtree:query(area)

	-- Return value, objects
	local pnts = List()

	-- If area is not in bounds, return empty list.
	if not self.bounds:intersects(area) then
		return pnts
	end

	-- Query this level.
	for i=1, self.objects:count(), 1 do
		if area:intersects(self.objects:get_iterator()[i]) then
			pnts:add(self.objects:get_iterator()[i])
		end
	end

	-- Terminate if no children.
	if self.north_west == nil then return pnts end

	-- Else, add objects from children.
	pnts:add_range(self.north_west:query(area))
	pnts:add_range(self.north_east:query(area))
	pnts:add_range(self.south_east:query(area))
	pnts:add_range(self.south_west:query(area))

	-- Return the result.
	return pnts
end

function Quadtree:delete(item, clean)
	if item.quad_owner ~= nil then
		if item.quad_owner == self then
			self:remove(item)
			self.id_list = self:get_item_ids()
			if clean then
				self:clean_up()
			end
		else
			item.quad_owner:delete(item)
		end
	end
end

function Quadtree:remove(item)
	if self.objects ~= nil then
		self.objects:remove(item)
	end
end

function Quadtree:visualize(i)
	if self.objects:count() > 0 then
		utils.draw_debug_sq(self.bounds:as_primitive(), {255*(self.objects:count()/self.qt_capacity), 255/(self.objects:count()/self.qt_capacity), 0, 255})
	else
		utils.draw_debug_sq(self.bounds:as_primitive(), {128, 128, 128, 255})
	end
	if i == nil then
		i = 1
	end
	utils.draw_string(self.bounds.X.."::"..self.bounds.Y, self.bounds.X, self.bounds.Y, 20/i, {255, 255, 252, 255})

	-- Return if done.
	if self.north_west == nil then
		return
	end


	self.north_west:visualize(i+1)
	self.north_east:visualize(i+1)
	self.south_east:visualize(i+1)
	self.south_west:visualize(i+1)
end
