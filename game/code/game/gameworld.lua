require('list')
require('game.gameobject')
require('game.game_objects.level')
require('other')
require('content')
require('game.globals')
require('quadtree')
utils = require('utils')
core = require('core')

GameWorld = class(function(t)
end)

-- Draw
function GameObject:draw()	end

-- Update
function GameObject:update()	end

-- Init
function GameObject:init()	end
