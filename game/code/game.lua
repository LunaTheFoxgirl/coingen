require('game.mainworld')
require('game.shopworld')
require('game.game_objects.player')
require('game.game_objects.coin')
require('game.globals')

core = require('core')
input = require('input')
translator = require('translathor')
content = require('content')
utils = require('utils')


function game_cleanup()

end

function game_init()
	cache_sprites()
	cache_shaders()
	cache_sounds()
	game_world = MainWorld()
	game_world:init()
	game_window:show_cursor(false)
end

function game_update()
	update_transition()
	game_world:update()
end

function game_draw()
	utils.clear_color({0,0,0,255})
	game_world:draw()
	utils.draw_fps({8,8})
end

function set_game_world(w)
	w:init()
	game_world = w
end

function main()
	-- Create window
	utils.set_raylib_logging(0)
	game_window = Window("Coingen", 1024, 674)
	game_window:target_fps(60)
	game_window:set_resizable(true)
	game_window:start_game()
end

function restart_game()
	reset_waves()
	reset_fade()
	game_world = MainWorld()
	game_world:init()
end
