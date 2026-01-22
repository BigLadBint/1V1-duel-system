local invites = {}          -- [target] = {inviter = src, timestamp = os.time()}
local duels = {}
local bucketCounter = 3000

local function isInDuel(playerId)
    for _, duel in pairs(duels) do
        if duel.p1 == playerId or duel.p2 == playerId then
            return true
        end
    end
    return false
end

RegisterNetEvent('duel:invite', function(target)
    local src = source
    target = tonumber(target)
    if not target or not GetPlayerName(target) or target == src then return end

    if isInDuel(src) or isInDuel(target) then
        TriggerClientEvent('chat:addMessage', src, { color = {255,100,100}, args = {'[Duel]', 'You or the target are already in a duel!'} })
        return
    end

    invites[target] = {inviter = src, timestamp = os.time()}
    TriggerClientEvent('duel:showInvite', target, src)

    -- Auto expire invite after 45 seconds
    SetTimeout(45000, function()
        if invites[target] and invites[target].inviter == src then
            invites[target] = nil
            TriggerClientEvent('duel:inviteExpired', target)
        end
    end)
end)

RegisterNetEvent('duel:accept', function()
    local src = source
    local invite = invites[src]
    if not invite then return end

    local inviter = invite.inviter
    invites[src] = nil

    if isInDuel(src) or isInDuel(inviter) then
        TriggerClientEvent('chat:addMessage', src, { color = {255,100,100}, args = {'[Duel]', 'Duel could not start – someone is already fighting!'} })
        return
    end

    bucketCounter = bucketCounter + 1
    local bucket = bucketCounter

    duels[bucket] = {
        p1 = inviter,
        p2 = src,
        score = {[inviter] = 0, [src] = 0}
    }

    SetPlayerRoutingBucket(inviter, bucket)
    SetPlayerRoutingBucket(src, bucket)

    local data = {
        p1 = inviter,
        p2 = src,
        names = {[inviter] = GetPlayerName(inviter), [src] = GetPlayerName(src)},
        score = duels[bucket].score
    }

    TriggerClientEvent('duel:start', inviter, true, data)   -- true = spawn1
    TriggerClientEvent('duel:start', src, false, data)     -- false = spawn2
end)

RegisterNetEvent('duel:decline', function()
    invites[source] = nil
end)

RegisterNetEvent('duel:reportKill', function(victim)
    local killer = source
    victim = tonumber(victim)

    for bucket, duel in pairs(duels) do
        if duel.score[killer] and (victim == duel.p1 or victim == duel.p2) then
            -- Basic distance check to reduce obvious exploits
            local killerPed = GetPlayerPed(killer)
            local victimPed = GetPlayerPed(victim)
            if killerPed > 0 and victimPed > 0 then
                local dist = #(GetEntityCoords(killerPed) - GetEntityCoords(victimPed))
                if dist > 150.0 then return end
            end

            duel.score[killer] += 1

            TriggerClientEvent('duel:updateScore', duel.p1, duel.score)
            TriggerClientEvent('duel:updateScore', duel.p2, duel.score)

            if duel.score[killer] >= Config.MaxKills then
                SetPlayerRoutingBucket(duel.p1, 0)
                SetPlayerRoutingBucket(duel.p2, 0)
                TriggerClientEvent('duel:finish', duel.p1, killer)
                TriggerClientEvent('duel:finish', duel.p2, killer)
                duels[bucket] = nil
            else
                local isFirst = math.random() < 0.5
                TriggerClientEvent('duel:newRound', duel.p1, isFirst)
                TriggerClientEvent('duel:newRound', duel.p2, not isFirst)
            end
            break
        end
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for bucket, duel in pairs(duels) do
        if duel.p1 == src or duel.p2 == src then
            local other = duel.p1 == src and duel.p2 or duel.p1
            SetPlayerRoutingBucket(duel.p1, 0)
            SetPlayerRoutingBucket(duel.p2, 0)
            if other and GetPlayerName(other) then
                TriggerClientEvent('duel:finish', other, nil)
            end
            duels[bucket] = nil
            break
        end
    end
end)