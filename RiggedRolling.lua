-- Initialize saved variable table if it doesn't exist
RiggedRollingSaved = RiggedRollingSaved or { isVisible = true }

-- Create the main frame
local frame = CreateFrame("Frame", "RiggedRollingFrame", UIParent, "BackdropTemplate")
frame:SetSize(150, 200) -- (width, height)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Set the backdrop
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:SetBackdropBorderColor(0, 0, 0)

-- Title text
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -5)
title:SetText("Rig Rolling")
title:SetTextColor(1, 0, 0)
title:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
title:SetShadowOffset(1, -1)

-- Close button
local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 5, 5)
closeButton:SetScript("OnClick", function()
    frame:Hide()
    RiggedRollingSaved.isVisible = false  -- Save visibility state
end)

-- Input boxes and labels
local inputBoxWidth = 55
local inputBoxHeight = 30
local labelOffset = 1
local boxSpacing = 10

-- Left input box (for the lower bound of the range)
local leftInputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
leftInputBox:SetSize(inputBoxWidth, inputBoxHeight)
leftInputBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
leftInputBox:SetAutoFocus(false)
leftInputBox:SetMaxLetters(6)
leftInputBox:SetNumeric(true)
leftInputBox:SetText("1") -- Default value

-- Label for the left input box
local leftLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
leftLabel:SetPoint("BOTTOM", leftInputBox, "TOP", 0, labelOffset)
leftLabel:SetText("Min")
leftLabel:SetTextColor(1, 1, 1)
leftLabel:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
leftLabel:SetShadowOffset(1, -1)

-- Right input box (for the upper bound of the range)
local rightInputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
rightInputBox:SetSize(inputBoxWidth, inputBoxHeight)
rightInputBox:SetPoint("LEFT", leftInputBox, "RIGHT", boxSpacing, 0)
rightInputBox:SetAutoFocus(false)
rightInputBox:SetMaxLetters(6)
rightInputBox:SetNumeric(true)
rightInputBox:SetText("100") -- Default value

-- Label for the right input box
local rightLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
rightLabel:SetPoint("BOTTOM", rightInputBox, "TOP", 0, labelOffset)
rightLabel:SetText("Max")
rightLabel:SetTextColor(1, 1, 1)
rightLabel:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
rightLabel:SetShadowOffset(1, -1)

-- Dash label between input boxes
local dashLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
dashLabel:SetPoint("CENTER", leftInputBox, "CENTER", inputBoxWidth + boxSpacing / 2, 0)
dashLabel:SetTextColor(0, 1, 1)

-- Original input box (for the user's entered number)
local inputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
inputBox:SetSize(100, inputBoxHeight)
inputBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 25, -110)
inputBox:SetAutoFocus(false)
inputBox:SetMaxLetters(6)
inputBox:SetNumeric(true)

-- Label for the original input box
local inputLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
inputLabel:SetPoint("BOTTOM", inputBox, "TOP", 0, labelOffset)
inputLabel:SetText("Roll")
inputLabel:SetTextColor(0, 1, 0)
inputLabel:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
inputLabel:SetShadowOffset(1, -1)

-- Create a texture for the dice instead of a button
local diceTexture = frame:CreateTexture(nil, "OVERLAY")
diceTexture:SetSize(inputBoxWidth, inputBoxHeight)
diceTexture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 50, 20)
diceTexture:SetTexture("Interface\\AddOns\\RiggedRolling\\Textures\\dice.png")

-- Function to handle texture click
diceTexture:SetScript("OnMouseDown", function(self)
    local number = inputBox:GetText()
    local minRoll = tonumber(leftInputBox:GetText())
    local maxRoll = tonumber(rightInputBox:GetText())
    local playerName = UnitName("player")

    -- Validate input
    if number ~= "" and minRoll and maxRoll and minRoll < maxRoll then
        local roll = math.random(minRoll, maxRoll)
        local message = string.format("|cffffff00%s rolls %s (%d-%d)|r", playerName, number, minRoll, maxRoll)
        print(message)
    else
        print("|cffff0000Please enter a valid number and range.|r")
    end
end)

-- Mouse over effects for dice texture
diceTexture:SetScript("OnEnter", function(self)
    self:SetAlpha(0.8)
end)

diceTexture:SetScript("OnLeave", function(self)
    self:SetAlpha(1)
end)

-- Slash command to toggle frame visibility
SLASH_RIGGEDROLLING1 = "/rr"
SlashCmdList["RIGGEDROLLING"] = function()
    if frame:IsShown() then
        frame:Hide()
        RiggedRollingSaved.isVisible = false
    else
        frame:Show()
        RiggedRollingSaved.isVisible = true
    end
end

-- Event handler to load and save visibility state
local function OnEvent(self, event)
    if event == "ADDON_LOADED" then
        frame:SetShown(RiggedRollingSaved.isVisible)
    elseif event == "PLAYER_LOGOUT" then
        RiggedRollingSaved.isVisible = frame:IsShown()
    end
end

-- Register events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:SetScript("OnEvent", OnEvent)
