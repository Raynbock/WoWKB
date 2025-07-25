--[[
    WoWKB: A moused-over NPC/mob database

    See the README file for more information.
]]

-- English is the default localization for WoWKB
-- if GetLocale() == "usEN" then

-- Buttons, Headers, Various Text
BINDING_NAME_WOWKB_TOGGLE_MAIN_UI = "Toggle Main Frame On/Off"
BINDING_NAME_WOWKB_TOGGLE_OPTIONS_UI = "Toggle Options Frame On/Off"
WOWKB_MAIN_HEADER = "World of WarCraft Knowledge Base"
WOWKB_OPTIONS_HEADER = "WoWKB Options"
WOWKB_ADDON_DESCRIPTION = "A moused-over NPC/mob database."
WOWKB_DOWNLOAD_SITES = "See README for download sites"
WOWKB_LEVEL = "Level"
WOWKB_NOTES_NW_BOUND = "NW Bound"
WOWKB_NOTES_NE_BOUND = "NE Bound"
WOWKB_NOTES_SE_BOUND = "SE Bound"
WOWKB_NOTES_SW_BOUND = "SW Bound"
WOWKB_NOTES_CENTER = "Center"
WOWKB_SHOW_ONLY_LOCAL_NPCS = "Show Only Local NPCs"
WOWKB_SHOW_UPDATES = "Show Updates"
WOWKB_BOUNDING_BOX = "Create Bounding Box Map Notes"
WOWKB_CREATE_MINI_NOTES = "Add MiniNotes To MiniMap"
WOWKB_ONE_MINI_NOTE = "Keep Only The Last MiniNote"
WOWKB_SEARCH_BOX = "Search"
WOWKB_CLOSE_BUTTON = "Close"
WOWKB_OPTIONS_BUTTON = "Options"
WOWKB_CLEAR_NOTES_BUTTON = "Clear Map Notes"
WOWKB_SHOW_MINIMAP_BUTTON = "Show MiniMap Button"
WOWKB_HEADING_NAME = "Name"
WOWKB_HEADING_DESCRIPTION = "Description"
WOWKB_HEADING_LEVEL = "Level"
WOWKB_HEADING_RARITY = "Rarity"
WOWKB_HEADING_ZONE = "Zone/Instance"
WOWKB_HEADING_COORDS = "Coordinates"
WOWKB_CLASSIFICATION_NORMAL = "Normal"
WOWKB_CLASSIFICATION_RARE = "Rare"
WOWKB_CLASSIFICATION_ELITE = "Elite"
WOWKB_CLASSIFICATION_RAREELITE = "Rare Elite"
WOWKB_CLASSIFICATION_WORLDBOSS = "World Boss"

-- Tooltips
WOWKB_QUICK_HELP = "Quick Help"
WOWKB_QUICK_HELP_1 = "1. Left-Click to add map note(s)"
WOWKB_QUICK_HELP_2 = "2. Right-Click to remove map note(s)"
WOWKB_QUICK_HELP_3 = "3. <Ctrl>+<Shift>+Right-Click to remove from database"
WOWKB_QUICK_HELP_4 = "4. Leaving the search box blank returns all records"
WOWKB_QUICK_HELP_5 = "5. RTFM (README)"
WOWKB_SHOW_ONLY_LOCAL_NPCS_HELP = "Only the mobs/NPCs in the zone you are currently in are shown."
WOWKB_SHOW_UPDATES_HELP = "Any change to the database will be displayed in the chat frame."
WOWKB_BOUNDING_BOX_HELP = "Left-Clicking to add MapNotes will add a center point as well as "..
    "points for the four bounding corners and lines connecting them.  Otherwise only the center "..
    "point is added."
WOWKB_CREATE_MINI_NOTES_HELP = "When MapNotes are created by Left-Clicking, the center point "..
    "will be added as a MiniNote on the MiniMap as well."
WOWKB_ONE_MINI_NOTE_HELP = "If Add MiniNotes To MiniMap is enabled this option will clear any "..
    "created by WoWKB before adding a new one so there is only one on the MiniMap at a time."
WOWKB_MINIMAP_BUTTON_TOOLTIP1 = "Toggle WoWKB"
WOWKB_MINIMAP_BUTTON_TOOLTIP2 = "Right-click and drag to move this button."
WOWKB_SHOW_MINIMAP_BUTTON_HELP = "Puts a circular button around the MiniMap which toggles WoWKB."

-- Informational
WOWKB_NO_NPC_MOB_FOUND = "No NPCs/mobs matching \"%s\" found"
WOWKB_REMOVED_FROM_DATABASE = "Removed \"%s\" in \"%s\" from the database"
WOWKB_DISCOVERED_UNIT = "Discovered %s!"
WOWKB_ADDED_UNIT_IN_ZONE = "Added %s in %s"
WOWKB_UPDATED_MIN_X = "Updated Min X for %s in %s to %.2f"
WOWKB_UPDATED_MIN_Y = "Updated Min Y for %s in %s to %.2f"
WOWKB_UPDATED_MAX_X = "Updated Max X for %s in %s to %.2f"
WOWKB_UPDATED_MAX_Y = "Updated Max Y for %s in %s to %.2f"
WOWKB_UPDATED_DESCRIPTION = "Updated Description for %s in %s to %s"
WOWKB_UPDATED_MIN_LEVEL = "Updated Min Level for %s in %s to %u"
WOWKB_UPDATED_MAX_LEVEL = "Updated Max Level for %s in %s to %u"
WOWKB_UPDATED_CLASSIFICATION = "Updated Classification for %s in %s to %s"
WOWKB_IMPORT_SUCCESSFUL = "WoWKB_ImportData merged successfully, added %u entries and updated %u"
WOWKB_METAMAP_IMPORT_SUCCESSFUL = "MetaMap WKB_Data merged successfully, added %u entries and updated %u"
WOWKB_ADDON_LOADED = "|c0000ff00v%s|r - Loaded %u NPCs/mobs in %u Zone(s)/Instance(s)"
WOWKB_SEARCH_RESULTS = "Found %u NPCs/mobs in %u Zone(s)/Instance(s)"
WOWKB_DEBUG_INFO = "Got %s on mouseover of name:%s desc:%s zone:%s (x,y):(%u,%u)"
WOWKB_NO_NOTES_ZONE = "There is not a map of %s to create notes on!"
WOWKB_NOTES_NOT_FOUND = "This feature requires MapNotes (Fan's Update) or Cartographer - See README"

-- Game Data
-- This index of zones is for WoWKB internal use only - the main goal is to avoid storing zone
-- names thousands of times in the database and instead store a much shorter indentifer.  This
-- also has a substantial speed benefit because the number of string comparisons is drastically
-- reduced.
--
-- Anytime zone information needs to be compared with the client or passed to another AddOn
-- such as MapNotes (which is rarely in both cases) it is converted using GetMapZones()
-- information.
--
-- This is not intended to make the WoWKB data compatible across different localized clients.
-- The nature of the information stored (NPC/mob names) makes it extremely difficult to get to a
-- common data format.  You would have to be able to enumerate every NPC/mob name in the game
-- and provide mappings for every language to that enumeration.
--
-- These identifiers are placed in the localization files only because they are language specific
-- and there is no reason to have English language clients searching lists of German or French
-- zone names and vice versa.
--
-- It may seem stupid that the table index and "i" are the same value, but they aren't always the
-- same.  The values for "i" are arbitrary - they could have been anything.  The table indices are
-- important because they will determine the order in which the identifiers are searched (which is
-- why names I want to convert into a "mappable" name are placed at the bottom - conversions will
-- reach them, but lookups should find a matching "i" entry before they are reached.  Most of the
-- zone names at the bottom of the file are from zones where GetZoneText() and GetRealZoneText()
-- do not return the same thing.

WoWKB_ZoneIdentifiers = {
    [1] = {
        z = "Alterac Mountains",
        i = 1,
        k = "Alterac",
    },
    [2] = {
        z = "Arathi Highlands",
        i = 2,
        k = "Arathi",
    },
    [3] = {
        z = "Ashenvale",
        i = 3,
        k = "Ashenvale",
    },
    [4] = {
        z = "Azshara",
        i = 4,
        k = "Aszhara",
    },
    [5] = {
        z = "Badlands",
        i = 5,
        k = "Badlands",
    },
    [6] = {
        z = "Blasted Lands",
        i = 6,
        k = "BlastedLands",
    },
    [7] = {
        z = "Burning Steppes",
        i = 7,
        k = "BurningSteppes",
    },
    [8] = {
        z = "Darkshore",
        i = 8,
        k = "Darkshore",
    },
    [9] = {
        z = "Darnassus",
        i = 9,
        k = "Darnassis",
    },
    [10] = {
        z = "Deadwind Pass",
        i = 10,
        k = "DeadwindPass",
    },
    [11] = {
        z = "Desolace",
        i = 11,
        k = "Desolace",
    },
    [12] = {
        z = "Dun Morogh",
        i = 12,
        k = "DunMorogh",
    },
    [13] = {
        z = "Durotar",
        i = 13,
        k = "Durotar",
    },
    [14] = {
        z = "Duskwood",
        i = 14,
        k = "Duskwood",
    },
    [15] = {
        z = "Dustwallow Marsh",
        i = 15,
        k = "Dustwallow",
    },
    [16] = {
        z = "Eastern Plaguelands",
        i = 16,
        k = "EasternPlaguelands",
    },
    [17] = {
        z = "Elwynn Forest",
        i = 17,
        k = "Elwynn",
    },
    [18] = {
        z = "Felwood",
        i = 18,
        k = "Felwood",
    },
    [19] = {
        z = "Feralas",
        i = 19,
        k = "Feralas",
    },
    [20] = {
        z = "Hillsbrad Foothills",
        i = 20,
        k = "Hilsbrad",
    },
    [21] = {
        z = "Ironforge",
        i = 21,
        k = "Ironforge",
    },
    [22] = {
        z = "Loch Modan",
        i = 22,
        k = "LochModan",
    },
    [23] = {
        z = "Moonglade",
        i = 23,
        k = "Moonglade",
    },
    [24] = {
        z = "Mulgore",
        i = 24,
        k = "Mulgore",
    },
    [25] = {
        z = "Orgrimmar",
        i = 25,
        k = "Ogrimmar",
    },
    [26] = {
        z = "Redridge Mountains",
        i = 26,
        k = "Redridge",
    },
    [27] = {
        z = "Searing Gorge",
        i = 27,
        k = "SearingGorge",
    },
    [28] = {
        z = "Silithus",
        i = 28,
        k = "Silithus",
    },
    [29] = {
        z = "Silverpine Forest",
        i = 29,
        k = "Silverpine",
    },
    [30] = {
        z = "Stonetalon Mountains",
        i = 30,
        k = "StonetalonMountains",
    },
    [31] = {
        z = "Stormwind City",
        i = 31,
        k = "Stormwind",
    },
    [32] = {
        z = "Stranglethorn Vale",
        i = 32,
        k = "Stranglethorn",
    },
    [33] = {
        z = "Swamp of Sorrows",
        i = 33,
        k = "SwampOfSorrows",
    },
    [34] = {
        z = "Tanaris",
        i = 34,
        k = "Tanaris",
    },
    [35] = {
        z = "Teldrassil",
        i = 35,
        k = "Teldrassil",
    },
    [36] = {
        z = "The Barrens",
        i = 36,
        k = "Barrens",
    },
    [37] = {
        z = "The Hinterlands",
        i = 37,
        k = "Hinterlands",
    },
    [38] = {
        z = "Thousand Needles",
        i = 38,
        k = "ThousandNeedles",
    },
    [39] = {
        z = "Thunder Bluff",
        i = 39,
        k = "ThunderBluff",
    },
    [40] = {
        z = "Tirisfal Glades",
        i = 40,
        k = "Tirisfal",
    },
    [41] = {
        z = "Undercity",
        i = 41,
        k = "Undercity",
    },
    [42] = {
        z = "Un'Goro Crater",
        i = 42,
        k = "UngoroCrater",
    },
    [43] = {
        z = "Western Plaguelands",
        i = 43,
        k = "WesternPlaguelands",
    },
    [44] = {
        z = "Westfall",
        i = 44,
        k = "Westfall",
    },
    [45] = {
        z = "Wetlands",
        i = 45,
        k = "Wetlands",
    },
    [46] = {
        z = "Winterspring",
        i = 46,
        k = "Winterspring",
    },

-- 47-56 are skipped due to a mapping error following the 2.0/Burning Crusade patch

-- Zones added with the 2.0/Burning Crusade patch
    [58] = {
        z = "Blade's Edge Mountains",
        i = 58,
        k = "BladesEdgeMountains",
    },
    [62] = {
        z = "Hellfire Peninsula",
        i = 62,
        k = "Hellfire",
    },
    [63] = {
        z = "Nagrand",
        i = 63,
        k = "Nagrand",
    },
    [64] = {
        z = "Netherstorm",
        i = 64,
        k = "Netherstorm",
    },
    [65] = {
        z = "Shadowmoon Valley",
        i = 65,
        k = "ShadowmoonValley",
    },
    [66] = {
        z = "Shattrath City",
        i = 66,
        k = "ShattrathCity",
    },
    [68] = {
        z = "Terokkar Forest",
        i = 68,
        k = "TerokkarForest",
    },
    [70] = {
        z = "Zangarmarsh",
        i = 70,
        k = "Zangarmarsh",
    },

-- Instances and other special zones
    [300] = {
        z = "Deeprun Tram",
        i = 300,
    },
    [301] = {
        z = "The Deadmines",
        i = 301,
    },
    [302] = {
        z = "Blackfathom Deeps",
        i = 302,
    },
    [303] = {
        z = "Ragefire Chasm",
        i = 303,
    },
    [304] = {
        z = "Razorfen Downs",
        i = 304,
    },
    [305] = {
        z = "Razorfen Kraul",
        i = 305,
    },
    [306] = {
        z = "Scarlet Monastery",
        i = 306,
    },
    [307] = {
        z = "Shadowfang Keep",
        i = 307,
    },
    [308] = {
        z = "Wailing Caverns",
        i = 308,
    },
    [309] = {
        z = "The Stockade",
        i = 309,
    },
    [310] = {
        z = "Maraudon",
        i = 310,
    },
    [311] = {
        z = "Uldaman",
        i = 311,
    },
    [312] = {
        z = "Gnomeregan",
        i = 312,
    },
    [313] = {
        z = "Zul'Gurub",
        i = 313,
    },
    [314] = {
        z = "Stratholme",
        i = 314,
    },
    [315] = {
        z = "Scholomance",
        i = 315,
    },
    [316] = {
        z = "Zul'Farrak",
        i = 316,
    },
    [317] = {
        z = "Molten Core",
        i = 317,
    },
    [318] = {
        z = "Blackrock Mountain",
        i = 318,
    },
    [319] = {
        z = "Onyxia's Lair",
        i = 319,
    },
    [320] = {
        z = "Blackwing Lair",
        i = 320,
    },
    [321] = {
        z = "Blackrock Depths",
        i = 321,
    },
    [322] = {
        z = "Dire Maul",
        i = 322,
    },
    [323] = {
        z = "The Temple of Atal'Hakkar",
        i = 323,
    },
    [324] = {
        z = "Hall of Blackhand",
        i = 329,
    },
    [325] = {
        z = "Arathi Basin",
        i = 325,
        k = "ArathiBasin",
    },
    [326] = {
        z = "Alterac Valley",
        i = 326,
        k = "AlteracValley",
    },
    [327] = {
        z = "Warsong Gulch",
        i = 327,
        k = "WarsongGulch",
    },
    [328] = {
        z = "Eye of the Storm",
        i = 328,
        k = "NetherstormArena",
    },
    [329] = {
        z = "Blackrock Spire",
        i = 329,
    },
    [330] = {
        z = "Ruins of Ahn'Qiraj",
        i = 330,
    },
    [331] = {
        z = "Hellfire Citadel",
        i = 331,
    },
    [332] = {
        z = "Coilfang Reservoir",
        i = 332,
    },
    [333] = {
        z = "Auchindoun",
        i = 333,
    },
    [334] = {
        z = "Karazhan",
        i = 334,
    },
    [335] = {
        z = "Tempest Keep",
        i = 335,
    },
    [336] = {
        z = "Caverns of Time",
        i = 336,
    },
    [337] = {
        z = "The Blood Furnace",
        i = 337,
    },
    [338] = {
        z = "Hellfire Ramparts",
        i = 338,
    },
    [339] = {
        z = "The Shattered Halls",
        i = 339,
    },
    [340] = {
        z = "Magtheridon's Lair",
        i = 340,
    },
    [341] = {
        z = "Dire Maul (East)",
        i = 341,
    },
    [342] = {
        z = "Dire Maul (West)",
        i = 342,
    },
    [343] = {
        z = "Dire Maul (North)",
        i = 343,
    },
    [344] = {
        z = "Hall of Legends",
        i = 344,
    },
    [345] = {
        z = "Champions' Hall",
        i = 345,
    },
    [346] = {
        z = "Lower Blackrock Spire",
        i = 346,
    },
    [347] = {
        z = "Upper Blackrock Spire",
        i = 347,
    },
    [348] = {
        z = "Naxxramas",
        i = 348,
    },
    [349] = {
        z = "Blade's Edge Arena",
        i = 349,
    },
    [350] = {
        z = "Nagrand Arena",
        i = 350,
    },
    [351] = {
        z = "Auchenai Crypts",
        i = 351,
    },
    [352] = {
        z = "Mana-Tombs",
        i = 352,
    },
    [353] = {
        z = "Shadow Labyrinth",
        i = 353,
    },
    [354] = {
        z = "Sethekk Halls",
        i = 354,
    },
    [355] = {
        z = "Gates of Ahn'Qiraj",
        i = 355,
    },
    [356] = {
        z = "Temple of Ahn'Qiraj",
        i = 356,
    },
    [357] = {
        z = "The Slave Pens",
        i = 357,
    },
    [358] = {
        z = "The Underbog",
        i = 358,
    },
    [359] = {
        z = "The Steamvault",
        i = 359,
    },
    [360] = {
        z = "Serpentshrine Cavern",
        i = 360,
    },
    [361] = {
        z = "Gruul's Lair",
        i = 361,
    },
    [362] = {
        z = "The Mechanar",
        i = 362,
    },
    [363] = {
        z = "The Botanica",
        i = 363,
    },
    [364] = {
        z = "The Arcatraz",
        i = 364,
    },
    [365] = {
        z = "The Eye",
        i = 365,
    },
    [366] = {
        z = "Old Hillsbrad Foothills",
        i = 366,
    },
    [367] = {
        z = "The Black Morass",
        i = 367,
    },
    [368] = {
        z = "The Battle for Mount Hyjal",
        i = 368,
    },
    [369] = {
        z = "Zul'Aman",
        i = 369,
    },

-- GetZoneText conversions/Renamed zones these must come at the end of the list so when we lookup a
-- name from the identifier we find the preferred GetRealZoneText name first.  These indices are
-- treated as invalid so they don't need to be the same in each localization file.
    [600] = {
        z = "City of Ironforge",
        i = 21,
    },
    [601] = {
        z = "Lion's Pride Inn",
        i = 17,
    },
    [602] = {
        z = "Darkshire Town Hall",
        i = 14,
    },
    [603] = {
        z = "Crypt",
        i = 2,
    },
    [604] = {
        z = "Lakeshire Inn",
        i = 26,
    },
    [605] = {
        z = "Lakeshire Town Hall",
        i = 26,
    },
    [606] = {
        z = "Scarlet Raven Tavern",
        i = 14,
    },
    [607] = {
        z = "Sentinel Tower",
        i = 44,
    },
    [608] = {
        z = "Thistlefur Hold",
        i = 3,
    },
    [609] = {
        z = "Hillsbrad",
        i = 20,
    },
    [610] = {
        z = "Stormwind Stockade",
        i = 309,
    },
    [611] = {
        z = "Anvilmar",
        i = 12,
    },
    [612] = {
        z = "The Wailing Caverns",
        i = 308,
    },
    [613] = {
        z = "The Molten Core",
        i = 317,
    },
    [614] = {
        z = "Booty Bay",
        i = 32,
    },
    [615] = {
        z = "Gadgetzan",
        i = 34,
    },
    [616] = {
        z = "Grom'gol Base Camp",
        i = 32,
    },
    [617] = {
        z = "Menethil Harbor",
        i = 45,
    },
    [618] = {
        z = "Ratchet",
        i = 36,
    },
    [619] = {
        z = "Theramore Isle",
        i = 15,
    },
    [620] = {
        z = "The Bone Wastes",
        i = 333,
    },
    [621] = {
        z = "Ahn'Qiraj",
        i = 28,
    },
    [622] = {
        z = "Plaguewood",
        i = 16,
    },
    [623] = {
        z = "Stormwind",
        i = 31,
    },
}

-- end
