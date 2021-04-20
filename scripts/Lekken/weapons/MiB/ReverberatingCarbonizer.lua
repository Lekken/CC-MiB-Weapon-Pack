--------------------------------------------------------------------------------
-- MiB Weapons: Reverberating Carbonizer
-- Script by Lekken
--------------------------------------------------------------------------------

-- Setup Tables
if (lph == nil) then lph = {} end
lph.carbonizer = {}
lph.carbonizer.wave = {}

-- Resources
lph.carbonizer.gfx_wpn = loadgfx("Lekken/weapons/MiB/ReverberatingCarbonizer.png")
setmidhandle(lph.carbonizer.gfx_wpn)
lph.carbonizer.gfx_wave = loadgfx("Lekken/weapons/MiB/wave.png")
setmidhandle(lph.carbonizer.gfx_wave)
lph.carbonizer.sfx_attack = loadsfx("Lekken/weapons/MiB/ReverberatingCarbonizer.wav")

--------------------------------------------------------------------------------
-- Carbonizer
--------------------------------------------------------------------------------
lph.carbonizer.id = addweapon("lph.carbonizer", "Reverberating Carbonizer", lph.carbonizer.gfx_wpn, 0, 1)
addweaponinfo("Reverberating Carbonizer from MiB franchise. Affects the target's mind.")
lph.carbonizer.ammo = 1
lph.carbonizer.creating_wave = false
lph.carbonizer.cout_wave = 0
lph.carbonizer.max_wave = 7
local increment = 0

function lph.carbonizer.draw()
	setblend(blend_alpha)
	setalpha(1)
	setcolor(255, 255, 255)
	drawinhand(lph.carbonizer.gfx_wpn, 10, 0)
	
	-- Crosshair
	if (lph.carbonizer.ammo - weapon_shots > 0) then
		hudcrosshair(7, 3)
	end
end

function lph.carbonizer.attack(attack)
		if (lph.carbonizer.creating_wave == true) then
			increment = increment + 1
			if (increment % 12 == 0) then
				playsound(lph.carbonizer.sfx_attack)
				lph.carbonizer.init_wave()
			end
			if (lph.carbonizer.cout_wave >= lph.carbonizer.max_wave) then
				lph.carbonizer.creating_wave = false
				increment = 0
				lph.carbonizer.cout_wave = 0
				playercontrol(1)
				endturn()
			end
		end

	-- Attack
	if (weapon_shots < lph.carbonizer.ammo and attack == 1) then
		useweapon(0)
		playercontrol(0)
		weapon_shots = weapon_shots + 1
		lph.carbonizer.creating_wave = true
	end
end



--------------------------------------------------------------------------------
-- Projectile
--------------------------------------------------------------------------------
lph.carbonizer.wave.id = addprojectile("lph.carbonizer.wave")

function lph.carbonizer.init_wave()
	lph.carbonizer.cout_wave = lph.carbonizer.cout_wave + 1

	id = createprojectile(lph.carbonizer.wave.id)
	projectiles[id] = {}
	-- Ignore collision with current player at beginning
	projectiles[id].ignore = playercurrent()
	-- Position
	projectiles[id].x = getplayerx(0)+(15*getplayerdirection(0))-math.sin(math.rad(getplayerrotation(0)))
	projectiles[id].y = getplayery(0)+math.cos(math.rad(getplayerrotation(0)))*(-5.0)
	-- Speed
	projectiles[id].sx = math.sin(math.rad(getplayerrotation(0)))*1.0
	projectiles[id].sy = -math.cos(math.rad(getplayerrotation(0)))*1.0
	-- Movement
	projectiles[id].x = projectiles[id].x-projectiles[id].sx*0.5
	projectiles[id].y = projectiles[id].y-projectiles[id].sy*0.5
	projectiles[id].lifetime = 100
	
	projectiles[id].scale = 0.1
end

function lph.carbonizer.wave.draw(id)
	-- Setup draw mode
	setblend(blend_light)
	setalpha(1)
	setcolor(255, 255, 255)
	setscale(projectiles[id].scale, projectiles[id].scale)
	--if (projectiles[id].scale < 1.0) then
		projectiles[id].scale = projectiles[id].scale + 0.01
	--end
	setrotation(math.deg(math.atan2(projectiles[id].sx, -projectiles[id].sy)))
	drawimage(lph.carbonizer.gfx_wave,projectiles[id].x, projectiles[id].y)
end

function lph.carbonizer.wave.update(id)
	projectiles[id].lifetime = projectiles[id].lifetime - 1
	if (projectiles[id].lifetime <= 0) then	freeprojectile(id) end
	-- Move
	lph.carbonizer.wave.move(id)
end

function lph.carbonizer.wave.move(id)
	rot = math.deg(math.atan2(projectiles[id].sx, -projectiles[id].sy))
	-- Move (in substep loop for optimal collision precision)
	msubt = math.ceil(math.max(math.abs(projectiles[id].sx), math.abs(projectiles[id].sy)) / 3)
	msubx = projectiles[id].sx / msubt
	msuby = projectiles[id].sy / msubt
	for i = 1, msubt, 1 do
		projectiles[id].x = projectiles[id].x + msubx
		projectiles[id].y = projectiles[id].y + msuby		
		-- Collision
		if (collision(colplayer, projectiles[id].x+math.sin(math.rad(rot))*20, 
								projectiles[id].y-math.cos(math.rad(rot))*20) 
			== 1)
		then
			if (playercollision() ~= projectiles[id].ignore) then
				if (getplayeralliance(playercollision()) ~= getplayeralliance(projectiles[id].ignore)) then
					playerstate(playercollision(), state_confused, 1)
				end
			end
		else
			projectiles[id].ignore=0
		end
	end
end