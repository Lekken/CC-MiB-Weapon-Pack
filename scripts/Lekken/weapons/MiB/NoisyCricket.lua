--------------------------------------------------------------------------------
-- MiB Weapons: Noisy Cricket
-- Script by Lekken
--------------------------------------------------------------------------------

-- Setup Tables
if (lph == nil) then lph = {} end
lph.cricket = {}
lph.cricket.prj = {}

-- Resources
lph.cricket.gfx_wpn = loadgfx("Lekken/weapons/MiB/NoisyCricket.png")
setmidhandle(lph.cricket.gfx_wpn)
lph.cricket.sfx_attack = loadsfx("Lekken/weapons/MiB/NoisyCricket.wav")

--------------------------------------------------------------------------------
-- Noisy Cricket
--------------------------------------------------------------------------------
lph.cricket.id = addweapon("lph.cricket", "Noisy Cricket", lph.cricket.gfx_wpn, 1, 3)
addweaponinfo("Noisy Cricket from MiB franchise. Small, yet powerful. This weapon deals areal damage. WARNING: extremely high recoil!")
lph.cricket.ammo = 1
lph.cricket.timer_delay_max = 50/4
lph.cricket.timer_delay = lph.cricket.timer_delay_max
lph.cricket.flag_delay = true

function lph.cricket.draw()
	setblend(blend_alpha)
	setalpha(1)
	setcolor(255, 255, 255)
	drawinhand(lph.cricket.gfx_wpn, 7, 0)

	-- Crosshair
	if (lph.cricket.ammo - weapon_shots > 0) then
		hudcrosshair(7, 3)
	end
end

function lph.cricket.attack(attack)
	-- Attack
	if (weapon_shots < lph.cricket.ammo and attack == 1) then
		playsound(lph.cricket.sfx_attack, -1, 0.3)
		lph.cricket.flag_delay = false
	end
	if (lph.cricket.flag_delay == false) then
		lph.cricket.timer_delay = lph.cricket.timer_delay - 1
	end
	if (lph.cricket.timer_delay <= 0) then
		useweapon(0)
		lph.cricket.timer_delay = lph.cricket.timer_delay_max
		lph.cricket.flag_delay = true
		weapon_shots = weapon_shots + 1
		lph.cricket.init_prj()
		playerpush(0, -projectiles[id].sx / 10.0, -(projectiles[id].recoil + projectiles[id].sy) / 10.0)
		endturn()
	end
end


--------------------------------------------------------------------------------
-- Projectile (invisible)
--------------------------------------------------------------------------------
lph.cricket.prj.id = addprojectile("lph.cricket.prj")

function lph.cricket.init_prj()
	id = createprojectile(lph.cricket.prj.id)
	projectiles[id] = {}

	projectiles[id].ignore = playercurrent()
	projectiles[id].damage = 70
	projectiles[id].areal = 75
	projectiles[id].recoil = 75
	-- Position
	projectiles[id].x = getplayerx(0) + (7 * getplayerdirection(0)) - math.sin(math.rad(getplayerrotation(0))) * 5.0
	projectiles[id].y = getplayery(0) + 3 + math.cos(math.rad(getplayerrotation(0))) * 5.0
	-- Speed
	projectiles[id].sx = math.sin(math.rad(getplayerrotation(0))) * 50.0
	projectiles[id].sy = -math.cos(math.rad(getplayerrotation(0))) * 50.0
	-- Movement
	projectiles[id].x = projectiles[id].x - projectiles[id].sx * 0.5
	projectiles[id].y = projectiles[id].y - projectiles[id].sy * 0.5
	projectiles[id].lifetime = 250
end

function lph.cricket.prj.draw(id)

end

function lph.cricket.prj.update(id)
	projectiles[id].lifetime = projectiles[id].lifetime - 1
	if (projectiles[id].lifetime <= 0) then	freeprojectile(id) end
	
	lph.cricket.prj.move(id)
end

function lph.cricket.prj.move(id)
	rot = math.deg(math.atan2(projectiles[id].sx, -projectiles[id].sy))
	msubt = math.ceil(math.max(math.abs(projectiles[id].sx), math.abs(projectiles[id].sy)) / 3)
	msubx = projectiles[id].sx / msubt
	msuby = projectiles[id].sy / msubt
	for i = 1, msubt, 1 do
		projectiles[id].x = projectiles[id].x + msubx
		projectiles[id].y = projectiles[id].y + msuby
		-- Collision
		if (collision(col1x1, projectiles[id].x + math.sin(math.rad(rot)) * 20, 
						projectiles[id].y - math.cos(math.rad(rot)) * 20) == 1)
		then
			if (terraincollision() == 1 
				or objectcollision() > 0 
				or playercollision() ~= projectiles[id].ignore)
			then
				-- Cause damage
				arealdamage(projectiles[id].x, projectiles[id].y, projectiles[id].areal, projectiles[id].damage)
				-- Destroy terrain
				terrainexplosion(projectiles[id].x, projectiles[id].y, 50, 1)
				-- Crater
				grey = math.random(0, 40)
				if (math.random(0, 1) == 1) then
					terrainalphaimage(gfx_crater100, projectiles[id].x, projectiles[id].y, 
										math.random(6,9)*0.1, grey, grey, grey)
				else
					terrainalphaimage(gfx_crater125, projectiles[id].x, projectiles[id].y, 
										math.random(6,9)*0.1, grey, grey, grey)
				end
				-- Free projectile
				freeprojectile(id)
				return 1
			end
		else
			projectiles[id].ignore=0
		end
		-- Water
		if (projectiles[id].y > (getwatery() + 5)) then
			freeprojectile(id)
			return 1
		end
	end
end