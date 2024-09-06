# Installation and Usage Guide for Private Investigator Script

## Prerequisites
- **QBCore Framework**: Ensure you have the QBCore framework installed and set up on your FiveM server.

## Installation Steps
1. **Download the Script**:
   - Download the `ph_privateinvestigator` script files and place them in your server's resources directory.

2. **Add to Server Configuration**:
   - Open your server configuration file (`server.cfg`) and add the following line to ensure the script is started when the server runs:
     ```plaintext
     ensure ph_privateinvestigator
     ```

3. **Configure the Script**:
   - Open the `config.lua` file within the `ph_privateinvestigator` directory.
   - Customize the missions, skills, and forensic lab locations as needed.

## Usage Instructions

1. **Starting an Investigation**:
   - As a player with the `privateinvestigator` job, use the following command to start an investigation:
     ```plaintext
     /startinvestigation [missionId]
     ```
   - Replace `[missionId]` with the ID of the mission you want to start (e.g., `1`).

2. **Collecting Evidence**:
   - Approach the clues marked on the map and press the interaction key to collect evidence.
   - The collected evidence will be added to your inventory.

3. **Interacting with NPCs**:
   - Use the following command to interact with nearby NPCs and receive hints:
     ```plaintext
     /interactnpc
     ```
   - Ensure you are close to an NPC to receive a hint.

4. **Analyzing Evidence**:
   - Go to a forensic lab location and use the following command to analyze collected evidence:
     ```plaintext
     /analyzeevidence
     ```
   - You must be at a forensic lab to analyze evidence.

5. **Completing the Investigation**:
   - Once you have collected all necessary evidence and interacted with NPCs, use the following command to complete the investigation:
     ```plaintext
     /completeinvestigation [missionId]
     ```
   - Replace `[missionId]` with the ID of the mission you are completing (e.g., `1`).

6. **Tracking Progress**:
   - Use the following command to display your current investigation progress:
     ```plaintext
     /showprogress(not working)
     ```

    **Important**
    please adjust coords to where you want them in config.lua as it is not setup some stuff is under ground once collected all evidence do /completeinvestigation

## Example Configuration ([`config.lua`](command:_github.copilot.openRelativePath?%5B%7B%22scheme%22%3A%22file%22%2C%22authority%22%3A%22%22%2C%22path%22%3A%22%2Fc%3A%2FUsers%2Fangel%2FDownloads%2Fph_privateinvestigator%2Fconfig.lua%22%2C%22query%22%3A%22%22%2C%22fragment%22%3A%22%22%7D%2C%221f9d5913-8571-45e6-b2c2-2c9005888bbe%22%5D ))
```lua
Config = {}

Config.Missions = {
    {
        id = 1,
        name = "Find the Missing Person",
        description = "Locate the missing person last seen near the park.",
        reward = 1000,
        clues = {
            { x = 123.45, y = 678.90, z = 21.34, text = "A torn piece of clothing" },
            { x = 223.45, y = 778.90, z = 21.34, text = "A dropped wallet" },
        },
        npcs = {
            { x = 130.45, y = 680.90, z = 21.34, model = "a_m_m_business_01", hint = "I saw someone running towards the alley." },
            { x = 230.45, y = 780.90, z = 21.34, model = "a_f_y_business_01", hint = "I heard a scream near the park." },
        },
        timeLimit = 600, -- Time limit in seconds
    },
    -- Add more missions as needed
}

Config.Skills = {
    ['clueDetection'] = {
        label = 'Clue Detection',
        description = 'Increases the chance of finding clues.',
        maxLevel = 5,
    },
    ['interrogation'] = {
        label = 'Interrogation',
        description = 'Increases the success rate of interrogations.',
        maxLevel = 5,
    },
    ['evidenceAnalysis'] = {
        label = 'Evidence Analysis',
        description = 'Increases the accuracy of evidence analysis.',
        maxLevel = 5,
    },
}

Config.ForensicLabs = {
    { x = 250.45, y = -1345.90, z = 29.34 },
    { x = 350.45, y = -1450.90, z = 29.34 },
}

 Excerpt from client.lua, lines 88 to 118

TriggerServerEvent('ph_privateinvestigator:analyzeEvidence')
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
