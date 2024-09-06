Config = {}

Config.Missions = {
    {
        id = 1,
        name = "Find the Missing Person",
        description = "Locate the missing person last seen near the park.",
        reward = 1000,
        clues = {
            { x = 123.45, y = 678.90, z = 21.34, text = "A torn piece of clothing" },
            { x = 223.45, y = 778.90, z = 204.34, text = "A dropped wallet" },
        },
        npcs = {
            { x = 130.45, y = 680.90, z = 21.34, model = "a_m_m_business_01", hint = "I saw someone running towards the alley." },
            { x = 230.45, y = 780.90, z = 203.34, model = "a_f_y_business_01", hint = "I heard a scream near the park." },
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
    { x = 250.45, y = -1345.90, z = 30.10 },
    { x = 350.45, y = -1450.90, z = 29.34 },
}