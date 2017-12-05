List = class(function(t)
	t.i_list = {}
end)

function List:add(element)
	table.insert(self.i_list, element)
end

function List:add_range(element)
	for _, v in pairs(element:get_iterator()) do
		table.insert(self.i_list, v)
	end
end

function List:remove(element)
	for i, e in pairs(self.i_list) do
		if e == element then
			table.remove(self.i_list, i)
			return
		end
	end
end

function List:get_index(i)
	return self.i_list[i]
end

function List:__tostring()
	local i = self:get_iterator()[1]:__tostring()
	for id, v in pairs(self:get_iterator()) do
		if id > 1 then
			i = i..", "..v:__tostring()
		end
	end
	return i
end

function List:contains(element)
	for _, e in pairs(self.i_list) do
		local t = e:__tostring()
		if t == element then
			return true
		end
	end
	return false
end

function List:count()
	return #self.i_list
end

function List:get_iterator()
	return self.i_list
end
