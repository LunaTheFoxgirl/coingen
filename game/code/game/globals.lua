content = require('content')
require('list')


--[[
	GAME FUNCIONALITY (This does not allow cheating, this just handles stuff like cameras, etc.
]]--
world_scale = 4
game_zoom_level = 1
game_debug_view = false




--[[
	PLAYER SETTINGS
	If you change this, you suck at the game.
	Cheater.
]]--

-- The coins the player has (default 0)
game_coins = 0

-- The amount of lives the player has (default 3)
game_player_lives = 3

-- The amount of lives the player has (default 3)
game_player_life_containers = 3

-- The time between auto-throws (default 16)
game_throw_timeout = 16

-- Invincibility frames.
game_iframe_time = 200
game_wave_timeout = 500

--Player items
game_player_bounce_shot = false
game_player_perice_shot = false
game_player_bombs = 0
game_player_AAAAA = false


--Gameplay stuff (start wave)
game_current_wave = 0
game_shd_iter = 0


c_types = List()
c_types:add({
	name="RAIDER",
	spawn_coins=0,
	--waves={1, 2, 3, 6, 7},
	health=2,
	sprite="raider-sheet",
	settings={

	},
})

c_types:add({
	name="SERIAL_KILLER",
	spawn_coins=25,
	--waves={1, 3, 5, 6, 7},
	health=2,
	sprite="sk-sheet",
	settings={

	},
})

--[[
c_types:add({
	name="BEAR",
	spawn_coins=30,
	waves={2, 3, 4, 5, 6, 7},
	health=5,
	sprite="bear-sheet",
	settings={

	},
})

c_types:add({
	name="SKELETON",
	spawn_coins=45,
	waves={4, 5, 6, 7},
	health=1,
	sprite="skeleton-sheet",
	settings={

	},
})
c_types:add({
	name="MAN_EATER",
	spawn_coins=100,
	waves={7},
	health=3,
	sprite="skeleton-sheet",
	settings={

	},
})

c_types:add({
	name="BOSS_TEMPLATE",
	spawn_coins=0,
	waves={8},
	health=2,
	sprite="boss-sheet",
	settings={

	},
})]]--

local c_constraints = {
	[0]=1,
	[1]=2,
	[2]=2,
	[3]=40,
	[4]=35,
	[5]=40,
	[6]=35,
	[7]=33,
	[8]=1,
}

local fade_trans = 255
local fade_done_func = nil
local fade_do_fade_out = true
local fade_speed = 1

function reset_fade()
	fade_trans = 255
	fade_done_func = nil
	fade_do_fade_out = true
	fade_speed = 1
end

function set_fade_speed(spd)
	fade_speed = spd
end

function fade_out(on_done)
	if fade_done_func == nil then
		fade_trans = 255
		fade_done_func = on_done
		fade_do_fade_out = true
	end
end

function fade_in(on_done)
	if fade_done_func == nil then
		fade_trans = 0
		fade_done_func = on_done
		fade_do_fade_out = false
	end
end

function update_transition()
	if fade_done_func ~= nil then
		if fade_do_fade_out then
			if fade_trans >= 0 then
				fade_trans = fade_trans - fade_speed
			end
			if fade_trans <= 0 then
				fade_trans = 0
				fade_done_func()
				fade_done_func = nil
				fade_speed = 1
			end
		else
			if fade_trans <= 255 then
				fade_trans = fade_trans + fade_speed
			end
			if fade_trans >= 255 then
				fade_trans = 255
				fade_done_func()
				fade_done_func = nil
				fade_speed = 1
			end
		end
	end
end

function fade_transition()
	return fade_trans
end



local wave = 0
local kills = 0
local total_kills = 0
local wave_started = false
local consec_waves = -1
local alive_enemies = 0
local extra_spawns = 0
local wave_timeout = 0
local has_timed_out = true

function reset_waves()
wave = 0
kills = 0
total_kills = 0
wave_started = false
consec_waves = -1
alive_enemies = 0
extra_spawns = 0
wave_timeout = 0
has_timed_out = true
end

function next_wave()
	wave_started = false
	consec_waves = consec_waves + 1
	wave = wave + 1
	extra_spawns = math.random(0, 5)
end

function add_enemy_spawn()
	if get_wave_started() then
		alive_enemies = alive_enemies + 1
	end
end

function start_wave()
	wave_started = true
end

function get_wave()
	return wave
end

function get_wave_started()
	return (is_time_for_wave()) and wave_started
end

function get_kills()
	return kills
end

function get_total_kills()
	return total_kills
end

function get_extra_spawns()
	return extra_spawns
end

function get_wave_timeout()
	return wave_timeout
end

function get_is_midway_timeout()
	return consec_waves ~= 2
end

function is_time_for_wave()
	if wave_timeout <= 0 then
		return true
	end
	return false
end

function update_wave_handler()
	if not has_timed_out then
		has_timed_out = true
		wave_timeout = game_wave_timeout
	end
	if wave_timeout > 0 then
		kills = 0
		wave_timeout = wave_timeout - 1
		return
	end
	if kills >= c_constraints[get_wave()] then
		next_wave()
		--if consec_waves ~= 2 then
		start_wave()
		--else
		--	consec_waves = 0
		--end
		has_timed_out = false
	end
end

function add_kill()
	if get_wave_started() then
		alive_enemies = alive_enemies - 1
		kills = kills + 1
	end
	total_kills = total_kills + 1
end

function get_total_enemies()
	return alive_enemies + kills
end

function get_kills_needed()
	return c_constraints[get_wave()]
end

function get_suitable_enemy_type()
	local s = List()
	for _, k in pairs(c_types:get_iterator()) do
		local n = k["spawn_coins"]

		if n <= game_coins then
			s:add(k["name"])
		end
	end
	return s:get_index(math.random(1, s:count()))
end

--[[
			GAME SPRITES (if you change this the game will most likely crash on launch.)
]]--
game_sprites = {}
function cache_sprites()
	game_sprites["coin1"] = content.load_sprite("coin1")
	game_sprites["coin2"] = content.load_sprite("coin2")
	game_sprites["player"] = content.load_sprite("player-sheet")
	game_sprites["enemy1_1"] = content.load_sprite("raider-sheet")
	game_sprites["enemy2_1"] = content.load_sprite("serialkiller-sheet")

	-- It's the shadow of you(r past)
	game_sprites["shadow"] = content.load_sprite("shadow")
	game_sprites["spook"] = content.load_sprite("gradient")
end


--[[
			GAME SHADERS
]]--
game_shaders = {}

function cache_shaders()
	game_shaders["hurt"] = content.load_shader("hurt")
	game_shaders["i_frames"] = content.load_shader("i_frames")
end

--[[
			GAME AUDIO
]]--
game_audio = {}

function cache_sounds()
	game_audio["coin"] = content.load_sound(content.type_sound, "coin.wav")
	game_audio["death"] = content.load_sound(content.type_sound, "death.wav")
	game_audio["hurt"] = content.load_sound(content.type_sound, "hurt.wav")
	game_audio["shopmus"] = content.load_sound(content.type_music, "shop_mus.ogg")
end
