--[[
    WoWKB: A moused-over NPC/mob database

    See the README file for more information.
]]

function WoWKB_OptionsFrameInit()
    WoWKB_ShowOnlyLocalNPCsCheckButton:SetChecked(WoWKB_State.ShowOnlyLocalNPCs)
    WoWKB_ShowUpdatesCheckButton:SetChecked(WoWKB_State.ShowUpdates)
    WoWKB_BoundingBoxCheckButton:SetChecked(WoWKB_State.CreateMapNotesBoundingBox)
    WoWKB_ShowMiniMapButtonCheckButton:SetChecked(WoWKB_State.ShowMiniMapButton)
    WoWKB_CreateMiniNotesCheckButton:SetChecked(WoWKB_State.CreateMiniNotes)
    WoWKB_OneMiniNoteCheckButton:SetChecked(WoWKB_State.OneMiniNote)
end

function WoWKB_ToggleShowUpdates()
    WoWKB_State.ShowUpdates = not WoWKB_State.ShowUpdates

    if WoWKB_State.ShowUpdates then
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
    end
end

function WoWKB_ToggleBoundingBox()
    WoWKB_State.CreateMapNotesBoundingBox = not WoWKB_State.CreateMapNotesBoundingBox

    if WoWKB_State.CreateMapNotesBoundingBox then
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
    end
end

function WoWKB_ToggleShowMiniMapButton()
    WoWKB_State.ShowMiniMapButton = not WoWKB_State.ShowMiniMapButton

    if WoWKB_State.ShowMiniMapButton then
        WoWKB_MiniMapButtonFrame:Show()
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        WoWKB_MiniMapButtonFrame:Hide()
        PlaySound("igMainMenuOptionCheckBoxOff")
    end
end

function WoWKB_ToggleCreateMiniNotes()
    WoWKB_State.CreateMiniNotes = not WoWKB_State.CreateMiniNotes

    if WoWKB_State.CreateMiniNotes then
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
    end
end

function WoWKB_ToggleOneMiniNote()
    WoWKB_State.OneMiniNote = not WoWKB_State.OneMiniNote

    if WoWKB_State.OneMiniNote then
        PlaySound("igMainMenuOptionCheckBoxOn")
    else
        PlaySound("igMainMenuOptionCheckBoxOff")
    end
end

function WoWKB_Options_OnHide()
    if(MYADDONS_ACTIVE_OPTIONSFRAME == this) then
        ShowUIPanel(myAddOnsFrame)
    end
end
