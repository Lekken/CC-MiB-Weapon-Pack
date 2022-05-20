--------------------------------------------------------------------------------
-- MiB Weapons: Neuralyzer
-- Script by Lekken
--------------------------------------------------------------------------------

-- Setup Tables
if (lph == nil) then lph = {} end
lph.neuralyzer = {}

-- Resources
lph.neuralyzer.gfx_wpn = loadgfx("Lekken/weapons/MiB/Neuralyzer.png")
setmidhandle(lph.neuralyzer.gfx_wpn)
lph.neuralyzer.gfx_flash = loadgfx("Lekken/weapons/MiB/flash.png")
setmidhandle(lph.neuralyzer.gfx_flash)
lph.neuralyzer.gfx_glasses = loadgfx("Lekken/weapons/MiB/glasses.png")
setmidhandle(lph.neuralyzer.gfx_glasses)
lph.neuralyzer.sfx_attack = loadsfx("Lekken/weapons/MiB/Neuralyzer.wav")

--------------------------------------------------------------------------------
-- Neuralyzer
--------------------------------------------------------------------------------
lph.neuralyzer.id = addweapon("lph.neuralyzer", "Neuralyzer", lph.neuralyzer.gfx_wpn, 1, 1)
addweaponinfo("Neuralyzer from MiB franchise. Sweep the memory clean.")
lph.neuralyzer.ammo = 1
lph.neuralyzer.activated = false
local last_scale = 0.5
local distx_max = 75
local disty_max = 75

function lph.neuralyzer.draw()
    setblend(blend_alpha)
    setalpha(1)
    setcolor(255, 255, 255)
    drawimage(lph.neuralyzer.gfx_glasses, getplayerx(0)+getplayerdirection(0)*2, getplayery(0)-5)
    drawimage(lph.neuralyzer.gfx_wpn, getplayerx(0)+getplayerdirection(0)*6, getplayery(0))
    
    if (lph.neuralyzer.activated == true) then
        setscale(last_scale, last_scale)
        last_scale = last_scale + (last_scale / 2)
        drawimage(lph.neuralyzer.gfx_flash, getplayerx(0)+getplayerdirection(0)*6, getplayery(0)-5)
    else
        last_scale = 0.5
    end
end

function lph.neuralyzer.attack(attack)
    -- Attack
    if (weapon_timer > 0) then
        weapon_timer = weapon_timer - 1
        lph.neuralyzer.activated = true
    else
        lph.neuralyzer.activated = false
    end
    if (weapon_shots < lph.neuralyzer.ammo and attack == 1) then
        useweapon(0)
        weapon_shots = weapon_shots + 1
        playsound(lph.neuralyzer.sfx_attack)
        weapon_timer = 20
        local players = playertable(0, 0)
        for i = 1, #players do
            if (getplayeralliance(players[i]) ~= getplayeralliance(playercurrent())) then
                if ((math.abs(getplayery(players[i]) - getplayery(0)) < disty_max)
                    and (math.abs(getplayerx(players[i]) - getplayerx(0)) < distx_max))
                then
                    if ((getplayerx(0) < getplayerx(players[i]) and getplayerdirection(0) == 1)
                        or (getplayerx(0) > getplayerx(players[i]) and getplayerdirection(0) == -1))
                    then
                        if (getplayerdirection(0) ~= getplayerdirection(players[i])) then
                            playerstate(players[i], state_sleeping, 1)
                        end
                    end
                end
            end
        end
        
        endturn()
    end
end