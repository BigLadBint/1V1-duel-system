local inDuel = false
local duelWeapon = Config.Weapon
local arenaIndex = 1
local duelData = {}

RegisterCommand('1v1', function(_, args)
    local id = tonumber(args[1])
    if id then TriggerServerEvent('duel:invite', id) end
end)

RegisterNetEvent('duel:showInvite', function(from)
    SetNuiFocus(true, true)
    SendNUIMessage({action = 'invite', from = from})
end)

RegisterNetEvent('duel:start', function(isSpawn1, data)
    inDuel = true
    duelData = data

    SetNuiFocus(false, false)
    SendNUIMessage({action = 'showHUD', names = data.names, score = data.score})

    startRound(isSpawn1)
end)

RegisterNetEvent('duel:updateScore', function(score)
    SendNUIMessage({action = 'updateScore', score = score})
end)

RegisterNetEvent('duel:newRound', function(isSpawn1)
    startRound(isSpawn1)
end)

RegisterNetEvent('duel:finish', function(winner)
    inDuel = false
    local ped = PlayerPedId()

    SetEntityInvincible(ped, false)
    SetPedCanBeTargetted(ped, true)
    SetPedInfiniteAmmo(ped, false)
    RemoveAllPedWeapons(ped, true)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))

    SendNUIMessage({action = 'hideHUD'})
end)

RegisterNetEvent('duel:inviteExpired', function()
    -- Add notification here if you want (e.g. chat message or NUI)
end)

RegisterNUICallback('accept', function(_, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('duel:accept')
    cb('ok')
end)

RegisterNUICallback('decline', function(_, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('duel:decline')
    cb('ok')
end)

local function getArena()
    if Config.ArenaMode == 'random' then
        arenaIndex = math.random(1, #Config.Arenas)
    else
        arenaIndex = arenaIndex + 1
        if arenaIndex > #Config.Arenas then arenaIndex = 1 end
    end
    return Config.Arenas[arenaIndex]
end

function startRound(isSpawn1)
    local ped = PlayerPedId()
    local arena = getArena()

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetPedCanBeTargetted(ped, false)

    SetEntityCoords(ped, isSpawn1 and arena.spawn1 or arena.spawn2)
    SetEntityHeading(ped, isSpawn1 and 0.0 or 180.0) -- rough facing direction
    SetEntityHealth(ped, 200)

    RemoveAllPedWeapons(ped, true)
    GiveWeaponToPed(ped, duelWeapon, 9999, false, true)
    SetCurrentPedWeapon(ped, duelWeapon, true)
    SetPedInfiniteAmmo(ped, true, duelWeapon)

    countdown(function()
        FreezeEntityPosition(ped, false)
        SetEntityInvincible(ped, false)
        SetPedCanBeTargetted(ped, true)
    end)
end

function countdown(cb)
    CreateThread(function()
        for _, t in ipairs({"3", "2", "1", "FIGHT!"}) do
            SendNUIMessage({action = 'countdown', text = t})
            Wait(1000)
        end
        SendNUIMessage({action = 'clearCountdown'})
        cb()
    end)
end

AddEventHandler('gameEventTriggered', function(name, args)
    if not inDuel or name ~= 'CEventNetworkEntityDamage' then return end

    local victim = args[1]
    local attacker = args[2]

    if attacker == PlayerPedId() and IsEntityDead(victim) and IsPedAPlayer(victim) then
        local victimId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim))
        TriggerServerEvent('duel:reportKill', victimId)
    end
end)