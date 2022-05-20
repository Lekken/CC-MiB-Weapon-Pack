--------------------------------------------------------------------------------
-- MiB Weapons: De-Atomizer
-- Script by Lekken
--------------------------------------------------------------------------------

-- Setup Tables
if (lph == nil) then lph = {} end
lph.deatomizer = {}
lph.deatomizer.bullet = {}

-- Resources
lph.deatomizer.gfx_wpn = loadgfx("Lekken/weapons/MiB/De-Atomizer.png")
setmidhandle(lph.deatomizer.gfx_wpn)
lph.deatomizer.gfx_prj = loadgfx("weapons/lasershot.png")
setmidhandle(lph.deatomizer.gfx_prj)
lph.deatomizer.sfx_attack = loadsfx("Lekken/weapons/MiB/De-Atomizer.wav")

--------------------------------------------------------------------------------
-- De-Atomizer
--------------------------------------------------------------------------------
lph.deatomizer.id = addweapon("lph.deatomizer", "De-Atomizer", lph.deatomizer.gfx_wpn, 1, 1)
addweaponinfo("De-Atomizer from MiB franchise. Every agent's standart sidearm.")
lph.deatomizer.ammo = 5

function lph.deatomizer.draw()
    setblend(blend_alpha)
    setalpha(1)
    setcolor(255, 255, 255)
    drawinhand(lph.deatomizer.gfx_wpn, 8, 0)
    
    -- HUD ammobar
    if (lph.deatomizer.ammo - weapon_shots > 0) then
        hudammobar(lph.deatomizer.ammo - weapon_shots, lph.deatomizer.ammo)
    end
    
    -- Crosshair
    if (lph.deatomizer.ammo - weapon_shots > 0) then
        hudcrosshair(7, 3)
    end
end

function lph.deatomizer.attack(attack)
    if (weapon_timer > 0) then
        weapon_timer = weapon_timer - 1
    end
    -- Attack
    if (weapon_shots < lph.deatomizer.ammo and weapon_timer <= 0 and attack == 1) then
        useweapon(0)
        weapon_timer = 10
        playsound(lph.deatomizer.sfx_attack)
        weapon_shots = weapon_shots + 1
        lph.deatomizer.init_prj()
        
        recoil(3)
        particle(p_muzzle,getplayerx(0)+(getplayerdirection(0)*7)+math.sin(math.rad(getplayerrotation(0)))*12,getplayery(0)+3-math.cos(math.rad(getplayerrotation(0)))*12)
        particlecolor(0,255,0)

        if (weapon_shots >= lph.deatomizer.ammo) then
            endturn()
        end
    end
end


--------------------------------------------------------------------------------
-- Projectile
--------------------------------------------------------------------------------
lph.deatomizer.bullet.id=addprojectile("lph.deatomizer.bullet")

function lph.deatomizer.init_prj()
    id = createprojectile(lph.deatomizer.bullet.id)
    projectiles[id] = {}

    projectiles[id].ignore = playercurrent()
    projectiles[id].damage = 6
    -- Position
    projectiles[id].x = getplayerx(0)+(7*getplayerdirection(0))-math.sin(math.rad(getplayerrotation(0)))*5.0
    projectiles[id].y = getplayery(0)+math.cos(math.rad(getplayerrotation(0)))*5.0
    -- Speed
    projectiles[id].sx = math.sin(math.rad(getplayerrotation(0))) * 25.0
    projectiles[id].sy = -math.cos(math.rad(getplayerrotation(0))) * 25.0
    -- Movement
    projectiles[id].x = projectiles[id].x - projectiles[id].sx * 0.5
    projectiles[id].y = projectiles[id].y - projectiles[id].sy * 0.5
    projectiles[id].lifetime = 300
end

function lph.deatomizer.bullet.draw(id)
    -- Setup draw mode
    setblend(blend_light)
    setalpha(1)
    setcolor(0, 255, 0)
    setscale(0.3, 0.3)
    setrotation(math.deg(math.atan2(projectiles[id].sx,-projectiles[id].sy)))
    drawimage(lph.deatomizer.gfx_prj,projectiles[id].x,projectiles[id].y)
    outofscreenarrow(projectiles[id].x,projectiles[id].y)
end

function lph.deatomizer.bullet.update(id)
    projectiles[id].lifetime = projectiles[id].lifetime - 1
    if (projectiles[id].lifetime <= 0) then    freeprojectile(id) end
    -- Move
    lph.deatomizer.bullet.move(id)
end

function lph.deatomizer.bullet.move(id)
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
            if terraincollision()==1 or objectcollision()>0 or playercollision()~=projectiles[id].ignore then
                -- Cause damage
                if playercollision()~=0 and playercollision()~=projectiles[id].ignore then
                    playerpush(playercollision(),projectiles[id].sx/10.0,projectiles[id].sy/10.0)
                    playerdamage(playercollision(),projectiles[id].damage)
                    blood(projectiles[id].x+math.sin(math.rad(rot))*20,projectiles[id].y-math.cos(math.rad(rot))*20)
                elseif objectcollision()>0 then
                    objectdamage(objectcollision(),projectiles[id].damage)
                end
                -- Destroy terrain
                for j=20,22,1 do
                    terraincircle(projectiles[id].x+math.sin(math.rad(rot))*j,projectiles[id].y-math.cos(math.rad(rot))*j,3,0x00000000)
                end
                -- Effects
                particle(p_muzzle,projectiles[id].x+math.sin(math.rad(rot))*21,projectiles[id].y-math.cos(math.rad(rot))*21)
                particlecolor(0,255,0)
                for i=1,3 do
                    particle(p_spark,projectiles[id].x+math.sin(math.rad(rot))*21,projectiles[id].y-math.cos(math.rad(rot))*21)
                    particlecolor(0,255,0)
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
end