local _, UUF = ...

function UUF:CreateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    local PortraitTexture = unitFrame.HighLevelContainer:CreateTexture(UUF:FetchFrameName(unit) .. "_PortraitTexture", "BACKGROUND")
    PortraitTexture:SetSize(PortraitDB.Width, PortraitDB.Height)
    PortraitTexture:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
    PortraitTexture:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
    PortraitTexture.showClass = PortraitDB.UseClassPortrait

    PortraitTexture.Border = CreateFrame("Frame", UUF:FetchFrameName(unit) .. "_PortraitBorder", unitFrame.HighLevelContainer, "BackdropTemplate")
    PortraitTexture.Border:SetAllPoints(PortraitTexture)
    PortraitTexture.Border:SetBackdrop(UUF.BACKDROP)
    PortraitTexture.Border:SetBackdropColor(0,0,0,0)
    PortraitTexture.Border:SetBackdropBorderColor(0,0,0,1)

    if PortraitDB.Enabled then
        -- Create secure button overlay for left-click and/or right-click if enabled
        if PortraitDB.LeftClickTargetOnPortrait or PortraitDB.RightClickMenuOnPortrait then
            local PortraitButton = CreateFrame("Button", UUF:FetchFrameName(unit) .. "_PortraitButton", unitFrame, "SecureUnitButtonTemplate")
            PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
            -- Anchor to unitFrame (secure) using same anchor points as portrait (HighLevelContainer covers unitFrame)
            PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
            PortraitButton:RegisterForClicks("AnyUp")
            PortraitButton:SetAttribute("unit", unitFrame.unit)
            if PortraitDB.LeftClickTargetOnPortrait then
                PortraitButton:SetAttribute("*type1", "target")
                
                -- Create highlight overlay for portrait (similar to mouseover indicator)
                local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
                if MouseoverDB and MouseoverDB.Enabled then
                    local PortraitHighlight = CreateFrame("Frame", nil, PortraitTexture.Border, "BackdropTemplate")
                    -- Set highlight to 25% of portrait height (anchored at bottom)
                    local portraitHeight = PortraitDB.Height
                    local highlightHeight = portraitHeight * 0.25
                    PortraitHighlight:SetPoint("BOTTOMLEFT", PortraitTexture, "BOTTOMLEFT", 0, 0)
                    PortraitHighlight:SetPoint("BOTTOMRIGHT", PortraitTexture, "BOTTOMRIGHT", 0, 0)
                    PortraitHighlight:SetPoint("TOPLEFT", PortraitTexture, "BOTTOMLEFT", 0, highlightHeight)
                    PortraitHighlight:SetPoint("TOPRIGHT", PortraitTexture, "BOTTOMRIGHT", 0, highlightHeight)
                    
                    if MouseoverDB.Style == "BORDER" then
                        PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                        PortraitHighlight:SetBackdropColor(0,0,0,0)
                        PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                    elseif MouseoverDB.Style == "GRADIENT" then
                        PortraitHighlight:SetBackdrop({
                            bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                            edgeFile = nil,
                            tile = false, tileSize = 0, edgeSize = 0,
                            insets = { left = 0, right = 0, top = 0, bottom = 0 },
                        })
                        PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                        PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                    else
                        PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                        PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                        PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                    end
                    
                    PortraitHighlight:Hide()
                    PortraitHighlight:SetFrameLevel(PortraitTexture.Border:GetFrameLevel() + 1)
                    PortraitButton.PortraitHighlight = PortraitHighlight
                    
                    -- Store reference to unitFrame for tooltip
                    PortraitButton.__owner = unitFrame
                    
                    -- Set OnEnter/OnLeave for tooltip and highlight
                    PortraitButton:SetScript("OnEnter", function()
                        UnitFrame_OnEnter(unitFrame)
                        if PortraitButton.PortraitHighlight then
                            PortraitButton.PortraitHighlight:Show()
                        end
                    end)
                    PortraitButton:SetScript("OnLeave", function()
                        UnitFrame_OnLeave(unitFrame)
                        if PortraitButton.PortraitHighlight then
                            PortraitButton.PortraitHighlight:Hide()
                        end
                    end)
                else
                    -- Store reference to unitFrame for tooltip
                    PortraitButton.__owner = unitFrame
                    -- Set tooltip even if highlight is disabled
                    PortraitButton:SetScript("OnEnter", function() UnitFrame_OnEnter(unitFrame) end)
                    PortraitButton:SetScript("OnLeave", function() UnitFrame_OnLeave(unitFrame) end)
                end
            end
            if PortraitDB.RightClickMenuOnPortrait then
                PortraitButton:SetAttribute("*type2", "togglemenu")
            end
            PortraitButton:SetFrameLevel(unitFrame.HighLevelContainer:GetFrameLevel() + 1)
            PortraitButton:EnableMouse(true)
            PortraitTexture.PortraitButton = PortraitButton
        end
        unitFrame.Portrait = PortraitTexture
        unitFrame.Portrait:Show()
        if PortraitTexture.PortraitButton then
            PortraitTexture.PortraitButton:Show()
        end
    else
        if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
        PortraitTexture:Hide()
        PortraitTexture.Border:Hide()
        if PortraitTexture.PortraitButton then
            PortraitTexture.PortraitButton:Hide()
        end
    end

    return PortraitTexture
end

function UUF:UpdateUnitPortrait(unitFrame, unit)
    local PortraitDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Portrait

    if PortraitDB.Enabled then
        unitFrame.Portrait = unitFrame.Portrait or UUF:CreateUnitPortrait(unitFrame, unit)

        -- Only enable element if the frame is fully initialized (has the element system)
        if unitFrame.EnableElement and not unitFrame:IsElementEnabled("Portrait") then 
            unitFrame:EnableElement("Portrait") 
        end

        if unitFrame.Portrait then
            unitFrame.Portrait:ClearAllPoints()
            unitFrame.Portrait:SetSize(PortraitDB.Width, PortraitDB.Height)
            unitFrame.Portrait:SetPoint(PortraitDB.Layout[1], unitFrame.HighLevelContainer, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
            unitFrame.Portrait:SetTexCoord((PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5, (PortraitDB.Zoom or 0) * 0.5, 1 - (PortraitDB.Zoom or 0) * 0.5)
            unitFrame.Portrait.showClass = PortraitDB.UseClassPortrait
            unitFrame.Portrait:Show()
            unitFrame.Portrait.Border:Show()
            
            -- Update or create secure button overlay for left-click and/or right-click
            if PortraitDB.LeftClickTargetOnPortrait or PortraitDB.RightClickMenuOnPortrait then
                if not unitFrame.Portrait.PortraitButton then
                    local PortraitButton = CreateFrame("Button", UUF:FetchFrameName(unit) .. "_PortraitButton", unitFrame, "SecureUnitButtonTemplate")
                    PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
                    -- Anchor to unitFrame (secure) using same anchor points as portrait (HighLevelContainer covers unitFrame)
                    PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    PortraitButton:RegisterForClicks("AnyUp")
                    PortraitButton:SetAttribute("unit", unitFrame.unit)
                    if PortraitDB.LeftClickTargetOnPortrait then
                        PortraitButton:SetAttribute("*type1", "target")
                    end
                    if PortraitDB.RightClickMenuOnPortrait then
                        PortraitButton:SetAttribute("*type2", "togglemenu")
                    end
                    PortraitButton:SetFrameLevel(unitFrame.HighLevelContainer:GetFrameLevel() + 1)
                    PortraitButton:EnableMouse(true)
                    unitFrame.Portrait.PortraitButton = PortraitButton
                    
                    -- Store reference to unitFrame for tooltip
                    PortraitButton.__owner = unitFrame
                    
                    -- Set up hooks if left-click is enabled
                    if PortraitDB.LeftClickTargetOnPortrait then
                        local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
                        if MouseoverDB and MouseoverDB.Enabled then
                            -- Create highlight overlay
                            local PortraitHighlight = CreateFrame("Frame", nil, unitFrame.Portrait.Border, "BackdropTemplate")
                            local portraitHeight = PortraitDB.Height
                            local highlightHeight = portraitHeight * 0.25
                            PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
                            PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
                            PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
                            PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
                            
                            if MouseoverDB.Style == "BORDER" then
                                PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                PortraitHighlight:SetBackdropColor(0,0,0,0)
                                PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                            elseif MouseoverDB.Style == "GRADIENT" then
                                PortraitHighlight:SetBackdrop({
                                    bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                                    edgeFile = nil,
                                    tile = false, tileSize = 0, edgeSize = 0,
                                    insets = { left = 0, right = 0, top = 0, bottom = 0 },
                                })
                                PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                            else
                                PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                            end
                            
                            PortraitHighlight:Hide()
                            PortraitHighlight:SetFrameLevel(unitFrame.Portrait.Border:GetFrameLevel() + 1)
                            PortraitButton.PortraitHighlight = PortraitHighlight
                            
                            -- Set OnEnter/OnLeave for tooltip and highlight
                            PortraitButton:SetScript("OnEnter", function()
                                UnitFrame_OnEnter(unitFrame)
                                if PortraitButton.PortraitHighlight then
                                    PortraitButton.PortraitHighlight:Show()
                                end
                            end)
                            PortraitButton:SetScript("OnLeave", function()
                                UnitFrame_OnLeave(unitFrame)
                                if PortraitButton.PortraitHighlight then
                                    PortraitButton.PortraitHighlight:Hide()
                                end
                            end)
                        else
                            -- Set tooltip even if highlight is disabled
                            PortraitButton:SetScript("OnEnter", function() UnitFrame_OnEnter(unitFrame) end)
                            PortraitButton:SetScript("OnLeave", function() UnitFrame_OnLeave(unitFrame) end)
                        end
                    end
                else
                    unitFrame.Portrait.PortraitButton:ClearAllPoints()
                    unitFrame.Portrait.PortraitButton:SetSize(PortraitDB.Width, PortraitDB.Height)
                    -- Anchor to unitFrame (secure) using same anchor points as portrait (HighLevelContainer covers unitFrame)
                    unitFrame.Portrait.PortraitButton:SetPoint(PortraitDB.Layout[1], unitFrame, PortraitDB.Layout[2], PortraitDB.Layout[3], PortraitDB.Layout[4])
                    unitFrame.Portrait.PortraitButton:SetAttribute("unit", unitFrame.unit)
                    -- Update attributes based on current settings
                    if PortraitDB.LeftClickTargetOnPortrait then
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type1", "target")
                        
                        -- Update or create highlight overlay
                        local MouseoverDB = UUF.db.profile.Units[UUF:GetNormalizedUnit(unit)].Indicators.Mouseover
                        if MouseoverDB and MouseoverDB.Enabled then
                            if not unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                local PortraitHighlight = CreateFrame("Frame", nil, unitFrame.Portrait.Border, "BackdropTemplate")
                                -- Set highlight to 25% of portrait height (anchored at bottom)
                                local portraitHeight = PortraitDB.Height
                                local highlightHeight = portraitHeight * 0.25
                                PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
                                PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
                                PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
                                PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
                                
                                if MouseoverDB.Style == "BORDER" then
                                    PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    PortraitHighlight:SetBackdropColor(0,0,0,0)
                                    PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                elseif MouseoverDB.Style == "GRADIENT" then
                                    PortraitHighlight:SetBackdrop({
                                        bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                                        edgeFile = nil,
                                        tile = false, tileSize = 0, edgeSize = 0,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 },
                                    })
                                    PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                else
                                    PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                end
                                
                                PortraitHighlight:Hide()
                                PortraitHighlight:SetFrameLevel(unitFrame.Portrait.Border:GetFrameLevel() + 1)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight = PortraitHighlight
                                
                                -- Store reference to unitFrame for tooltip
                                unitFrame.Portrait.PortraitButton.__owner = unitFrame
                                
                                -- Set OnEnter/OnLeave for tooltip and highlight
                                unitFrame.Portrait.PortraitButton:SetScript("OnEnter", function()
                                    UnitFrame_OnEnter(unitFrame)
                                    if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                        unitFrame.Portrait.PortraitButton.PortraitHighlight:Show()
                                    end
                                end)
                                unitFrame.Portrait.PortraitButton:SetScript("OnLeave", function()
                                    UnitFrame_OnLeave(unitFrame)
                                    if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                        unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                                    end
                                end)
                            else
                                -- Update highlight style if it exists
                                -- Set highlight to 25% of portrait height (anchored at bottom)
                                local portraitHeight = PortraitDB.Height
                                local highlightHeight = portraitHeight * 0.25
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:ClearAllPoints()
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("BOTTOMLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, 0)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("BOTTOMRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, 0)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("TOPLEFT", unitFrame.Portrait, "BOTTOMLEFT", 0, highlightHeight)
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:SetPoint("TOPRIGHT", unitFrame.Portrait, "BOTTOMRIGHT", 0, highlightHeight)
                                if MouseoverDB.Style == "BORDER" then
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropColor(0,0,0,0)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropBorderColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                elseif MouseoverDB.Style == "GRADIENT" then
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdrop({
                                        bgFile = "Interface\\AddOns\\UnhaltedUnitFrames\\Media\\Textures\\Gradient.png",
                                        edgeFile = nil,
                                        tile = false, tileSize = 0, edgeSize = 0,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 },
                                    })
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                else
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdrop(UUF.BACKDROP)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropColor(MouseoverDB.Colour[1], MouseoverDB.Colour[2], MouseoverDB.Colour[3], MouseoverDB.HighlightOpacity)
                                    unitFrame.Portrait.PortraitButton.PortraitHighlight:SetBackdropBorderColor(0,0,0,0)
                                end
                            end
                        elseif unitFrame.Portrait.PortraitButton.PortraitHighlight then
                            -- Hide highlight if mouseover indicator is disabled
                            unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                        end
                        -- Always ensure OnEnter/OnLeave hooks are set when left-click is enabled
                        -- (they may have been removed when left-click was previously disabled)
                        unitFrame.Portrait.PortraitButton:SetScript("OnEnter", function()
                            UnitFrame_OnEnter(unitFrame)
                            if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:Show()
                            end
                        end)
                        unitFrame.Portrait.PortraitButton:SetScript("OnLeave", function()
                            UnitFrame_OnLeave(unitFrame)
                            if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                                unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                            end
                        end)
                    else
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type1", nil)
                        if unitFrame.Portrait.PortraitButton.PortraitHighlight then
                            unitFrame.Portrait.PortraitButton.PortraitHighlight:Hide()
                        end
                        -- Remove OnEnter/OnLeave hooks from portrait button when left-click is disabled
                        unitFrame.Portrait.PortraitButton:SetScript("OnEnter", nil)
                        unitFrame.Portrait.PortraitButton:SetScript("OnLeave", nil)
                        -- Restore OnEnter/OnLeave hooks to main frame
                        -- HookScript is safe to call multiple times - it just adds hooks
                        unitFrame:HookScript("OnEnter", UnitFrame_OnEnter)
                        unitFrame:HookScript("OnLeave", UnitFrame_OnLeave)
                    end
                    if PortraitDB.RightClickMenuOnPortrait then
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type2", "togglemenu")
                    else
                        unitFrame.Portrait.PortraitButton:SetAttribute("*type2", nil)
                    end
                end
                unitFrame.Portrait.PortraitButton:Show()
                -- Remove left-click targeting from main frame if on portrait
                if PortraitDB.LeftClickTargetOnPortrait then
                    unitFrame:SetAttribute("*type1", nil)
                    -- Update mouseover indicator to prevent tooltip (it uses SetScript which will override HookScript hooks)
                    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
                else
                    unitFrame:SetAttribute("*type1", "target")
                    -- Update mouseover indicator to restore tooltip
                    UUF:UpdateUnitMouseoverIndicator(unitFrame, unit)
                end
                -- Remove right-click menu from main frame if on portrait
                if PortraitDB.RightClickMenuOnPortrait then
                    unitFrame:SetAttribute("*type2", nil)
                else
                    unitFrame:SetAttribute("*type2", "togglemenu")
                end
            else
                if unitFrame.Portrait.PortraitButton then
                    unitFrame.Portrait.PortraitButton:Hide()
                end
                -- Restore left-click targeting to main frame
                unitFrame:SetAttribute("*type1", "target")
                -- Restore right-click menu to main frame
                unitFrame:SetAttribute("*type2", "togglemenu")
            end
            
            unitFrame.Portrait:ForceUpdate()
        end
    else
        if not unitFrame.Portrait then return end
        if unitFrame:IsElementEnabled("Portrait") then unitFrame:DisableElement("Portrait") end
        if unitFrame.Portrait then
            unitFrame.Portrait:Hide()
            unitFrame.Portrait.Border:Hide()
            if unitFrame.Portrait.PortraitButton then
                unitFrame.Portrait.PortraitButton:Hide()
            end
            -- Restore left-click targeting to main frame when portrait is disabled
            unitFrame:SetAttribute("*type1", "target")
            -- Restore right-click menu to main frame when portrait is disabled
            unitFrame:SetAttribute("*type2", "togglemenu")
            unitFrame.Portrait = nil
        end
    end
end
