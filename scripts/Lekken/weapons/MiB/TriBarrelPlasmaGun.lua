--------------------------------------------------------------------------------
-- MiB Weapons: Tri Barrel Plasma Gun
-- Script by Lekken
--------------------------------------------------------------------------------

-- Setup Tables
if (lph == nil) then lph = {} end
lph.tribarrelgun = {}
lph.tribarrelgun.bullet = {}

-- Resources
lph.tribarrelgun.gfx_wpn = loadgfx("Lekken/weapons/MiB/TriBarrelPlasmaGun.png")
setmidhandle(lph.tribarrelgun.gfx_wpn)
lph.tribarrelgun.gfx_prj = loadgfx("Lekken/weapons/MiB/sphere.png")
setmidhandle(lph.tribarrelgun.gfx_prj)
lph.tribarrelgun.sfx_attack = loadsfx("Lekken/weapons/MiB/TriBarrelPlasmaGun.wav")

--------------------------------------------------------------------------------
-- Tri Barrel Plasma Gun
--------------------------------------------------------------------------------
lph.tribarrelgun.id = addweapon("lph.tribarrelgun", "Tri Barrel Plasma Gun", lph.tribarrelgun.gfx_wpn, 1, 4)
addweaponinfo("Tri Barrel Plasma Gun from MiB franchise. Powerful and destructive, this weapon only to use in extreme cautions.")
lph.tribarrelgun.ammo = 1
lph.tribarrelgun.timer_delay_max = 30
lph.tribarrelgun.timer_delay = lph.tribarrelgun.timer_delay_max
lph.tribarrelgun.flag_delay = true

function lph.tribarrelgun.draw()
	setblend(blend_alpha)
	setalpha(1)
	setcolor(255, 255, 255)
	drawinhand(lph.tribarrelgun.gfx_wpn, 8, 0)

	-- Crosshair
	if (lph.tribarrelgun.ammo - weapon_shots > 0) then
		hudcrosshair(7, 3)
	end
end

function lph.tribarrelgun.attack(attack)
	-- Attack
	if (weapon_shots < lph.tribarrelgun.ammo and attack == 1) then
		playsound(lph.tribarrelgun.sfx_attack, -1, 0.4)
		lph.tribarrelgun.flag_delay = false
	end
	if (lph.tribarrelgun.flag_delay == false) then
		lph.tribarrelgun.timer_delay = lph.tribarrelgun.timer_delay - 1
	end
	if (lph.tribarrelgun.timer_delay <= 0) then
		useweapon(0)
		lph.tribarrelgun.timer_delay = lph.tribarrelgun.timer_delay_max
		lph.tribarrelgun.flag_delay = true
		weapon_shots = weapon_shots + 1
		lph.tribarrelgun.init_prj()
		-- Effects
		recoil(5)
		particle(p_muzzle,getplayerx(0)+(getplayerdirection(0)*7)+math.sin(math.rad(getplayerrotation(0)))*12,getplayery(0)+3-math.cos(math.rad(getplayerrotation(0)))*12)
		particlecolor(0,0,255)
		particlefadealpha(0.01)
		particle(p_smoke,getplayerx(0)+(getplayerdirection(0)*7)+math.sin(math.rad(getplayerrotation(0)))*12,getplayery(0)+3-math.cos(math.rad(getplayerrotation(0)))*12)
		particlespeed(-0.2+math.random()*0.4+getwind()*10.0,-1.0+math.random()*0.6)
		particlefadealpha(0.005)
		endturn()
	end
end


--------------------------------------------------------------------------------
-- Projectile
--------------------------------------------------------------------------------
lph.tribarrelgun.bullet.id=addprojectile("lph.tribarrelgun.bullet")

function lph.tribarrelgun.init_prj()
	id = createprojectile(lph.tribarrelgun.bullet.id)
	projectiles[id] = {}

	projectiles[id].ignore = playercurrent()
	projectiles[id].damage = 150
	projectiles[id].areal = 100
	-- Position
	projectiles[id].x = getplayerx(0)+(7*getplayerdirection(0))-math.sin(math.rad(getplayerrotation(0)))*5.0
	projectiles[id].y = getplayery(0)+math.cos(math.rad(getplayerrotation(0)))*5.0
	-- Speed
	projectiles[id].sx = math.sin(math.rad(getplayerrotation(0)))*15.0
	projectiles[id].sy = -math.cos(math.rad(getplayerrotation(0)))*15.0
	-- Movement
	projectiles[id].x = projectiles[id].x-projectiles[id].sx*0.5
	projectiles[id].y = projectiles[id].y-projectiles[id].sy*0.5
	projectiles[id].lifetime = 300
end

function lph.tribarrelgun.bullet.draw(id)
	-- Setup draw mode
	setblend(blend_light)
	setalpha(1)
	setcolor(255, 255, 255)
	setscale(1, 1)
	setrotation(math.deg(math.atan2(projectiles[id].sx,-projectiles[id].sy)))
	drawimage(lph.tribarrelgun.gfx_prj,projectiles[id].x,projectiles[id].y)
	outofscreenarrow(projectiles[id].x,projectiles[id].y)
end

function lph.tribarrelgun.bullet.update(id)
	projectiles[id].lifetime = projectiles[id].lifetime - 1
	if (projectiles[id].lifetime <= 0) then	freeprojectile(id) end
	-- Move
	lph.tribarrelgun.bullet.move(id)
end

function lph.tribarrelgun.bullet.move(id)
	rot=math.deg(math.atan2(projectiles[id].sx,-projectiles[id].sy))
	-- Move (in substep loop for optimal collision precision)
	msubt=math.ceil(math.max(math.abs(projectiles[id].sx),math.abs(projectiles[id].sy))/3)
	msubx=projectiles[id].sx/msubt
	msuby=projectiles[id].sy/msubt
	for i=1,msubt,1 do
		projectiles[id].x=projectiles[id].x+msubx
		projectiles[id].y=projectiles[id].y+msuby		
		-- Collision
		if collision(col3x3,projectiles[id].x+math.sin(math.rad(rot))*20,projectiles[id].y-math.cos(math.rad(rot))*20)==1 then
			if terraincollision()==1
				or objectcollision()>0 
				or playercollision()~=projectiles[id].ignore
			then
				-- Cause damage
				arealdamage(projectiles[id].x, projectiles[id].y, projectiles[id].areal, projectiles[id].damage)
				-- Destroy terrain
				terrainexplosion(projectiles[id].x, projectiles[id].y, 75, 1)
				-- Crater
				grey = math.random(0, 40)
				if (math.random(0, 1) == 1) then
					terrainalphaimage(gfx_crater100, projectiles[id].x, projectiles[id].y, 
										math.random(6,9)*0.1, grey, grey, grey)
				else
					terrainalphaimage(gfx_crater125, projectiles[id].x, projectiles[id].y, 
										math.random(6,9)*0.1, grey, grey, grey)
				end
				-- Effects
				particle(p_muzzle,projectiles[id].x+math.sin(math.rad(rot))*21,projectiles[id].y-math.cos(math.rad(rot))*21)
				particlecolor(0,0,255)
				for i=1,3 do
					particle(p_spark,projectiles[id].x+math.sin(math.rad(rot))*21,projectiles[id].y-math.cos(math.rad(rot))*21)
					particlecolor(0,0,255)
				end
				-- Free projectile
				freeprojectile(id)
				return 1
			end
		else
			projectiles[id].ignore=0
		end
		-- Water
		if (projectiles[id].y)>getwatery()+5 then
			-- Effects
			particle(p_waterhit,projectiles[id].x,projectiles[id].y)
			if math.random(1,2)==1 then
				playsound(sfx_hitwater2)
			else
				playsound(sfx_hitwater3)
			end
			-- Free projectile
			freeprojectile(id)
			return 1
		end
	end
	-- Scroll to projectile
	scroll(projectiles[id].x,projectiles[id].y)
end