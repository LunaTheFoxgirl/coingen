require('math_p')
core = require('core')
input = require('input')
translator = require('translathor')
content = require('content')
utils = require('utils')

-- Constructor
GameObject = class(QuadtreeItem, function(t, qt_parent, world_parent)
	QuadtreeItem.init(t, qt_parent)
	t.parent = world_parent
	t.alive = true
	t.d_order = dorder
end)

-- Get drawing order
function GameObject:get_order() return self.d_order end

function GameObject:set_owner(o)
	self.quad_owner = o
end

-- Destroy
function GameObject:destroy() t.alive = false end

-- Draw
function GameObject:draw()	end

-- Update
function GameObject:update()	end

-- Init
function GameObject:init()	end
