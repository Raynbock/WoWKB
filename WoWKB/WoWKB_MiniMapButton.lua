--[[
    WoWKB: A moused-over NPC/mob database

    See the README file for more information.
]]

function WoWKB_MiniMapButtonOnClick()
    WoWKB_ToggleFrame(WoWKB_MainFrame)
end

function WoWKB_MiniMapButtonInit()
    if WoWKB_State.ShowMiniMapButton then
        WoWKB_MiniMapButtonFrame:Show()
    else
        WoWKB_MiniMapButtonFrame:Hide()
    end
end

function WoWKB_MiniMapButtonUpdatePosition()
    local xOffset = 54 - (78 * cos(WoWKB_State.MiniMapButtonPosition))
    local yOffset = (78 * sin(WoWKB_State.MiniMapButtonPosition)) - 55
    WoWKB_MiniMapButtonFrame:SetPoint("TOPLEFT", "Minimap", "TOPLEFT", xOffset, yOffset)
end

function WoWKB_MiniMapButtonBeingDragged()
    local xpos,ypos = GetCursorPosition()
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

    xpos = xmin-xpos/UIParent:GetScale()+70
    ypos = ypos/UIParent:GetScale()-ymin-70

    WoWKB_MiniMapButtonSetPosition(math.deg(math.atan2(ypos,xpos)))
end

function WoWKB_MiniMapButtonSetPosition(angle)
    if(angle < 0) then
        angle = angle + 360
    end

    WoWKB_State.MiniMapButtonPosition = angle
    WoWKB_MiniMapButtonUpdatePosition()
end

function WoWKB_MiniMapButtonOnEnter()
    GameTooltip:SetOwner(this, "ANCHOR_LEFT")
    GameTooltip:SetText(WOWKB_MINIMAP_BUTTON_TOOLTIP1)
    GameTooltip:AddLine(WOWKB_MINIMAP_BUTTON_TOOLTIP2)
	GameTooltipTextLeft1:SetTextColor(1, 1, 1)
    GameTooltip:Show()
end
