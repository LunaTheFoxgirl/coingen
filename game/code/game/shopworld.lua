require('game.game_objects.shop_level')
require('game.globals')

Shopworld = class(GameWorld, function(t, pl)
	GameWorld.init(t)
	t.player = pl
end)

-- Draw
function Shopworld:draw()
	self.level:draw()
	self.player:draw()
end

-- Update
function Shopworld:update()
	self.level:update()
	self.player:update()
	print(fade_transition())
end

-- Init
function Shopworld:init()
	print("---- ENTERING SHOP ----")
	print("Initializing level...")
	--game_audio["shopmus"]:volume(1)
	--game_audio["shopmus"]:play()

	self.level = ShopLevel(self.obj_list, self)
	self.level:init()
	set_fade_speed(22)
	fade_out(function()
		print("Level faded in!")
	end)
	print("Initialized level...")
end
