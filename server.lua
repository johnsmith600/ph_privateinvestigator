local QBCore = exports['qb-core']:GetCoreObject()

-- Initialize player skills and progress
local function initializePlayerData(player)
    if not player.PlayerData.skills then
        player.PlayerData.skills = {
            clueDetection = 1,
            interrogation = 1,
            evidenceAnalysis = 1,
        }
    end
    if not player.PlayerData.progress then
        player.PlayerData.progress = {
            collectedEvidence = {},
            interactedNPCs = {},
        }
    end
end

-- Command to start an investigation
RegisterCommand('startinvestigation', function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    initializePlayerData(Player)
    
    if Player.PlayerData.job.name == 'privateinvestigator' then
        local missionId = tonumber(args[1])
        if missionId and Config.Missions[missionId] then
            Player.PlayerData.progress = {
                collectedEvidence = {},
                interactedNPCs = {},
            }
            TriggerClientEvent('ph_privateinvestigator:startInvestigation', src, missionId)
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid mission ID', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You are not a private investigator', 'error')
    end
end, false)

-- Command to complete the investigation
RegisterCommand('completeinvestigation', function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    initializePlayerData(Player)
    
    if Player.PlayerData.job.name == 'privateinvestigator' then
        local missionId = tonumber(args[1])
        if missionId and Config.Missions[missionId] then
            local mission = Config.Missions[missionId]
            local evidenceCount = #Player.PlayerData.progress.collectedEvidence
            local npcCount = #Player.PlayerData.progress.interactedNPCs
            local requiredEvidenceCount = #mission.clues
            local requiredNpcCount = #mission.npcs
            
            -- Calculate rewards based on progress
            local baseReward = mission.reward
            local evidenceBonus = (evidenceCount / requiredEvidenceCount) * 500
            local npcBonus = (npcCount / requiredNpcCount) * 500
            local totalReward = baseReward + evidenceBonus + npcBonus
            
            if evidenceCount >= requiredEvidenceCount then
                Player.Functions.AddMoney('cash', totalReward)
                TriggerClientEvent('QBCore:Notify', src, 'Investigation completed! You earned $' .. totalReward, 'success')
                
                -- Increase skill levels
                Player.PlayerData.skills.clueDetection = math.min(Player.PlayerData.skills.clueDetection + 1, Config.Skills['clueDetection'].maxLevel)
                Player.PlayerData.skills.interrogation = math.min(Player.PlayerData.skills.interrogation + 1, Config.Skills['interrogation'].maxLevel)
                Player.PlayerData.skills.evidenceAnalysis = math.min(Player.PlayerData.skills.evidenceAnalysis + 1, Config.Skills['evidenceAnalysis'].maxLevel)
            else
                local penalty = (requiredEvidenceCount - evidenceCount) * 100 -- Example penalty calculation
                Player.Functions.RemoveMoney('cash', penalty)
                TriggerClientEvent('QBCore:Notify', src, 'Investigation incomplete! You missed ' .. (requiredEvidenceCount - evidenceCount) .. ' pieces of evidence. Penalty: $' .. penalty, 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid mission ID', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You are not a private investigator', 'error')
    end
end, false)

-- Store collected evidence
RegisterNetEvent('ph_privateinvestigator:addEvidence')
AddEventHandler('ph_privateinvestigator:addEvidence', function(evidence)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    initializePlayerData(Player)
    
    if Player then
        table.insert(Player.PlayerData.progress.collectedEvidence, evidence)
        exports.ox_inventory:AddItem(src, 'evidence', 1, { description = evidence })
        TriggerClientEvent('QBCore:Notify', src, 'Evidence added to your inventory', 'success')
    end
end)

-- Interact with NPCs to receive hints
RegisterNetEvent('ph_privateinvestigator:interactWithNPC')
AddEventHandler('ph_privateinvestigator:interactWithNPC', function(npcHint)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    initializePlayerData(Player)
    
    if Player then
        local successChance = math.random(1, 100)
        local skillLevel = Player.PlayerData.skills.interrogation
        if successChance <= (skillLevel * 20) then
            table.insert(Player.PlayerData.progress.interactedNPCs, npcHint)
            TriggerClientEvent('QBCore:Notify', src, 'NPC Hint: ' .. npcHint, 'success')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Interrogation failed. Try again.', 'error')
        end
    end
end)

-- Command to display progress
RegisterCommand('showprogress', function(source, args, rawCommand)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    initializePlayerData(Player)
    
    if Player then
        local progress = Player.PlayerData.progress
        local progressMessage = "Investigation Progress:\n"
        progressMessage = progressMessage .. "Collected Evidence:\n"
        for _, evidence in ipairs(progress.collectedEvidence) do
            progressMessage = progressMessage .. "- " .. evidence .. "\n"
        end
        progressMessage = progressMessage .. "Interacted NPCs:\n"
        for _, npcHint in ipairs(progress.interactedNPCs) do
            progressMessage = progressMessage .. "- " .. npcHint .. "\n"
        end
        TriggerClientEvent('QBCore:Notify', src, progressMessage, 'info')
    end
end, false)