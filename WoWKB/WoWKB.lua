--[[
    WoWKB: A moused-over NPC/mob database

    See the README file for more information.
]]

BINDING_HEADER_WOWKB = "WoWKB"

WoWKB_Version = GetAddOnMetadata(BINDING_HEADER_WOWKB, "Version")

WoWKB_Details = {
    name = BINDING_HEADER_WOWKB,
    version = WoWKB_Version,
    releaseDate = GetAddOnMetadata(BINDING_HEADER_WOWKB, "X-Date"),
    author = GetAddOnMetadata(BINDING_HEADER_WOWKB, "Author"),
    email = GetAddOnMetadata(BINDING_HEADER_WOWKB, "X-Email"),
    website = WOWKB_DOWNLOAD_SITES,
    category = MYADDONS_CATEGORY_MAP,
    optionsframe = "WoWKB_OptionsFrame",
}

local WoWKB_PlayerX = 0
local WoWKB_PlayerY = 0
local WoWKB_SearchResults = nil
local WoWKB_NextMapNoteIcon = 1
local WoWKB_CartographerIcons = { "Cross", "Circle", "Diamond", "Square", "Star", "Triangle" }

--[[
    Data Template
    UnitName = {
        [ZoneId] = {
            [1] = miny,
            [2] = maxx,
            [3] = maxy,
            [4] = minx,
            [5] = GameTooltipTextLeft2:GetText() unless it's Level,
            [6] = minLevel,
            [7] = maxLevel,
            [8] = UnitClassification enumerated as 0=normal 1=rare 2=elite 3=rareelite 4=worldboss
        }
    }
]]

WOWKB_SCROLL_FRAME_BUTTON_HEIGHT = 16
WOWKB_SCROLL_FRAME_BUTTONS_SHOWN = 25

function WoWKB_DisplayMessage(msg, r, g, b)
    msg = "<"..BINDING_HEADER_WOWKB..">: "..msg
    if DEFAULT_CHAT_FRAME then
        if r == nil or g == nil or b == nil then
            r = 0
            g = 0.4
            b = 1
        end

        DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b)
    end
end

function WoWKB_DebugMessage(msg, r, g, b)
    if WoWKB_State.Debug >= 1 then
        WoWKB_DisplayMessage(msg, r, g, b)
    end
end

function WoWKB_InfoBarShowError(errmsg)
    WoWKB_InfoBar:SetText(errmsg)
    WoWKB_InfoBar:SetTextColor(1,0,0)
    PlaySound("igQuestLogAbandonQuest")
end

function WoWKB_OnLoad()
    table.insert(UISpecialFrames, "WoWKB_MainFrame")
    table.insert(UISpecialFrames, "WoWKB_OptionsFrame")

    SlashCmdList.WOWKB = WoWKB_SearchFromSlashCommand
    SLASH_WOWKB1 = "/wowkb"
    SLASH_WOWKB2 = "/wkb"

    -- UI init
    WoWKB_HeadingName:SetWidth(WoWKB_HeadingPanel:GetWidth()*0.25)
    WoWKB_HeadingDescription:SetWidth(WoWKB_HeadingPanel:GetWidth()*0.25)
    WoWKB_HeadingLevel:SetWidth(WoWKB_HeadingPanel:GetWidth()*0.06)
    WoWKB_HeadingRarity:SetWidth(WoWKB_HeadingPanel:GetWidth()*0.10)
    WoWKB_HeadingZone:SetWidth(WoWKB_HeadingPanel:GetWidth()*0.21)
    WoWKB_HeadingCoords:SetWidth(WoWKB_HeadingPanel:GetWidth()*0.13)
    for i=1, WOWKB_SCROLL_FRAME_BUTTONS_SHOWN,1 do
        getglobal("WoWKB_ScrollFrameButton"..i.."Name"):SetWidth(WoWKB_HeadingName:GetWidth())
        getglobal("WoWKB_ScrollFrameButton"..i.."Description"):SetWidth(WoWKB_HeadingDescription:GetWidth())
        getglobal("WoWKB_ScrollFrameButton"..i.."Level"):SetWidth(WoWKB_HeadingLevel:GetWidth())
        getglobal("WoWKB_ScrollFrameButton"..i.."Rarity"):SetWidth(WoWKB_HeadingRarity:GetWidth())
        getglobal("WoWKB_ScrollFrameButton"..i.."Zone"):SetWidth(WoWKB_HeadingZone:GetWidth())
        getglobal("WoWKB_ScrollFrameButton"..i.."Coords"):SetWidth(WoWKB_HeadingCoords:GetWidth())
    end
end

function WoWKB_OnEvent(arg1)
    if event == "UPDATE_MOUSEOVER_UNIT" then
        WoWKB_UpdateMouseoverUnit()
    elseif event == "ADDON_LOADED" then
        WoWKB_AddOnLoaded(arg1)
    end
end

function WoWKB_GetDataStats(table)
    local tempZones = {}
    local nameCount = 0
    local zoneCount = 0

    for name,zoneTable in pairs(table) do
        for zone in pairs(zoneTable) do
            nameCount = nameCount + 1
            if tempZones[zone] == nil then
                zoneCount = zoneCount + 1
                tempZones[zone] = 1
            end
        end
    end

    return nameCount,zoneCount
end

function WoWKB_SearchFromSlashCommand(searchText)
    WoWKB_State.LastSearch = searchText
    WoWKB_MainFrame:Hide()
    WoWKB_MainFrame:Show()
end

function WoWKB_GetPlayerCoords()
    SetMapToCurrentZone()

    WoWKB_PlayerX, WoWKB_PlayerY = GetPlayerMapPosition("player")

    -- turn 0.123456 into 1234
    WoWKB_PlayerX = WoWKB_Round(WoWKB_PlayerX*10000, 0)
    WoWKB_PlayerY = WoWKB_Round(WoWKB_PlayerY*10000, 0)
end

function WoWKB_ExtractLevel(msg)
    local level = string.gsub(msg,".-"..TEXT(WOWKB_LEVEL).." (%-?%d%d?).*","%1")

    if level == msg then
        level = string.gsub(msg,".-"..TEXT(WOWKB_LEVEL).." (%?%?).*","%1")
    end
        
    if level == msg then
        assert(false, "WoWKB_ExtractLevel failed to do so msg:["..msg.."]")
    end

    if level == "??" then
        return -1
    else
        if tonumber(level) == nil then
            assert(false, "WoWKB_ExtractLevel failed to do so level:["..level.."] msg:["..msg.."]")
        end
        return tonumber(level)
    end
end

function WoWKB_ExtractClassification(msg)
-- [8] = UnitClassification enumerated as 0=normal 1=rare 2=elite 3=rareelite 4=worldboss
    if string.find(msg,"normal",1,true) ~= nil then
        return 0
    elseif string.find(msg,"rare",1,true) ~= nil then
        return 1
    elseif string.find(msg,"elite",1,true) ~= nil then
        return 2
    elseif string.find(msg,"rareelite",1,true) ~= nil then
        return 3
    elseif string.find(msg,"worldboss",1,true) ~= nil then
        return 4
    else
        return 0
    end
end

function WoWKB_RoundAndScale(value)
    return WoWKB_Round(value/100, 2)
end

-- returns       coordString, dx, dy, centerx, centery
--         "(12-34),(56-78)", 50, 50,   11.00,   11.00
function WoWKB_GetCoordString(entry)
    local cleanCoords = {}

    for i=1,4 do
        -- turns 1234 into 12
        cleanCoords[i] = WoWKB_Round(entry[i]/100, 0)
    end

    local dx = entry[2] - entry[4]
    local dy = entry[3] - entry[1]
    local centerx = WoWKB_RoundAndScale(entry[4] + dx/2)
    local centery = WoWKB_RoundAndScale(entry[1] + dy/2)

    -- if the NPC has a range of 3 map units or greater, show ranges
    if dx >= 300 or dy >= 300 then
        coordString = "("..cleanCoords[4].."-"..cleanCoords[2].."),"..
                       " ("..cleanCoords[1].."-"..cleanCoords[3]..")"
    else
    -- otherwise just show an averaged point
        coordString = "("..centerx..", "..centery..")"
    end

    return coordString, dx, dy, centerx, centery
end

function WoWKB_GetClassificationString(value)
    if value == 0 then
        return TEXT(WOWKB_CLASSIFICATION_NORMAL)
    elseif value == 1 then
        return TEXT(WOWKB_CLASSIFICATION_RARE)
    elseif value == 2 then
        return TEXT(WOWKB_CLASSIFICATION_ELITE)
    elseif value == 3 then
        return TEXT(WOWKB_CLASSIFICATION_RAREELITE)
    elseif value == 4 then
        return TEXT(WOWKB_CLASSIFICATION_WORLDBOSS)
    else
        return TEXT(WOWKB_CLASSIFICATION_NORMAL)
    end
end

function WoWKB_Search(searchText, suppressErrors)
    if searchText == nil then
        searchText = WoWKB_State.LastSearch
    end

    if suppressErrors == nil then
        suppressErrors = false
    end

    WoWKB_State.LastSearch = searchText

    WoWKB_GetPlayerCoords()

    FauxScrollFrame_SetOffset(WoWKB_ScrollFrame, 0)
    WoWKB_BuildSearchResults()
    WoWKB_UpdateScrollFrame()

    WoWKB_SearchEditBox:SetText(WoWKB_State.LastSearch)

    if WoWKB_SearchResults.onePastEnd == 1 and not suppressErrors then
        local nameCount = WoWKB_GetDataStats(WoWKB_Data)

        if nameCount ~= 0 then
            WoWKB_InfoBarShowError(format(TEXT(WOWKB_NO_NPC_MOB_FOUND), WoWKB_State.LastSearch))
        end
    end
end

function WoWKB_ClearMapNotes()
    if WoWKB_CompatibleMapNotesLoaded() then
        MapNotes_DeleteNotesByCreatorAndName(TEXT(BINDING_HEADER_WOWKB))
        PlaySound("igQuestLogAbandonQuest")
    end

    if WoWKB_CompatibleCartographerLoaded() then
        WoWKB_CartographerDeleteNotesByName()
        PlaySound("igQuestLogAbandonQuest")
    end
end

function WoWKB_CompatibleMapNotesLoaded()
    if MapNotes_DeleteNotesByCreatorAndName == nil or MapNotes_GetNoteBySlashCommand == nil or
       MapNotes_ClearMiniNotesByCreator == nil or MapNotes_ToggleLine == nil then
        return false
    end

    if MAPNOTES_VERSION == nil then
        return false
    end

    local major = string.gsub(MAPNOTES_VERSION,"(.*)%..*%..*","%1",1)
    local minor = string.gsub(MAPNOTES_VERSION,".*%.(.*)%..*","%1",1)
    local interface = string.gsub(MAPNOTES_VERSION,".*%..*%.(.*)","%1",1)

    if major == MAPNOTES_VERSION or minor == MAPNOTES_VERSION or interface == MAPNOTES_VERSION then
        return false
    end
    
    major = tonumber(major)
    minor = tonumber(minor)
    interface = tonumber(interface)

    if major == nil or minor == nil or interface == nil then
        return false
    end

    if interface >= 30200 then
        if major >= 5 then
            if minor >= 16 then
                return true
            end
        end
    end

    return false
end

function WoWKB_CompatibleCartographerLoaded()
    if Cartographer_Notes == nil or Cartographer_Notes.SetNote == nil or Cartographer_Notes.RefreshMap == nil or
       Cartographer_Notes.RegisterNotesDatabase == nil or Cartographer_Notes.GetIconList == nil then
        return false
    end

    return true
end

function WoWKB_AddOnLoaded(addon)
    if addon == BINDING_HEADER_WOWKB then
        -- defaults
        if WoWKB_Data == nil then
            WoWKB_Data = {}
        end

        if WoWKB_State == nil then
            WoWKB_State = {
                Version = 0,
                ShowOnlyLocalNPCs = false,
                ShowUpdates = false,
                CreateMapNotesBoundingBox = true,
                ShowMiniMapButton = true,
                MiniMapButtonPosition = 315,
                OneMiniNote = true,
                CreateMiniNotes = true,
                SortBy = "WoWKB_HeadingName",
                ReverseSort = false,
                Debug = 0,
                LastSearch = "",
            }
        end

        if WoWKB_ImportState == nil then
            WoWKB_ImportState = WoWKB_Copy(WoWKB_State)
        end

        if WoWKB_UnknownZones == nil then
            WoWKB_UnknownZones = {}
        end

        if WoWKB_ImportUnknownZones ~= nil then
            WoWKB_MergeUnknownZones(WoWKB_ImportUnknownZones)
            WoWKB_ImportUnknownZones = nil
        end

        if WoWKB_CompatibleCartographerLoaded() and WoWKB_CartographerNotes == nil then
            WoWKB_CartographerNotes = {}
        end

        WoWKB_State, WoWKB_Data = WoWKB_Upgrade(WoWKB_State, WoWKB_Data)

        WoWKB_Import()

        -- set UI state
        WoWKB_OptionsFrameInit()
        WoWKB_MiniMapButtonInit()

        -- Remove MapNotes dependent UI elements if we don't have MapNotes
        if not WoWKB_CompatibleMapNotesLoaded() then
            WoWKB_BoundingBoxCheckButton:Hide()
            WoWKB_CreateMiniNotesCheckButton:Hide()
            WoWKB_OneMiniNoteCheckButton:Hide()
            WoWKB_OptionsFrame:SetHeight(110)
        end

        -- Remove notes dependent UI elements if we don't have MapNotes or Cartographer
        if not WoWKB_CompatibleMapNotesLoaded() and not WoWKB_CompatibleCartographerLoaded() then
            WoWKB_ClearNotesButton:Hide()
        end

        if myAddOnsFrame_Register then
            myAddOnsFrame_Register(WoWKB_Details, WoWKB_Help)
        end

        if WoWKB_CompatibleCartographerLoaded() then
            Cartographer_Notes:RegisterNotesDatabase("WoWKB", WoWKB_CartographerNotes)
        end

        if(not IsAddOnLoaded("MetaMapWKB")) then
		    LoadAddOn("MetaMapWKB")
	    end

        WoWKB_DisplayMessage(format(TEXT(WOWKB_ADDON_LOADED), WoWKB_Version, WoWKB_GetDataStats(WoWKB_Data)), 1, 1, 0)
    elseif addon == "MetaMapWKB" then
        -- MetaMapWKB import
        if WKB_Data ~= nil then
            local addedEntries = 0
            local updatedEntries = 0

            addedEntries,updatedEntries = WoWKB_MergeMetaMapData(WKB_Data)
            WoWKB_DisplayMessage(format(TEXT(WOWKB_METAMAP_IMPORT_SUCCESSFUL), addedEntries, updatedEntries), 0, 1, 0)
        end
    end
end

function WoWKB_Import()
    if WoWKB_ImportData ~= nil then
        local addedEntries = 0
        local updatedEntries = 0

        WoWKB_ImportState, WoWKB_ImportData = WoWKB_Upgrade(WoWKB_ImportState, WoWKB_ImportData)
        addedEntries,updatedEntries = WoWKB_MergeData(WoWKB_ImportData)
        WoWKB_ImportState = nil
        WoWKB_ImportData = nil
        WoWKB_DisplayMessage(format(TEXT(WOWKB_IMPORT_SUCCESSFUL), addedEntries, updatedEntries), 0, 1, 0)
    end
end

function WoWKB_Upgrade(StateToUpgrade, DataToUpgrade)
    if StateToUpgrade.Version == 0 then
        StateToUpgrade.Version = 1800.1
    end

    if tonumber(StateToUpgrade.Version) <= 1800.1 then
        StateToUpgrade.ShowMiniMapButton = true
        StateToUpgrade.MiniMapButtonPosition = 315

        StateToUpgrade.Version = 1800.2
    end

    if tonumber(StateToUpgrade.Version) <= 20000.3 then
        StateToUpgrade.OneMiniNote = true
        StateToUpgrade.CreateMiniNotes = true

        StateToUpgrade.Version = 20000.4
    end

    if StateToUpgrade.Version <= 20000.4 then
        StateToUpgrade.SortBy = "WoWKB_HeadingName"
        StateToUpgrade.ReverseSort = false
        DataToUpgrade = WoWKB_UpgradeDataTo20000_5(DataToUpgrade)

        StateToUpgrade.Version = 20000.5
    end

    if StateToUpgrade.Version <= 20003.4 then
        DataToUpgrade = WoWKB_UpgradeDataTo20003_6(DataToUpgrade)
        StateToUpgrade.Debug = 0
        StateToUpgrade.LastSearch = ""

        DataToUpgrade = WoWKB_RemoveNamesWithNoZones(DataToUpgrade)
        DataToUpgrade = WoWKB_UpdateUnknownZones(DataToUpgrade)

        StateToUpgrade.Version = 20003.6
    end

    return StateToUpgrade, DataToUpgrade
end

function WoWKB_UpgradeDataTo20000_5(table)
    -- Fix instance number problem discovered following 2.0 patch
    -- and convert unknown zones that are now known
    local temp = {}

    for name,zoneTable in pairs(table) do
        for zone,entry in pairs(zoneTable) do
            local newZone = zone
            if type(zone) == "number" and zone >= 47 and zone <= 56 then
                newZone = zone + 253
            end

            newZone = WoWKB_ConvertZoneNameToIdentifier(newZone)
            WoWKB_MergeEntry(temp, name, newZone, false, entry[1], entry[2], entry[3],
                             entry[4], entry[5], true, entry[6], entry[7], entry[8])
        end
    end

    return temp
end

function WoWKB_UpgradeDataTo20003_6(table)
    local temp = {}

    for name,zoneTable in pairs(table) do
        -- remove strange color blocks observed in non-english clients as well as braces '<' and '>'
        local newName = WoWKB_StripTextColors(name)
        local level = -1
        local description = ""

        -- fix localized data that was looking for the wrong Level string
        if string.find(newName,TEXT(WOWKB_LEVEL),1,true) ~= nil then
            level = WoWKB_ExtractLevel(newName)
            newName = string.sub(newName, 0, string.find(newName," (",1,true) - 1)
        end

        -- separate description from name
        if string.find(newName," (",1,true) ~= nil then
            description = string.gsub(newName,".- %((.-)%)","%1")
            if description == newName then
                description = ""
            end
            newName = string.sub(newName, 0, string.find(newName," (",1,true) - 1)
        end

        if string.find(newName,TEXT(UNKNOWNOBJECT),1,true) == nil then
            for zone,entry in pairs(zoneTable) do
                if description == "" then
                    description = entry[5]
                end

                local minLevel,maxLevel = level,level
                if minLevel == -1 then
                    minLevel = entry[6]
                end
                if maxLevel == -1 then
                    maxLevel = entry[7]
                end
                
                WoWKB_MergeEntry(temp, newName, zone, false, entry[1], entry[2], entry[3],
                                 entry[4], description, true, minLevel, maxLevel, entry[8])
            end
        end
    end

    return temp
end

-- returns addedEntry, updatedEntry
function WoWKB_MergeEntry(table, name, zone, showUpdates, miny, maxx, maxy, minx, description, replaceDesc, minLevel, maxLevel, classification)
    local addedEntry = false
    local updatedEntry = false
    local show = WoWKB_State.ShowUpdates and showUpdates

    if table[name] == nil then
        table[name] = {}
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_DISCOVERED_UNIT), name),0.8,0,0)
        end
    end

    if table[name][zone] == nil then
        table[name][zone] = { 20000, -1, -1, 20000, "", -1, -1, 0 }
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_ADDED_UNIT_IN_ZONE), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone)),0.8,0,0)
        end
        addedEntry = true
    end

    if miny ~= nil and (table[name][zone][1] == 20000 or (miny ~= 0 and (table[name][zone][1] == 0 or miny < table[name][zone][1]))) then
        table[name][zone][1] = miny
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_MIN_Y), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone),
                                 WoWKB_RoundAndScale(miny)),0.8,0,0)
        end
        updatedEntry = true
    end

    if maxx ~= nil and maxx > table[name][zone][2] then
        table[name][zone][2] = maxx
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_MAX_X), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone),
                                 WoWKB_RoundAndScale(maxx)),0.8,0,0)
        end
        updatedEntry = true
    end

    if maxy ~= nil and maxy > table[name][zone][3] then
        table[name][zone][3] = maxy
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_MAX_Y), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone),
                                 WoWKB_RoundAndScale(maxy)),0.8,0,0)
        end
        updatedEntry = true
    end

    if minx ~= nil and (table[name][zone][4] == 20000 or (minx ~= 0 and (table[name][zone][4] == 0 or minx < table[name][zone][4]))) then
        table[name][zone][4] = minx
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_MIN_X), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone),
                                 WoWKB_RoundAndScale(minx)),0.8,0,0)
        end
        updatedEntry = true
    end

    if description ~= nil and description ~= table[name][zone][5] and (addedEntry or replaceDesc) then
        table[name][zone][5] = description
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_DESCRIPTION), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone), description),0.8,0,0)
        end
        updatedEntry = true
    end

    if minLevel ~= nil and minLevel ~= -1 then
        if table[name][zone][6] == -1 or minLevel < table[name][zone][6] then
            table[name][zone][6] = minLevel
            if show then
                WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_MIN_LEVEL), name,
                                     WoWKB_ConvertZoneIdentifierToName(zone), minLevel),0.8,0,0)
            end
            updatedEntry = true
        end
    end

    if maxLevel ~= nil and maxLevel ~= -1 then
        if table[name][zone][7] == -1 or maxLevel > table[name][zone][7] then
            table[name][zone][7] = maxLevel
            if show then
                WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_MAX_LEVEL), name,
                                     WoWKB_ConvertZoneIdentifierToName(zone), maxLevel),0.8,0,0)
            end
            updatedEntry = true
        end
    end

    if classification ~= nil and classification ~= table[name][zone][8] then
        table[name][zone][8] = classification
        if show then
            WoWKB_DisplayMessage(format(TEXT(WOWKB_UPDATED_CLASSIFICATION), name,
                                 WoWKB_ConvertZoneIdentifierToName(zone),
                                 WoWKB_GetClassificationString(classification)),0.8,0,0)
        end
        updatedEntry = true
    end

    if addedEntry then
        updatedEntry = false
    end

    return addedEntry, updatedEntry
end

function WoWKB_UpdateUnknownZones(table)
    -- convert unknown zones that are now known
    local temp = {}
    WoWKB_UnknownZones = {}

    for name,zoneTable in pairs(table) do
        for zone,entry in pairs(zoneTable) do
            local newZone = WoWKB_ConvertZoneNameToIdentifier(zone)
            local newZoneName = WoWKB_ConvertZoneIdentifierToName(newZone)
            if type(newZoneName) ~= "number" or
                (type(newZoneName) == "string" and tonumber(newZoneName) == nil) then
                WoWKB_MergeEntry(temp, name, newZone, false, entry[1], entry[2], entry[3], entry[4],
                                 entry[5], true, entry[6], entry[7], entry[8])
            end
        end
    end

    return temp
end

function WoWKB_Round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function WoWKB_SortedPairs(t,comparator)
    local sortedKeys = {}
    table.foreach(t, function(k,v) table.insert(sortedKeys,k) end)
    table.sort(sortedKeys,comparator)
    local i = 0
    local function _f(_s,_v)
        i = i + 1
        local k = sortedKeys[i]
        if k then
            return k,t[k]
        end
    end
    return _f,nil,nil
end

function WoWKB_Copy(source, lookup)
    lookup = lookup or {}
    local copy = {}

    if not lookup[source] then
        lookup[source] = copy
    end

    for i,v in pairs( source ) do
        if type( i ) == "table" then
            if lookup[i] then
                i = lookup[i]
            else
                i = WoWKB_Copy( i, lookup )
            end
        end

        if type( v ) ~= "table" then
            copy[i] = v
        else
            if lookup[v] then
                copy[i] = lookup[v]
            else
                copy[i] = WoWKB_Copy( v, lookup )
            end
        end
    end
    
    return copy
end

function WoWKB_StripTextColors(textString)
    -- this function is designed to replace
    -- |cff00AA00Colored Text|r
    -- with
    -- Colored Text
    if textString ~= nil then
        -- remove |cff00AA00 elements
        textString = string.gsub(textString, "|c[%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f][%dA-Fa-f]"..
                           "[%dA-Fa-f][%dA-Fa-f][%dA-Fa-f]", "")

        -- remove |r elements
        textString = string.gsub(textString, "|r", "")

        -- remove braces '<' and '>'
        textString = string.gsub(textString, "<", "")
        textString = string.gsub(textString, ">", "")

        return textString
    else
        assert(false, "nil or invalid parameter to StripTextColors")
    end
end

function WoWKB_MergeData(MergeData)
    local addedEntries = 0
    local updatedEntries = 0

    for name,zoneTable in pairs(MergeData) do
        for zone,entry in pairs(zoneTable) do
            local addedEntry = nil
            local updatedEntry = nil
            addedEntry, updatedEntry = WoWKB_MergeEntry(WoWKB_Data, name, zone, false, entry[1], entry[2], entry[3],
                                                        entry[4], entry[5], true, entry[6], entry[7], entry[8])

            if addedEntry then
                addedEntries = addedEntries + 1
            end

            if updatedEntry then
                updatedEntries = updatedEntries + 1
            end
        end
    end

    return addedEntries, updatedEntries
end

function WoWKB_MergeMetaMapData(WKB_DataIn)
    local addedEntries = 0
    local updatedEntries = 0

    for zoneText,nameTable in pairs(WKB_DataIn) do
        for name,entry in pairs(nameTable) do
            local description = ""
            local level = -1
            local classification = 0
            local zone = WoWKB_ConvertZoneNameToIdentifier(zoneText)

            if string.find(entry.inf2,TEXT(WOWKB_LEVEL),1,true) ~= nil then
                level = WoWKB_ExtractLevel(entry.inf2)
                if entry.icon == 3 then
                    description = entry.inf1
                end
            end

            if entry.icon == 1 then
                classification = WoWKB_ExtractClassification(entry.inf1)
            end

            local addedEntry = nil
            local updatedEntry = nil
            addedEntry, updatedEntry = WoWKB_MergeEntry(WoWKB_Data, name, zone, false, entry[1], entry[2], entry[3],
                                                        entry[4], description, false, level, level, classification)

            if addedEntry then
                addedEntries = addedEntries + 1
            end

            if updatedEntry then
                updatedEntries = updatedEntries + 1
            end
        end
    end

    return addedEntries, updatedEntries
end

function WoWKB_MergeUnknownZones(MergeUnknownZones)
    for name in pairs(MergeUnknownZones) do
        WoWKB_UnknownZones[name] = 0
    end
end

function WoWKB_UpdateMouseoverUnit()
    if WoWKB_State.Debug >= 2 then
        WoWKB_DebugMouseover()
    end

    if UnitIsPlayer("mouseover")~=1 and UnitPlayerControlled("mouseover")~=1 and
            UnitIsDeadOrGhost("mouseover")~=1 then

        local zone = WoWKB_ConvertZoneNameToIdentifier(WoWKB_GetRealZoneText())
        local unitName = UnitName("mouseover")
        local description = GameTooltipTextLeft2:GetText()
        local level = UnitLevel("mouseover")
        local classification = WoWKB_ExtractClassification(UnitClassification("mouseover"))
        local playerX, playerY = GetPlayerMapPosition("player")

        -- turn 0.123456 into 1234
        playerX = WoWKB_Round(playerX*10000, 0)
        playerY = WoWKB_Round(playerY*10000, 0)

        if unitName == TEXT(UNKNOWNOBJECT) or unitName == "" or unitName == nil then
            WoWKB_DebugMessage(format(TEXT(WOWKB_DEBUG_INFO), "bad name", unitName, description, zone, playerX, playerY))
            return
        end

        -- Sometimes zone comes up blank, I noticed it was on Innkeepers both times I saw it so
        -- perhaps there's a bug inside Inns - maybe only when you first log in (since it seems
        -- to be rare and only happen in Inns...)
        if zone == "" then
            WoWKB_DebugMessage(format(TEXT(WOWKB_DEBUG_INFO), "bad zone", unitName, description, zone, playerX, playerY))
            return
        end

        if type(zone) == "string" then
            WoWKB_DebugMessage(format(TEXT(WOWKB_DEBUG_INFO), "unknown zone", unitName, description, zone, playerX, playerY))
        end

        -- The player position seems to come up as 0,0 pretty frequently in instances but it
        -- seems to me we should still store what we know about the NPC/mob
        if playerX == 0 and playerY == 0 then
            WoWKB_DebugMessage(format(TEXT(WOWKB_DEBUG_INFO), "bad coords", unitName, description, zone, playerX, playerY))
        end

        -- A bug report from curse looks like the level was nil
        if level == nil then
            WoWKB_DebugMessage(format(TEXT(WOWKB_DEBUG_INFO), "bad level", unitName, description, zone, playerX, playerY))
            return
        end

        -- omit description ("Innkeeper" etc.) if its the level of the unit
        if string.find(description,TEXT(WOWKB_LEVEL),1,true) ~= nil then
            description = ""
        end

        -- strip off any colors
        unitName = WoWKB_StripTextColors(unitName)
        description = WoWKB_StripTextColors(description)

        local addedEntry = nil
        local updatedEntry = nil
        addedEntry, updatedEntry = WoWKB_MergeEntry(WoWKB_Data, unitName, zone, true, playerY, playerX, playerY,
                                                    playerX, description, true, level, level, classification)

        if (addedEntry or updatedEntry) and WoWKB_MainFrame:IsVisible() then
            WoWKB_Search(WoWKB_State.LastSearch, true)
        end
    end
end

function WoWKB_DebugMouseover()
    if UnitIsPlayer("mouseover")~=1 and UnitPlayerControlled("mouseover")~=1 and
            UnitIsDead("mouseover")~=1 then
        local unitName = UnitName("mouseover")
        local description = GameTooltipTextLeft2:GetText()
        local zone = WoWKB_GetRealZoneText()
        local level = UnitLevel("mouseover")
        local classification = UnitClassification("mouseover")
        WoWKB_DebugMessage("name:"..unitName.." desc:"..description.." level:"..level.." classification:"..
                           classification.." zone:"..zone)
    end
end

function WoWKB_UpdateScrollFrame()
    if not WoWKB_SearchResults then
        WoWKB_BuildSearchResults()
    end

    for iScrollFrameButton = 1, WOWKB_SCROLL_FRAME_BUTTONS_SHOWN, 1 do
        local buttonIndex = iScrollFrameButton + FauxScrollFrame_GetOffset(WoWKB_ScrollFrame)
        local scrollFrameButton = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton)
        local scrollFrameButtonName = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton.."Name")
        local scrollFrameButtonDescription = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton.."Description")
        local scrollFrameButtonLevel = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton.."Level")
        local scrollFrameButtonRarity = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton.."Rarity")
        local scrollFrameButtonZone = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton.."Zone")
        local scrollFrameButtonCoords = getglobal("WoWKB_ScrollFrameButton"..iScrollFrameButton.."Coords")

        if buttonIndex < WoWKB_SearchResults.onePastEnd then
            local name = WoWKB_SearchResults[buttonIndex][1]
            local zone = WoWKB_SearchResults[buttonIndex][2]
            local entry = WoWKB_Data[name][zone]
            local description = entry[5]
            local level = "??"
            if entry[6] ~= -1 then
                if entry[6] == entry[7] then
                    level = entry[6]
                else
                    level = entry[6].."-"..entry[7]
                end
            end
            local classification = WoWKB_GetClassificationString(entry[8])
            local coordString = ""

            coordString = WoWKB_GetCoordString(entry)

            scrollFrameButtonName:SetText(name)
            scrollFrameButtonDescription:SetText(description)
            scrollFrameButtonLevel:SetText(level)
            scrollFrameButtonRarity:SetText(classification)
            scrollFrameButtonZone:SetText(WoWKB_ConvertZoneIdentifierToName(zone))
            scrollFrameButtonCoords:SetText(coordString)

            if zone == WoWKB_ConvertZoneNameToIdentifier(WoWKB_GetRealZoneText()) then
                if entry[2]>=WoWKB_PlayerX and entry[4]<=WoWKB_PlayerX and
                        entry[3]>=WoWKB_PlayerY and entry[1]<=WoWKB_PlayerY then
                    -- Unit is close, show in green
                    scrollFrameButtonCoords:SetTextColor(0,1,0)
                else
                    -- Unit is in the same zone, show in yellow
                    scrollFrameButtonCoords:SetTextColor(1,1,0)
                end

                scrollFrameButton:Show()
            else
                if not WoWKB_State.ShowOnlyLocalNPCs then
                    -- Unit is in a different zone, show in red
                    scrollFrameButtonCoords:SetTextColor(1,0,0)

                    scrollFrameButton:Show()
                else
                    scrollFrameButton:Hide()
                end
            end
        else
            scrollFrameButton:Hide()
        end
    end

    FauxScrollFrame_Update(WoWKB_ScrollFrame, WoWKB_SearchResults.onePastEnd - 1,
        WOWKB_SCROLL_FRAME_BUTTONS_SHOWN, WOWKB_SCROLL_FRAME_BUTTON_HEIGHT)
end

function WoWKB_BuildSearchResults()
    local index = 1
    local tempZones = {}
    local zoneCount = 0
    local localZone = WoWKB_ConvertZoneNameToIdentifier(WoWKB_GetRealZoneText())
    local keyword = string.lower(WoWKB_State.LastSearch)
    local searchLevel = tonumber(WoWKB_State.LastSearch) or string.find(keyword,"-",1,true) or string.find(keyword,"?",1,true)
    local found = false

    WoWKB_SearchResults = {}
    for name,zoneTable in pairs(WoWKB_Data) do
        local searchName = string.lower(name) 
        for zone,entry in pairs(zoneTable) do
            found = false
            if not WoWKB_State.ShowOnlyLocalNPCs or zone == localZone then
                if string.find(searchName,keyword,1,true)~=nil or
                    string.find(string.lower(entry[5]),keyword,1,true)~=nil or
                    string.find(string.lower(WoWKB_ConvertZoneIdentifierToName(zone)),keyword,1,true)~=nil or
				    string.find(string.lower(WoWKB_GetClassificationString(entry[8])),keyword,1,true)~=nil then
                        found = true
                end

                if searchLevel then
                    if string.find(string.lower(entry[6]),keyword,1,true)~=nil or
				        string.find(string.lower(entry[7]),keyword,1,true)~=nil or
                        (entry[6] == -1 and string.find("??",keyword,1,true)~=nil) then
                        found = true
                    end
                end

                if found then
                    WoWKB_SearchResults[index] = {}
                    WoWKB_SearchResults[index][1] = name
                    WoWKB_SearchResults[index][2] = zone
                    index = index + 1
                    if tempZones[zone] == nil then
                        zoneCount = zoneCount + 1
                        tempZones[zone] = 1
                    end
                end
            end
        end
    end

    WoWKB_SearchResults.onePastEnd = index
    WoWKB_ScrollFrameSort(WoWKB_State.SortBy, false)

    WoWKB_InfoBar:SetText(format(TEXT(WOWKB_SEARCH_RESULTS), index-1, zoneCount))
    WoWKB_InfoBar:SetTextColor(0,0.5,1)
end

function WoWKB_ConvertZoneNameToIdentifier(zoneNameToConvert)
    for i,zoneTable in WoWKB_SortedPairs(WoWKB_ZoneIdentifiers) do
        if zoneNameToConvert == zoneTable.z then
            return zoneTable.i
        end
    end

    -- We leave zone names we don't know about (due to a patch, GetZoneText/GetRealZoneText
    -- weirdness, etc.) intact and we will convert them in a future version
    if type(zoneNameToConvert) == "string" and zoneNameToConvert ~= "" then
        WoWKB_UnknownZones[zoneNameToConvert] = 0
    end

    return zoneNameToConvert
end

function WoWKB_ConvertZoneNameToMapNotesKey(zoneNameToConvert)
    for i,zoneTable in WoWKB_SortedPairs(WoWKB_ZoneIdentifiers) do
        if zoneNameToConvert == zoneTable.z then
            if zoneTable.k == nil then
                return nil
            else
                return "WM "..zoneTable.k
            end
        end
    end

    -- We leave zone names we don't know about (due to a patch, GetZoneText/GetRealZoneText
    -- weirdness, etc.) intact and we will convert them in a future version
    if type(zoneNameToConvert) == "string" and zoneNameToConvert ~= "" then
        WoWKB_UnknownZones[zoneNameToConvert] = 0
    end

    return nil
end

function WoWKB_ConvertZoneIdentifierToName(zoneIdentifierToConvert)
    if WoWKB_ZoneIdentifiers[zoneIdentifierToConvert] ~= nil then
        return WoWKB_ZoneIdentifiers[zoneIdentifierToConvert].z
    end

    -- A not-yet-converted or invalid zoneIdentifier was passed to this function.  We just
    -- pass it through and hope for the best.  In all likelihood it won't be recognized by whatever
    -- is asking (its probably a bad zone name from GetZoneText, etc.)
    if type(zoneIdentifierToConvert) == "number" or
        (type(zoneIdentifierToConvert) == "string" and zoneIdentifierToConvert ~= "") then
        WoWKB_UnknownZones[zoneIdentifierToConvert] = 0
    end

    return zoneIdentifierToConvert
end

function WoWKB_CartographerDeleteNotesByName(name)
    for zone in pairs(WoWKB_CartographerNotes) do
        if zone ~= "version" then
            for zone, x, y, icon, db, data in Cartographer_Notes:IterateNearbyNotes(zone, 0, 0, nil, "WoWKB") do
                if name == nil or name == data.title then
                    Cartographer_Notes:DeleteNote(zone, x, y)
                end
            end            
        end
    end
end

function WoWKB_ScrollFrameButtonOnMouseUp(self, button)
    local scrollFrameButtonName = getglobal("WoWKB_ScrollFrameButton"..self:GetID().."Name")
    local scrollFrameButtonDescription = getglobal("WoWKB_ScrollFrameButton"..self:GetID().."Description")
    local scrollFrameButtonLevel = getglobal("WoWKB_ScrollFrameButton"..self:GetID().."Level")
    local scrollFrameButtonRarity = getglobal("WoWKB_ScrollFrameButton"..self:GetID().."Rarity")
    local scrollFrameButtonZone = getglobal("WoWKB_ScrollFrameButton"..self:GetID().."Zone")
    local scrollFrameButtonCoords = getglobal("WoWKB_ScrollFrameButton"..self:GetID().."Coords")
    local name = scrollFrameButtonName:GetText()
    local description = scrollFrameButtonDescription:GetText()
    if description == nil then
        description = ""
    end
    local level = scrollFrameButtonLevel:GetText()
    local rarity = scrollFrameButtonRarity:GetText()
    local zone = scrollFrameButtonZone:GetText()
    local coords = scrollFrameButtonCoords:GetText()

    if button == "LeftButton" then
        if IsShiftKeyDown() and ChatFrame1EditBox:IsVisible() then
            if description == "" then
                ChatFrame1EditBox:Insert(name.." : "..TEXT(WOWKB_LEVEL).." "..level..
                                        " : "..rarity.." : "..zone.." : "..coords)
            else
                ChatFrame1EditBox:Insert(name.." : "..description.." : "..TEXT(WOWKB_LEVEL).." "..level..
                                        " : "..rarity.." : "..zone.." : "..coords)
            end
        else
            if WoWKB_CompatibleMapNotesLoaded() then
                WoWKB_AddMapNotes(name, description, zone)
            end

            if WoWKB_CompatibleCartographerLoaded() then
                WoWKB_AddCartographerNotes(name, description, zone)
            end

            if not WoWKB_CompatibleMapNotesLoaded() and not WoWKB_CompatibleCartographerLoaded() then
                WoWKB_InfoBarShowError(format(TEXT(WOWKB_NOTES_NOT_FOUND), zone))
            end
        end
    elseif button == "RightButton" then
        if IsShiftKeyDown() and IsControlKeyDown() then
            -- delete entry from database
            local zoneIdentifier = WoWKB_ConvertZoneNameToIdentifier(zone)
            WoWKB_Data[name][zoneIdentifier] = nil
            WoWKB_Data = WoWKB_RemoveNamesWithNoZones(WoWKB_Data)
            PlaySound("Deathbind Sound")
            WoWKB_DisplayMessage(format(TEXT(WOWKB_REMOVED_FROM_DATABASE), name, zone))
            WoWKB_Search(WoWKB_State.LastSearch, true)
        else
            if WoWKB_CompatibleMapNotesLoaded() then
                MapNotes_DeleteNotesByCreatorAndName(TEXT(BINDING_HEADER_WOWKB), name)
            end

            if WoWKB_CompatibleCartographerLoaded() then
                WoWKB_CartographerDeleteNotesByName(name)
            end

            if not WoWKB_CompatibleMapNotesLoaded() and not WoWKB_CompatibleCartographerLoaded() then
                WoWKB_InfoBarShowError(format(TEXT(WOWKB_NOTES_NOT_FOUND), zone))
            else
                PlaySound("igMiniMapClose")
            end
        end
    end
end

-- returns centerx, centery, centerInfo2, bounds[]
function WoWKB_GetCoordsAndInfo2(name, zone)
    local zoneIdentifier = WoWKB_ConvertZoneNameToIdentifier(zone)
    local entry = WoWKB_Data[name][zoneIdentifier]
    local coordString, dx, dy, centerx, centery = WoWKB_GetCoordString(entry)

    local centerInfo2 = TEXT(WOWKB_NOTES_CENTER).." ("..centerx..", "..centery..")"

    centerx = centerx/100
    centery = centery/100

    local bounds = {}
    local coordSets = {
        [1] = { n = TEXT(WOWKB_NOTES_NW_BOUND), x = 4, y = 1, },
        [2] = { n = TEXT(WOWKB_NOTES_NE_BOUND), x = 2, y = 1, },
        [3] = { n = TEXT(WOWKB_NOTES_SE_BOUND), x = 2, y = 3, },
        [4] = { n = TEXT(WOWKB_NOTES_SW_BOUND), x = 4, y = 3, }, }

    -- calculate bounding box if the range in x or y is 3 map units or more
    if (dx >= 300 or dy >= 300) then
        for i,coordSet in WoWKB_SortedPairs(coordSets) do
            local boundX = entry[coordSet.x]/10000
            local boundY = entry[coordSet.y]/10000
            local printx1 = WoWKB_RoundAndScale(entry[coordSet.x])
            local printy1 = WoWKB_RoundAndScale(entry[coordSet.y])
            local boundInfo2 = coordSet.n.." ("..printx1..", "..printy1..")"
            bounds[i] = { x = boundX, y = boundY, info2 = boundInfo2 }
        end
    else
        return centerx, centery, centerInfo2, nil
    end

    return centerx, centery, centerInfo2, bounds
end

-- k<WM Alterac> x<0.62> y<0.62> t<WoWKB Note 1> i1<Info 1> i2<Info 2> cr<WoWKB> i<5> tf<3> i1f<4> i2f<5> mn<1>
function WoWKB_AddMapNotes(name, description, zone)
    local mapNotesKey = WoWKB_ConvertZoneNameToMapNotesKey(zone)
    
    if mapNotesKey == nil then
        WoWKB_InfoBarShowError(format(TEXT(WOWKB_NO_NOTES_ZONE), zone))
        return
    end

    if not WoWKB_CompatibleMapNotesLoaded() or mapNotesKey == nil then
        return
    end

    local icon = WoWKB_NextMapNoteIcon % 5 + 1
    WoWKB_NextMapNoteIcon = WoWKB_NextMapNoteIcon + 1

    local centerx, centery, centerInfo2, bounds
    centerx, centery, centerInfo2, bounds = WoWKB_GetCoordsAndInfo2(name, zone)

    -- add center point
    local msg = WoWKB_CreateMapNotesMessage(mapNotesKey, centerx, centery,
                                            name, description, centerInfo2,
                                            icon, 6, 7, 2, true)
    if msg ~= "" then
        if WoWKB_State.OneMiniNote and WoWKB_State.CreateMiniNotes then
            MapNotes_ClearMiniNotesByCreator(BINDING_HEADER_WOWKB)
        end

        PlaySound("MapPing")
        MapNotes_GetNoteBySlashCommand(msg)
    end

    -- add bounding box if the range in x or y is 3 map units or more (checked in WoWKB_GetCoordsAndInfo2)
    -- and the option is enabled
    if bounds ~= nil and WoWKB_State.CreateMapNotesBoundingBox then
        local prevPoint = bounds[4]
        local linesToToggle = {}
        
        for i,thisPoint in ipairs(bounds) do
            local msg = WoWKB_CreateMapNotesMessage(mapNotesKey, thisPoint.x, thisPoint.y, name,
                                                    description, thisPoint.info2, icon+5, 6, 7, 2, false)
            if msg ~= "" and MapNotes_GetNoteBySlashCommand(msg) then
                table.insert(linesToToggle, { k = mapNotesKey,
                                              x1 = thisPoint.x, y1 = thisPoint.y,
                                              x2 = prevPoint.x, y2 = prevPoint.y })
            end
            prevPoint = thisPoint
        end

        for i,line in pairs(linesToToggle) do
            MapNotes_ToggleLine(line.k, line.x1, line.y1, line.x2, line.y2)
        end
    end
end

function WoWKB_AddCartographerNotes(name, description, zone)
    if not WoWKB_CompatibleCartographerLoaded() then
        return
    end

    local centerx, centery, centerInfo2 = WoWKB_GetCoordsAndInfo2(name, zone)

    local icon = WoWKB_NextMapNoteIcon % 6 + 1
    WoWKB_NextMapNoteIcon = WoWKB_NextMapNoteIcon + 1

    Cartographer_Notes:SetNote(zone, centerx, centery, WoWKB_CartographerIcons[icon], "WoWKB",
                               "title", name, "titleR", 0.42, "titleG", 0.47, "titleB", 0.87,
                               "info", description, "infoR", 0.25, "infoG", 0.35, "infoB", 0.66,
                               "info2", centerInfo2, "info2R", 0.87, "info2G", 0.06, "info2B", 0.0)
    Cartographer_Notes:RefreshMap()
    PlaySound("MapPing")
end

function WoWKB_CreateMapNotesMessage(mapNotesKey, x, y, name, info1, info2,
                                     icon, nameColor, info1Color, info2Color, miniNote)
    if mapNotesKey ~= nil and x >= 0 and x <= 1 and y >= 0 and y <= 1
            and name ~= nil and name ~= "" and info1 ~= nil and info2 ~= nil and icon >= 0
            and icon <= 9 and nameColor >= 0 and nameColor <= 9 and info1Color >= 0
            and info1Color <= 9 and info2Color >= 0 and info2Color <= 9 then
        local createMiniNote = "0"

        if WoWKB_State.CreateMiniNotes and miniNote then
            createMiniNote = "1"
        end

        return "k<"..mapNotesKey.."> x<"..x.."> y<"..y.."> t<"..name.."> i1<"
                    ..info1.."> i2<"..info2.."> cr<"..BINDING_HEADER_WOWKB.."> i<"..icon
                    .."> tf<"..nameColor.."> i1f<"..info1Color.."> i2f<"..info2Color
                    .."> mn<"..createMiniNote..">"
    else
        assert(false, "nil or invalid parameter to CreateMapNotesMessage!")
    end
end

function WoWKB_RemoveNamesWithNoZones(table)
    local temp = {}

    for name,zoneTable in pairs(table) do
        local zoneCount = 0

        for zone in pairs(zoneTable) do
            zoneCount = zoneCount + 1
        end

        if zoneCount ~= 0 then
            temp[name] = {}
            temp[name] = table[name]
        end
    end

    return temp
end

function WoWKB_ToggleFrame(frame)
    if frame:IsVisible() then
        frame:Hide()
    else
        frame:Show()
    end
end

function WoWKB_ToggleShowOnlyLocalNPCs()
    WoWKB_State.ShowOnlyLocalNPCs = not WoWKB_State.ShowOnlyLocalNPCs

    if WoWKB_State.ShowOnlyLocalNPCs then
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
    end

    WoWKB_Search()
end

function WoWKB_SearchEditBoxOnEscapePressed()
    WoWKB_SearchEditBox:SetText(WoWKB_State.LastSearch)
    WoWKB_SearchEditBox:ClearFocus()
end

function WoWKB_SearchEditBoxOnEnterPressed()
    PlaySound("MONEYFRAMEOPEN")
    WoWKB_Search(WoWKB_SearchEditBox:GetText())
    WoWKB_SearchEditBox:ClearFocus()
end

function WoWKB_SearchEditBoxOnEditFocusGained()
    WoWKB_SearchEditBox:SetText("")
end

function WoWKB_OnEnter(header, anchor, wrap, ...)
    assert(header ~= nil and anchor ~= nil and wrap ~= nil, "ERROR: nil arguments passed to WoWKB_OnEnter!")

    WoWKB_Tooltip:ClearLines()
    local xOffset, yOffset
    if string.find(anchor,"TOP",1,true) ~= nil then
        yOffset = -5
    elseif string.find(anchor,"BOTTOM",1,true) ~= nil then
        yOffset = 5
    end

    if string.find(anchor,"RIGHT",1,true) ~= nil then
        xOffset = -5
    elseif string.find(anchor,"LEFT",1,true) ~= nil then
        xOffset = 5
    end

    WoWKB_Tooltip:SetOwner(this, anchor, xOffset, yOffset)
    WoWKB_Tooltip:SetText(header, 0.2, 0.5, 1, 1)
    for i,string in ipairs({...}) do
        WoWKB_Tooltip:AddLine(string, 1, 1, 1, wrap)
    end
    WoWKB_Tooltip:Show()
end

function WoWKB_ScrollFrameSort(sortBy, fromClick)
    if fromClick then
        if WoWKB_State.SortBy == sortBy then
            WoWKB_State.ReverseSort = not WoWKB_State.ReverseSort
        else
            WoWKB_State.ReverseSort = false
        end
    end

    WoWKB_State.SortBy = sortBy

    WoWKB_CurrentZone = WoWKB_ConvertZoneNameToIdentifier(WoWKB_GetRealZoneText())
    WoWKB_GetPlayerCoords()

    if WoWKB_State.ReverseSort then
        table.sort(WoWKB_SearchResults, WoWKB_ReverseComparator)
    else
        table.sort(WoWKB_SearchResults, WoWKB_ForwardComparator)
    end
end

function WoWKB_ReverseComparator(a, b)
    return WoWKB_ForwardComparator(b, a)
end

function WoWKB_ForwardComparator(a, b)
    if a == nil then
        return false
    elseif b == nil then
        return true
    elseif WoWKB_State.SortBy == "WoWKB_HeadingName" then
        return tostring(a[1]) < tostring(b[1])
    elseif WoWKB_State.SortBy == "WoWKB_HeadingDescription" then
        return tostring(WoWKB_Data[a[1]][a[2]][5]) < tostring(WoWKB_Data[b[1]][b[2]][5])
    elseif WoWKB_State.SortBy == "WoWKB_HeadingLevel" then
        return WoWKB_Data[a[1]][a[2]][6] < WoWKB_Data[b[1]][b[2]][6]
    elseif WoWKB_State.SortBy == "WoWKB_HeadingRarity" then
        return WoWKB_Data[a[1]][a[2]][8] < WoWKB_Data[b[1]][b[2]][8]
    elseif WoWKB_State.SortBy == "WoWKB_HeadingZone" then
        return tostring(WoWKB_ConvertZoneIdentifierToName(a[2])) <
            tostring(WoWKB_ConvertZoneIdentifierToName(b[2]))
    elseif WoWKB_State.SortBy == "WoWKB_HeadingCoords" then
        return WoWKB_SortCoords(a, b)
    else
        return false
    end
end

function WoWKB_SortCoords(a, b)
    if b[2] ~= WoWKB_CurrentZone and a[2] == WoWKB_CurrentZone then
        return true
    elseif a[2] ~= WoWKB_CurrentZone and b[2] == WoWKB_CurrentZone then
        return false
    elseif a[2] ~= WoWKB_CurrentZone and b[2] ~= WoWKB_CurrentZone then
        return false
    else
        local aCoords = WoWKB_Data[a[1]][a[2]]
        local adx = aCoords[2] - aCoords[4]
        local ady = aCoords[3] - aCoords[1]
        local ax = aCoords[4] + adx/2
        local ay = aCoords[1] + ady/2
        local inA = false
        local inB = false

        -- consider being inside bounding box as closer than proximity to center
        if aCoords[2]>WoWKB_PlayerX and aCoords[4]<WoWKB_PlayerX and
            aCoords[3]>WoWKB_PlayerY and aCoords[1]<WoWKB_PlayerY then
            inA = true
        end

        local bCoords = WoWKB_Data[b[1]][b[2]]
        local bdx = bCoords[2] - bCoords[4]
        local bdy = bCoords[3] - bCoords[1]
        local bx = bCoords[4] + bdx/2
        local by = bCoords[1] + bdy/2
        
        -- consider being inside bounding box as closer than proximity to center
        if bCoords[2]>WoWKB_PlayerX and bCoords[4]<WoWKB_PlayerX and
            bCoords[3]>WoWKB_PlayerY and bCoords[1]<WoWKB_PlayerY then
            inB = true
        end

        -- note these aren't the actual distances (you need to take the
        -- square root for that) but we can safely compare them to one
        -- another knowing that if a < b then a^2 < b^2 as well
        local da = (WoWKB_PlayerX - ax)^2 + (WoWKB_PlayerY - ay)^2
        local db = (WoWKB_PlayerX - bx)^2 + (WoWKB_PlayerY - by)^2
        
        if da < db then
            return inA or not inB
        else
            return inA and not inB
        end
    end
end

function WoWKB_GetRealZoneText()
    local zoneText = GetRealZoneText()

    if zoneText == nil or type(zoneText) == "number" or zoneText == "" then
        return ""
    else
        return zoneText
    end
end

WoWKB_Help = {}
WoWKB_Help[1] =
        "You can use the following commands to perform a search (ommiting search term "..
        "will list all records in the database):\n\n"..

        "|c00ffff00/wowkb|r |c0000ffff[search term]|r\n"..
        "or\n"..
        "|c00ffff00/wkb|r |c0000ffff[search term]|r\n\n"..

        "The results are color-coded based on your location:\n"..
        "|c0000ff00Green|r - Within the min/max range the NPC/mob was seen\n"..
        "|c00ffff00Yellow|r - In the same zone as the NPC/mob\n"..
        "|c00ff0000Red|r - In a different zone than the NPC/mob"
WoWKB_Help[2] =
        "There are two different formats for the coordinates listed after the name and "..
        "description of the NPC/mob.\n\n"..

        "(XX.XX, YY.YY) - This form means the range is less than three map units which "..
        "generally means the NPC/mob stays in the same spot or you "..
        "haven't seen it very many times. The X and Y coordinates are "..
        "expressed to the nearest 1/100th of a map unit.\n\n"..

        "(xx-XX), (yy-YY) - This form means the range is greater than or equal to three "..
        "map units and expresses the X and Y coordinates as a range "..
        "from min x to max X and min y to max Y.\n\n"


function WoWKB_OnVerticalScroll(self, offset)
    FauxScrollFrame_OnVerticalScroll(self, offset, WOWKB_SCROLL_FRAME_BUTTON_HEIGHT, WoWKB_UpdateScrollFrame)
end
