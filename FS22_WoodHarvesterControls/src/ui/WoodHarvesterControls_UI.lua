--
-- Mod: WoodHarvesterControls
-- Author: Bargon Mods
-- Email: bargonmods@gmail.com
-- Date: 10/01/2023
-- Version: 1.2.0.0
-- 
WoodHarvesterControls_UI = {}
local WoodHarvesterControls_UI_mt = Class(WoodHarvesterControls_UI, ScreenElement)

-- constants
WoodHarvesterControls_UI.MAX_LENGTH = 3000 -- cm
WoodHarvesterControls_UI.MAX_DIAMETER = 100 -- cm
WoodHarvesterControls_UI.MAX_FEEDING_SPEED = 6 -- cm
WoodHarvesterControls_UI.MIN_FEEDING_SPEED = 1 -- cm
WoodHarvesterControls_UI.FEEDING_SPEED_FACTOR = 0.001
WoodHarvesterControls_UI.LENGTH_FACTOR = 0.01

-- xml elements
WoodHarvesterControls_UI.CONTROLS = {"yesButton", "noButton", "automaticWithCutButtonSetting", "automaticTiltUpSetting",
                                     "automaticOpenSetting", "grabOnCutSetting", "numberOfAssortmentsSetting",
                                     "minDiameter1Value", "minDiameter1", "buckingLength1Value", "buckingLength1",
                                     "minDiameter2Value", "minDiameter2", "buckingLength2Value", "buckingLength2",
                                     "minDiameter3Value", "minDiameter3", "buckingLength3Value", "buckingLength3",
                                     "buckingLength4Value", "buckingLength4", "autoProgramFeedingSetting",
                                     "autoProgramFellingCutSetting", "autoProgramBuckingCutSetting",
                                     "automaticWithCloseButtonSetting", "lengthPreset1Value", "lengthPreset2Value",
                                     "lengthPreset3Value", "lengthPreset4Value", "sawModeSetting",
                                     "automaticFeedSetting", "breakingDistanceValue", "slowFeedingTiltedUpSetting",
                                     "feedingSpeedValue", "slowFeedingSpeedValue", "tiltDownOnFellingCutSetting",
                                     "tiltUpWithOpenButtonSetting", "tiltUpDelayValue", "repeatLengthPresetSetting",
                                     "registerSoundSetting", "maxRemovingLengthValue", "rotatorModeSetting",
                                     "rotatorForceValue", "rotatorThresholdValue", "tiltMaxAngleValue",
                                     "allSplitTypeSetting"}

function WoodHarvesterControls_UI:new(modName)
    local self = DialogElement.new(nil, WoodHarvesterControls_UI_mt)

    self:registerControls(WoodHarvesterControls_UI.CONTROLS)

    self.vehicle = nil
    self.modName = modName
    self.i18n = g_i18n.modEnvironments[self.modName]

    return self
end

function WoodHarvesterControls_UI:delete()
    -- delete
end

function WoodHarvesterControls_UI:setVehicle(vehicle)
    self.vehicle = vehicle
end

function WoodHarvesterControls_UI:onOpen()
    WoodHarvesterControls_UI:superClass().onOpen(self)

    -- easy controls
    self.automaticWithCutButtonSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                                 self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.automaticTiltUpSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                          self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.automaticOpenSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                        self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.grabOnCutSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                    self.i18n:getText("ui_WoodHarvesterControls_off")})

    -- bucking system
    self.numberOfAssortmentsSetting:setTexts({"1", "2", "3", "4"})

    -- automatic program
    self.autoProgramFeedingSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_press"),
                                             self.i18n:getText("ui_WoodHarvesterControls_hold")})

    self.autoProgramFellingCutSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_press"),
                                                self.i18n:getText("ui_WoodHarvesterControls_hold"),
                                                self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.autoProgramBuckingCutSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_press"),
                                                self.i18n:getText("ui_WoodHarvesterControls_hold"),
                                                self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.automaticWithCloseButtonSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                                   self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.automaticFeedSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                        self.i18n:getText("ui_WoodHarvesterControls_off")})

    -- rotator options
    self.rotatorModeSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_free"),
                                      self.i18n:getText("ui_WoodHarvesterControls_fixed"),
                                      self.i18n:getText("ui_WoodHarvesterControls_physical")})

    -- saw options
    self.sawModeSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_automatic"),
                                  self.i18n:getText("ui_WoodHarvesterControls_semiautomatic"),
                                  self.i18n:getText("ui_WoodHarvesterControls_manual")})

    -- length presets
    self.repeatLengthPresetSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                             self.i18n:getText("ui_WoodHarvesterControls_off")})

    -- feeding options
    self.slowFeedingTiltedUpSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                              self.i18n:getText("ui_WoodHarvesterControls_off")})

    -- tilt options
    self.tiltDownOnFellingCutSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                               self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.tiltUpWithOpenButtonSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                               self.i18n:getText("ui_WoodHarvesterControls_off")})

    -- user preferences
    self.registerSoundSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                        self.i18n:getText("ui_WoodHarvesterControls_off")})

    self.allSplitTypeSetting:setTexts({self.i18n:getText("ui_WoodHarvesterControls_on"),
                                       self.i18n:getText("ui_WoodHarvesterControls_off")})

    self:updateValues()
end

function WoodHarvesterControls_UI:updateValues()
    local whSpec = self.vehicle.spec_woodHarvester

    -- easy controls
    self.automaticWithCutButtonSetting:setState(whSpec.autoProgramWithCut and 1 or 2)

    if whSpec.cutReleasedComponentJoint ~= nil then
        self.automaticTiltUpSetting:setState(whSpec.automaticTiltUp and 1 or 2)
        self.automaticTiltUpSetting:setDisabled(false)
    else
        self.automaticTiltUpSetting:setDisabled(true)
        self.automaticTiltUpSetting:setState(2)
    end

    if whSpec.grabAnimation.name ~= nil then
        self.automaticOpenSetting:setState(whSpec.automaticOpen and 1 or 2)
        self.automaticOpenSetting:setDisabled(false)
    else
        self.automaticOpenSetting:setDisabled(true)
        self.automaticOpenSetting:setState(2)
    end

    if whSpec.cutAttachReferenceNode ~= nil and whSpec.cutAttachNode ~= nil then
        self.grabOnCutSetting:setState(whSpec.grabOnCut and 1 or 2)
        self.grabOnCutSetting:setDisabled(false)
    else
        self.grabOnCutSetting:setDisabled(true)
        self.grabOnCutSetting:setState(2)
    end

    -- bucking system
    self.numberOfAssortmentsSetting:setState(whSpec.numberOfAssortments)

    for i = 1, 4 do
        -- m to cm
        if self["minDiameter" .. i .. "Value"] ~= nil then
            self["minDiameter" .. i .. "Value"]:setText(tostring(MathUtil.round(
                whSpec.bucking[i].minDiameter / WoodHarvesterControls_UI.LENGTH_FACTOR)))
        end
        if self["buckingLength" .. i .. "Value"] ~= nil then
            self["buckingLength" .. i .. "Value"]:setText(tostring(
                MathUtil.round(whSpec.bucking[i].length / WoodHarvesterControls_UI.LENGTH_FACTOR)))
        end
    end

    self:updateBuckingSystem()

    -- automatic program
    self.autoProgramFeedingSetting:setState(whSpec.autoProgramFeeding)
    self.autoProgramFellingCutSetting:setState(whSpec.autoProgramFellingCut)
    self.autoProgramBuckingCutSetting:setState(whSpec.autoProgramBuckingCut)
    self.automaticWithCloseButtonSetting:setState(whSpec.autoProgramWithClose and 1 or 2)
    self.automaticFeedSetting:setState(whSpec.automaticFeedingOption and 1 or 2)
    self:updateAutomaticFeeding()

    -- rotator options
    if whSpec.cutReleasedComponentJoint2 ~= nil then
        self.rotatorModeSetting:setState(whSpec.rotatorMode)
        self.rotatorModeSetting:setDisabled(false)
    else
        self.rotatorModeSetting:setDisabled(true)
        self.rotatorModeSetting:setState(2)
    end

    self.rotatorForceValue:setText(tostring(whSpec.rotatorRotLimitForceLimit))
    self.rotatorThresholdValue:setText(tostring(math.deg(whSpec.rotatorThreshold)))
    self:updateRotatorMode()

    -- saw options
    self.sawModeSetting:setState(whSpec.sawMode)

    -- length presets
    for i = 1, 4 do
        self["lengthPreset" .. i .. "Value"]:setText(tostring(
            MathUtil.round(whSpec["lengthPreset" .. i] / WoodHarvesterControls_UI.LENGTH_FACTOR)))
    end
    self.repeatLengthPresetSetting:setState(whSpec.repeatLengthPreset and 1 or 2)

    -- feeding options
    self.breakingDistanceValue:setText(tostring(MathUtil.round(whSpec.breakingDistance /
                                                                   WoodHarvesterControls_UI.LENGTH_FACTOR)))

    if whSpec.cutReleasedComponentJoint ~= nil then
        self.slowFeedingTiltedUpSetting:setState(whSpec.slowFeedingTiltedUp and 1 or 2)
        self.slowFeedingTiltedUpSetting:setDisabled(false)
    else
        self.slowFeedingTiltedUpSetting:setDisabled(true)
        self.slowFeedingTiltedUpSetting:setState(2)
    end

    self.feedingSpeedValue:setText(tostring(whSpec.feedingSpeed / WoodHarvesterControls_UI.FEEDING_SPEED_FACTOR))
    self.slowFeedingSpeedValue:setText(tostring(whSpec.slowFeedingSpeed / WoodHarvesterControls_UI.FEEDING_SPEED_FACTOR))

    -- tilt options
    if whSpec.cutReleasedComponentJoint ~= nil then
        self.tiltDownOnFellingCutSetting:setState(whSpec.tiltDownOnFellingCut and 1 or 2)
        self.tiltDownOnFellingCutSetting:setDisabled(false)
    else
        self.tiltDownOnFellingCutSetting:setDisabled(true)
        self.tiltDownOnFellingCutSetting:setState(2)
    end

    if whSpec.cutReleasedComponentJoint ~= nil then
        self.tiltUpWithOpenButtonSetting:setState(whSpec.tiltUpWithOpenButton and 1 or 2)
        self.tiltUpWithOpenButtonSetting:setDisabled(false)
    else
        self.tiltUpWithOpenButtonSetting:setDisabled(true)
        self.tiltUpWithOpenButtonSetting:setState(2)
    end

    self.tiltUpDelayValue:setText(tostring(whSpec.tiltUpDelay))
    self:updateTiltUpDelay()

    self.tiltMaxAngleValue:setDisabled(whSpec.cutReleasedComponentJoint == nil)
    self.tiltMaxAngleValue:setText(tostring(math.deg(whSpec.tiltMaxRot)))

    -- user preferences
    self.registerSoundSetting:setState(whSpec.registerSound and 1 or 2)

    self.maxRemovingLengthValue:setText(tostring(MathUtil.round(whSpec.maxRemovingLength /
                                                                    WoodHarvesterControls_UI.LENGTH_FACTOR)))

    if whSpec.allSplitType ~= nil then
        self.allSplitTypeSetting:setState(whSpec.allSplitType and 1 or 2)
    end

end

function WoodHarvesterControls_UI:onClickOk()
    if self.vehicle == nil then
        return
    end

    local whSpec = self.vehicle.spec_woodHarvester

    local settings = {}

    local state

    -- easy controls
    settings.autoProgramWithCut = self.automaticWithCutButtonSetting:getState() == 1
    settings.automaticTiltUp = self.automaticTiltUpSetting:getState() == 1
    settings.automaticOpen = self.automaticOpenSetting:getState() == 1
    settings.grabOnCut = self.grabOnCutSetting:getState() == 1

    -- bucking system
    state = self.numberOfAssortmentsSetting:getState()
    if state <= 4 then
        settings.numberOfAssortments = state
    else
        settings.numberOfAssortments = 1
    end

    settings.bucking = {}
    for i = 1, 4 do
        settings.bucking[i] = {}
        -- bucking diameter
        settings.bucking[i].minDiameter = 0
        if self["minDiameter" .. i .. "Value"] ~= nil then
            local n = Utils.getNoNil(tonumber(self["minDiameter" .. i .. "Value"]:getText()), 0)
            settings.bucking[i].minDiameter = MathUtil.round(n) * WoodHarvesterControls_UI.LENGTH_FACTOR
        end
        -- bucking length
        settings.bucking[i].length = 1
        if self["buckingLength" .. i .. "Value"] ~= nil then
            local n = Utils.getNoNil(tonumber(self["buckingLength" .. i .. "Value"]:getText()), 0)
            settings.bucking[i].length = MathUtil.round(n) * WoodHarvesterControls_UI.LENGTH_FACTOR
        end
    end

    -- automatic program
    settings.autoProgramFeeding = self.autoProgramFeedingSetting:getState()
    settings.autoProgramFellingCut = self.autoProgramFellingCutSetting:getState()
    settings.autoProgramBuckingCut = self.autoProgramBuckingCutSetting:getState()
    settings.autoProgramWithClose = self.automaticWithCloseButtonSetting:getState() == 1
    settings.automaticFeedingOption = self.automaticFeedSetting:getState() == 1

    -- rotator options
    settings.rotatorMode = self.rotatorModeSetting:getState()

    local n = Utils.getNoNil(tonumber(self.rotatorForceValue:getText()), 0)
    settings.rotatorRotLimitForceLimit = n

    local n = Utils.getNoNil(tonumber(self.rotatorThresholdValue:getText()), 0)
    settings.rotatorThreshold = math.rad(n)

    -- saw options
    settings.sawMode = self.sawModeSetting:getState()

    -- length presets
    for i = 1, 4 do
        local n = Utils.getNoNil(tonumber(self["lengthPreset" .. i .. "Value"]:getText()), 0)
        settings["lengthPreset" .. i] = MathUtil.round(n) * WoodHarvesterControls_UI.LENGTH_FACTOR
    end

    settings.repeatLengthPreset = self.repeatLengthPresetSetting:getState() == 1

    -- feeding options
    local n = Utils.getNoNil(tonumber(self.breakingDistanceValue:getText()), 0)
    settings.breakingDistance = MathUtil.round(n) * WoodHarvesterControls_UI.LENGTH_FACTOR

    settings.slowFeedingTiltedUp = self.slowFeedingTiltedUpSetting:getState() == 1

    local n = Utils.getNoNil(tonumber(self.feedingSpeedValue:getText()), WoodHarvesterControls_UI.MIN_FEEDING_SPEED)
    settings.feedingSpeed = n * WoodHarvesterControls_UI.FEEDING_SPEED_FACTOR

    local n = Utils.getNoNil(tonumber(self.slowFeedingSpeedValue:getText()), WoodHarvesterControls_UI.MIN_FEEDING_SPEED)
    settings.slowFeedingSpeed = n * WoodHarvesterControls_UI.FEEDING_SPEED_FACTOR

    -- tilt options
    settings.tiltDownOnFellingCut = self.tiltDownOnFellingCutSetting:getState() == 1
    settings.tiltUpWithOpenButton = self.tiltUpWithOpenButtonSetting:getState() == 1

    local n = Utils.getNoNil(tonumber(self.tiltUpDelayValue:getText()), 0)
    settings.tiltUpDelay = n

    local n = Utils.getNoNil(tonumber(self.tiltMaxAngleValue:getText()), 0)
    settings.tiltMaxRot = math.rad(n)

    -- user preferences
    settings.registerSound = self.registerSoundSetting:getState() == 1

    local n = Utils.getNoNil(tonumber(self.maxRemovingLengthValue:getText()), 0)
    settings.maxRemovingLength = MathUtil.round(n) * WoodHarvesterControls_UI.LENGTH_FACTOR

    settings.allSplitType = self.allSplitTypeSetting:getState() == 1

    self.vehicle:updateSettings(settings)

    g_gui:closeDialogByName("WoodHarvesterControls_UI")
end

function WoodHarvesterControls_UI:onClickBack()
    g_gui:closeDialogByName("WoodHarvesterControls_UI")
end

function WoodHarvesterControls_UI:onClickNumberOfAssortment(state)
    self:updateBuckingSystem()
end

function WoodHarvesterControls_UI:onClickAutomaticProgramFeeding(state)
    self:updateAutomaticFeeding()
end

function WoodHarvesterControls_UI:onClickTiltUpWithOpenButton(state)
    self:updateTiltUpDelay()
end

function WoodHarvesterControls_UI:onClickRotatorMode(state)
    if state == 3 then
        g_gui:showInfoDialog({
            text = self.i18n:getText("ui_WoodHarvesterControls_rotatorModeWarning"),
            dialogType = DialogElement.TYPE_INFO
        })
    end

    self:updateRotatorMode()
end

function WoodHarvesterControls_UI:updateAutomaticFeeding()
    self.automaticFeedSetting:setDisabled(self.autoProgramFeedingSetting:getState() == 2)
end

function WoodHarvesterControls_UI:updateTiltUpDelay()
    self.tiltUpDelayValue:setDisabled(self.tiltUpWithOpenButtonSetting:getState() == 2)
end

function WoodHarvesterControls_UI:updateBuckingSystem()
    local state = self.numberOfAssortmentsSetting:getState()

    for i = 1, 4 do
        if self["buckingLength" .. i] ~= nil then
            self["buckingLength" .. i]:setDisabled(i > state)
        end
        if self["minDiameter" .. i] ~= nil then
            self["minDiameter" .. i]:setDisabled(i >= state)
        end
    end
end

function WoodHarvesterControls_UI:updateRotatorMode()
    local whSpec = self.vehicle.spec_woodHarvester
    local enabled = whSpec.cutReleasedComponentJoint2 ~= nil and self.rotatorModeSetting:getState() == 3

    self.rotatorForceValue:setDisabled(not enabled)
    self.rotatorThresholdValue:setDisabled(not enabled)
end

function WoodHarvesterControls_UI:onDiameterChanged(element, text)
    self:onNumberChangedClamp(element, text, 0, WoodHarvesterControls_UI.MAX_DIAMETER)
end

function WoodHarvesterControls_UI:onLengthChanged(element, text)
    self:onNumberChangedClamp(element, text, 0, WoodHarvesterControls_UI.MAX_LENGTH)
end

function WoodHarvesterControls_UI:onFeedingSpeedChanged(element, text)
    self:onNumberChangedClamp(element, text, WoodHarvesterControls_UI.MIN_FEEDING_SPEED,
        WoodHarvesterControls_UI.MAX_FEEDING_SPEED)
end

function WoodHarvesterControls_UI:ensurePositiveNumber(element, text)
    self:onNumberChangedClamp(element, text)
end

function WoodHarvesterControls_UI:onNumberChangedClamp(element, text, min, max)
    if min == nil then
        min = 0
    end

    if max == nil then
        max = 99999
    end

    local number = tonumber(text)

    if number == nil then
        element:setText("")
    else
        if number < min then
            element:setText(tostring(min))
        elseif number > max then
            element:setText(tostring(max))
        else
            -- This is a temporal fix to update the "sourceText" property of the "textElement" parent class 
            -- the bug can be reproduced by using the text input and the scrolling (it will restore the previous value as the sourceText is not being updated)
            element:setText(text)
        end
    end
end
