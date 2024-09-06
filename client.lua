local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ph_privateinvestigator:startInvestigation')
AddEventHandler('ph_privateinvestigator:startInvestigation', function(missionId)
    local mission = Config.Missions[missionId]
    if mission then
        QBCore.Functions.Notify('Investigation started: ' .. mission.name, 'success')
        
        -- Create blips for clues
        for _, clue in ipairs(mission.clues) do
            local blip = AddBlipForCoord(clue.x, clue.y, clue.z)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 3)
            SetBlipScale(blip, 0.8)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Clue: " .. clue.text)
            EndTextCommandSetBlipName(blip)
            
            -- Spawn clue objects
            local clueModel = GetHashKey("prop_paper_bag_small")
            RequestModel(clueModel)
            while not HasModelLoaded(clueModel) do
                Wait(1)
            end
            local clueObject = CreateObject(clueModel, clue.x, clue.y, clue.z, true, true, false)
            PlaceObjectOnGroundProperly(clueObject)
            FreezeEntityPosition(clueObject, true)
        end
        
        -- Spawn NPCs
        for _, npc in ipairs(mission.npcs) do
            local model = GetHashKey(npc.model)
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(1)
            end
            local ped = CreatePed(4, model, npc.x, npc.y, npc.z, 0.0, true, false)
            SetEntityAsMissionEntity(ped, true, true)
            TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
        end
        
        -- Start timer for the mission
        local startTime = GetGameTimer()
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1000)
                local elapsedTime = (GetGameTimer() - startTime) / 1000
                if elapsedTime >= mission.timeLimit then
                    TriggerServerEvent('ph_privateinvestigator:failInvestigation', missionId)
                    break
                end
            end
        end)
    else
        QBCore.Functions.Notify('Invalid mission ID', 'error')
    end
end)

-- Event to collect evidence
RegisterNetEvent('ph_privateinvestigator:collectEvidence')
AddEventHandler('ph_privateinvestigator:collectEvidence', function(clue)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - vector3(clue.x, clue.y, clue.z))
    
    if distance < 2.0 then
        TriggerServerEvent('ph_privateinvestigator:addEvidence', clue.text)
        QBCore.Functions.Notify('Evidence collected: ' .. clue.text, 'success')
    else
        QBCore.Functions.Notify('You are too far from the clue', 'error')
    end
end)

-- Command to collect evidence
RegisterCommand('collectevidence', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearClue = false
    local clueText = ""
    
    for _, mission in ipairs(Config.Missions) do
        for _, clue in ipairs(mission.clues) do
            local distance = #(playerCoords - vector3(clue.x, clue.y, clue.z))
            if distance < 2.0 then
                nearClue = true
                clueText = clue.text
                break
            end
        end
        if nearClue then break end
    end
    
    if nearClue then
        TriggerServerEvent('ph_privateinvestigator:addEvidence', clueText)
        QBCore.Functions.Notify('Evidence collected: ' .. clueText, 'success')
    else
        QBCore.Functions.Notify('No clue nearby to collect.', 'error')
    end
end, false)

-- Event to show analysis results
RegisterNetEvent('ph_privateinvestigator:showAnalysisResults')
AddEventHandler('ph_privateinvestigator:showAnalysisResults', function(results)
    QBCore.Functions.Notify(results, 'success')
end)

-- Command to analyze evidence at forensic lab
RegisterCommand('analyzeevidence', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearLab = false
    
    for _, lab in ipairs(Config.ForensicLabs) do
        local distance = #(playerCoords - vector3(lab.x, lab.y, lab.z))
        if distance < 5.0 then
            nearLab = true
            break
        end
    end
    
    if nearLab then
        TriggerServerEvent('ph_privateinvestigator:analyzeEvidence')
        QBCore.Functions.Notify('Evidence analysis started', 'success')
    else
        QBCore.Functions.Notify('You need to be at a forensic lab to analyze evidence.', 'error')
    end
end, false)

-- Command to interact with NPCs
RegisterCommand('interactnpc', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearNPC = false
    local npcHint = ""
    
    for _, mission in ipairs(Config.Missions) do
        for _, npc in ipairs(mission.npcs) do
            local distance = #(playerCoords - vector3(npc.x, npc.y, npc.z))
            if distance < 2.0 then
                nearNPC = true
                npcHint = npc.hint
                break
            end
        end
        if nearNPC then break end
    end
    
    if nearNPC then
        TriggerServerEvent('ph_privateinvestigator:interactWithNPC', npcHint)
    else
        QBCore.Functions.Notify('No NPC nearby to interact with.', 'error')
    end
end, false)