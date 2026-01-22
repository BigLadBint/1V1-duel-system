Config = {}

-- Select how arenas are chosen:
-- 'random' or 'sequential'
Config.ArenaMode = 'random'

Config.Arenas = {
    {
        name = "Sky Arena",
        spawn1 = vector3(-3740.27, -2982.65, 542.92),
        spawn2 = vector3(-3740.33, -3022.46, 542.92)
    },
    {
        name = "Warehouse",
        spawn1 = vector3(1000.12, -3100.45, -39.0),
        spawn2 = vector3(1010.22, -3100.45, -39.0)
    },
    {
        name = "Island Arena",
        spawn1 = vector3(4840.2, -5174.6, 2.0),
        spawn2 = vector3(4855.2, -5174.6, 2.0)
    }
}

Config.Weapon = `WEAPON_PISTOL`
Config.MaxKills = 10
