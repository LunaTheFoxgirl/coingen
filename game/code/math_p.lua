-- Rectangle
Rectangle = class(function(t, x, y, w, h)
	t.X = x
	t.Y = y
	t.Width = w
	t.Height = h
end)

function Rectangle:intersects(rect)
	if rect.is_a == nil then
		print("WARNING: NIL RECT")
		return {0, 0, 0, 0}
	end
	if rect:is_a(Rectangle) then
		local v = (rect:left() > self:right() or
			rect:right() < self:left() or
			rect:top() > self:bottom() or
			rect:bottom() < self:top())
		return not v
	end
	if rect:is_a(Vector2) then
		local v = (rect.X > self:right() or
			rect.X < self:left() or
			rect.Y > self:bottom() or
			rect.Y < self:top())
		return not v
	end
end

function Rectangle:__tostring()
	return "["..self.X..", "..self.Y..", "..self.Width..", "..self.Height.."]"
end

-- Operator +
function Rectangle:__add(lhs, rhs)
	return Rectangle(lhs.X + rhs.X, lhs.Y + rhs.Y, lhs.Width, lhs.Height)
end

function Rectangle:__sub(lhs, rhs)
	return Rectangle(lhs.X - rhs.X, lhs.Y - rhs.Y, lhs.Width, lhs.Height)
end

function Rectangle:left()
	return self.X
end

function Rectangle:right()
	return self.X + self.Width
end

function Rectangle:top()
	return self.Y
end

function Rectangle:bottom()
	return self.Y + self.Height
end

function Rectangle:center()
	return Vector2(self.X + (self.Width/2), self.Y + (self.Height/2))
end

function Rectangle:as_primitive()
	return {self.X, self.Y, self.Width, self.Height}
end
















-- Vector2
Vector2 = class(function(t, x, y)
	t.X = x
	t.Y = y
end)

function Vector2:intersects_rect(rect)
	if rect.is_a == nil then
		return {0, 0, 0, 0}
	end
	if rect:is_a(Rectangle) then
		return not (rect.left() > self.X	and
			 rect.right() < self.X		and
			 rect.top() > self.Y		and
			 rect.bottom() < self.Y)
	end
end

-- Operator +
function Vector2:__add(other)
	return Vector2(self.X + other.X, self.Y + other.Y)
end

function Vector2:__sub(other)
	return Vector2(self.X - other.X, self.Y - other.Y)
end

function Vector2:normalize()
	local norm = 1 / (math.sqrt((self.X * self.X) + (self.Y * self.Y)))
	return Vector2(self.X * norm, self.Y*norm)
end

function Vector2:as_primitive()
	return {self.X, self.Y}
end
