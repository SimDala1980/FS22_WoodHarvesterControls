--
-- Mod: WoodHarvesterControls
-- Author: Bargon Mods
-- Email: bargonmods@gmail.com
-- Date: 10/01/2023
-- Version: 1.2.0.0
--
WoodHarvesterControls = {}

local WHC = WoodHarvesterControls

WHC.AUTOMATIC = 1
WHC.SEMIAUTOMATIC = 2
WHC.MANUAL = 3

WHC.SAW_AUTO = 1
WHC.SAW_SENSOR = 2
WHC.SAW_MANUAL = 3

WHC.ON = 1
WHC.OFF = 2

WHC.AUTO_PUSH = 1
WHC.AUTO_HOLD = 2
WHC.AUTO_OFF = 3

WHC.STOP_BUTTON_ID = 0
WHC.AUTOMATIC_PROGRAM_BUTTON_ID = 1

WHC.TILT_TYPE_TOGGLE = 0
WHC.TILT_TYPE_DOWN = 1
WHC.TILT_TYPE_UP = 2

WHC.GRAB_TYPE_TOGGLE = 0
WHC.GRAB_TYPE_CLOSE = 1
WHC.GRAB_TYPE_OPEN = 2

WHC.DEFAULT_TILT_DOWN_FORCE = 0
WHC.DEFAULT_TILT_DOWN_DAMPING = 1

WHC.ROTATOR_FREE = 1
WHC.ROTATOR_FIXED = 2
WHC.ROTATOR_PHYSICAL = 3

WHC.MIN_BREAKING_SPEED = 0.0005
WHC.MIN_DISTANCE_TO_GROUND = 0.3

WoodHarvesterControls.actions = {{
    name = InputAction.IMPLEMENT_EXTRA2,
    priority = GS_PRIO_HIGH,
    text = g_i18n:getText("action_saw"),
    triggerUp = true
}, {
    name = InputAction.IMPLEMENT_EXTRA3,
    priority = GS_PRIO_HIGH,
    text = g_i18n:getText("action_openWoodHarvesterControlsMenu")
}, {
    name = "WOOD_HARVESTER_CONTROLS_SAW",
    priority = GS_PRIO_HIGH,
    text = g_i18n:getText("action_saw"),
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_TURN_ON_OFF_HEAD",
    priority = GS_PRIO_HIGH
}, {
    name = "WOOD_HARVESTER_CONTROLS_TILT_UP_DOWN_HEAD",
    priority = GS_PRIO_NORMAL
}, {
    name = "WOOD_HARVESTER_CONTROLS_TILT_UP_HEAD",
    priority = GS_PRIO_NORMAL,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_TILT_DOWN_HEAD",
    priority = GS_PRIO_NORMAL,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_OPEN_HEAD",
    priority = GS_PRIO_VERY_HIGH,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_CLOSE_HEAD",
    priority = GS_PRIO_VERY_HIGH,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_OPEN_CLOSE_HEAD",
    priority = GS_PRIO_HIGH,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_FORWARD_FEED",
    priority = GS_PRIO_NORMAL,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_BACKWARD_FEED",
    priority = GS_PRIO_NORMAL,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_SLOW_FORWARD_FEED",
    priority = GS_PRIO_NORMAL,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_SLOW_BACKWARD_FEED",
    priority = GS_PRIO_NORMAL,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_AUTOMATIC_PROGRAM",
    priority = GS_PRIO_HIGH,
    triggerUp = true
}, {
    name = "WOOD_HARVESTER_CONTROLS_STOP",
    priority = GS_PRIO_HIGH
}, {
    name = "WOOD_HARVESTER_CONTROLS_LENGTH_PRESET_1",
    priority = GS_PRIO_NORMAL
}, {
    name = "WOOD_HARVESTER_CONTROLS_LENGTH_PRESET_2",
    priority = GS_PRIO_NORMAL
}, {
    name = "WOOD_HARVESTER_CONTROLS_MENU",
    priority = GS_PRIO_HIGH
}}

function WoodHarvesterControls.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(TurnOnVehicle, specializations)
end

function WoodHarvesterControls.initSpecialization()
    -- schema
    local schema = Vehicle.xmlSchema

    schema:setXMLSpecializationType("WoodHarvesterControls")
    schema:register(XMLValueType.STRING, "vehicle.woodHarvesterControls.sawAnimation#name", "Saw animation name")
    schema:register(XMLValueType.FLOAT, "vehicle.woodHarvesterControls.sawAnimation#speedScale",
        "Saw animation speed scale")
    schema:register(XMLValueType.FLOAT, "vehicle.woodHarvesterControls.sawAnimation#maxCutDiameter",
        "Max cutting diameter")

    schema:register(XMLValueType.STRING, "vehicle.woodHarvesterControls.frontGrabAnimation#name",
        "Front grab animation name")
    schema:register(XMLValueType.FLOAT, "vehicle.woodHarvesterControls.frontGrabAnimation#speedScale",
        "Front grab animation speed scale")
    schema:register(XMLValueType.STRING, "vehicle.woodHarvesterControls.backGrabAnimation#name",
        "Back grab animation name")
    schema:register(XMLValueType.FLOAT, "vehicle.woodHarvesterControls.backGrabAnimation#speedScale",
        "Back grab animation speed scale")
    schema:register(XMLValueType.STRING, "vehicle.woodHarvesterControls.rollersGrabAnimation#name",
        "Rollers grab animation name")
    schema:register(XMLValueType.FLOAT, "vehicle.woodHarvesterControls.rollersGrabAnimation#speedScale",
        "Rollers grab animation speed scale")
    schema:setXMLSpecializationType()

    local schemaSavegame = Vehicle.xmlSchemaSavegame

    -- easy controls
    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#autoProgramWithCut"):format(g_woodHarvesterControlsModName),
        "Automatic program with cut button")
    schemaSavegame:register(XMLValueType.BOOL, ("vehicles.vehicle(?).%s.woodHarvesterControls#automaticTiltUp"):format(
        g_woodHarvesterControlsModName), "Automatic Tilt Up")
    schemaSavegame:register(XMLValueType.BOOL, ("vehicles.vehicle(?).%s.woodHarvesterControls#automaticOpen"):format(
        g_woodHarvesterControlsModName), "Automatic Open")
    schemaSavegame:register(XMLValueType.BOOL, ("vehicles.vehicle(?).%s.woodHarvesterControls#grabOnCut"):format(
        g_woodHarvesterControlsModName), "Grab tree after cut")

    -- bucking system
    schemaSavegame:register(XMLValueType.INT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#numberOfAssortments"):format(g_woodHarvesterControlsModName),
        "Number of assortments")
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls.buckingSystem(?)#minDiameter"):format(
            g_woodHarvesterControlsModName), "Minimun Diameter (cm)")
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls.buckingSystem(?)#length"):format(g_woodHarvesterControlsModName),
        "Cutting Length (cm)")

    -- automatic program
    schemaSavegame:register(XMLValueType.INT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#autoProgramFeeding"):format(g_woodHarvesterControlsModName),
        "Automatic Program Feeding")
    schemaSavegame:register(XMLValueType.INT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#autoProgramFellingCut"):format(g_woodHarvesterControlsModName),
        "Automatic Program Felling Cut")
    schemaSavegame:register(XMLValueType.INT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#autoProgramBuckingCut"):format(g_woodHarvesterControlsModName),
        "Automatic Program Bucking Cut")
    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#autoProgramWithClose"):format(g_woodHarvesterControlsModName),
        "Automatic program with close button")
    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#automaticFeedingOption"):format(g_woodHarvesterControlsModName),
        "Automatic feed after cut")

    -- rotator options
    schemaSavegame:register(XMLValueType.INT, ("vehicles.vehicle(?).%s.woodHarvesterControls#rotatorMode"):format(
        g_woodHarvesterControlsModName), "Rotator Mode")
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#rotatorRotLimitForceLimit"):format(g_woodHarvesterControlsModName),
        "Rotator Force")
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#rotatorThreshold"):format(g_woodHarvesterControlsModName),
        "Rotator Threshold")

    -- saw options
    schemaSavegame:register(XMLValueType.INT, ("vehicles.vehicle(?).%s.woodHarvesterControls#sawMode"):format(
        g_woodHarvesterControlsModName), "Saw mode")

    -- length presets
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls.lengthPreset(?)#length"):format(g_woodHarvesterControlsModName),
        "Length Preset (cm)")

    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#repeatLengthPreset"):format(g_woodHarvesterControlsModName),
        "Repeat length preset")

    -- feeding options
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#breakingDistance"):format(g_woodHarvesterControlsModName),
        "Breaking Distance")
    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#slowFeedingTiltedUp"):format(g_woodHarvesterControlsModName),
        "Slow feed when titled up Mode")
    schemaSavegame:register(XMLValueType.FLOAT, ("vehicles.vehicle(?).%s.woodHarvesterControls#feedingSpeed"):format(
        g_woodHarvesterControlsModName), "General feeding speed")
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#slowFeedingSpeed"):format(g_woodHarvesterControlsModName),
        "Slow feeding speed")

    -- tilt options
    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#tiltDownOnFellingCut"):format(g_woodHarvesterControlsModName),
        "Tilt down on felling cut")
    schemaSavegame:register(XMLValueType.BOOL,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#tiltUpWithOpenButton"):format(g_woodHarvesterControlsModName),
        "Tilt up with open button")
    schemaSavegame:register(XMLValueType.FLOAT, ("vehicles.vehicle(?).%s.woodHarvesterControls#tiltUpDelay"):format(
        g_woodHarvesterControlsModName), "Tilt up with open button delay")
    schemaSavegame:register(XMLValueType.FLOAT, ("vehicles.vehicle(?).%s.woodHarvesterControls#tiltMaxRot"):format(
        g_woodHarvesterControlsModName), "Max tilt angle")

    -- user preferences
    schemaSavegame:register(XMLValueType.BOOL, ("vehicles.vehicle(?).%s.woodHarvesterControls#registerSound"):format(
        g_woodHarvesterControlsModName), "Register found sounds")
    schemaSavegame:register(XMLValueType.FLOAT,
        ("vehicles.vehicle(?).%s.woodHarvesterControls#maxRemovingLength"):format(g_woodHarvesterControlsModName),
        "Max removing length")
    schemaSavegame:register(XMLValueType.BOOL, ("vehicles.vehicle(?).%s.woodHarvesterControls#allSplitType"):format(
        g_woodHarvesterControlsModName), "Support all trees")
end

function WoodHarvesterControls.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoad", WoodHarvesterControls)
    SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", WoodHarvesterControls)
end

function WoodHarvesterControls.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "detachTree", WoodHarvesterControls.detachTree)
    SpecializationUtil.registerFunction(vehicleType, "attachTree", WoodHarvesterControls.attachTree)
    SpecializationUtil.registerFunction(vehicleType, "findRegister", WoodHarvesterControls.findRegister)
    SpecializationUtil.registerFunction(vehicleType, "setDelimbStatus", WoodHarvesterControls.setDelimbStatus)
    SpecializationUtil.registerFunction(vehicleType, "handleCutEffects", WoodHarvesterControls.handleCutEffects)
    SpecializationUtil.registerFunction(vehicleType, "handleDelimbEffects", WoodHarvesterControls.handleDelimbEffects)
    SpecializationUtil.registerFunction(vehicleType, "handleRegisterSound", WoodHarvesterControls.handleRegisterSound)
    SpecializationUtil.registerFunction(vehicleType, "setAttachStatus", WoodHarvesterControls.setAttachStatus)
    SpecializationUtil.registerFunction(vehicleType, "setGrabStatus", WoodHarvesterControls.setGrabStatus)
    SpecializationUtil.registerFunction(vehicleType, "updateSettings", WoodHarvesterControls.updateSettings)
    SpecializationUtil.registerFunction(vehicleType, "attachShape", WoodHarvesterControls.attachShape)
    SpecializationUtil.registerFunction(vehicleType, "onRegisterFound", WoodHarvesterControls.onRegisterFound)
    SpecializationUtil.registerFunction(vehicleType, "lowerSaw", WoodHarvesterControls.lowerSaw)
    SpecializationUtil.registerFunction(vehicleType, "raiseSaw", WoodHarvesterControls.raiseSaw)
    SpecializationUtil.registerFunction(vehicleType, "updateRotatorMode", WoodHarvesterControls.updateRotatorMode)
    SpecializationUtil.registerFunction(vehicleType, "onCutButton", WoodHarvesterControls.onCutButton)
    SpecializationUtil.registerFunction(vehicleType, "onTiltButtons", WoodHarvesterControls.onTiltButtons)
    SpecializationUtil.registerFunction(vehicleType, "onGrabButtons", WoodHarvesterControls.onGrabButtons)
    SpecializationUtil.registerFunction(vehicleType, "onButtonPressed", WoodHarvesterControls.onButtonPressed)
    SpecializationUtil.registerFunction(vehicleType, "stopHead", WoodHarvesterControls.stopHead)
    SpecializationUtil.registerFunction(vehicleType, "runAutomaticProgram", WoodHarvesterControls.runAutomaticProgram)
end

function WoodHarvesterControls.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "cutTree", WoodHarvesterControls.cutTree)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "onUpdateTick", WoodHarvesterControls.onUpdateTick)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "findSplitShapesInRange",
        WoodHarvesterControls.findSplitShapesInRange)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "woodHarvesterSplitShapeCallback",
        WoodHarvesterControls.woodHarvesterSplitShapeCallback)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "setLastTreeDiameter",
        WoodHarvesterControls.setLastTreeDiameter)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getDoConsumePtoPower",
        WoodHarvesterControls.getDoConsumePtoPower)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanSplitShapeBeAccessed",
        WoodHarvesterControls.getCanSplitShapeBeAccessed)
end

function WoodHarvesterControls:originalOnLoad(superFunc, savegame)
    local spec = self.spec_woodHarvester

    XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.woodHarvester.delimbSound",
        "vehicle.woodHarvester.sounds.delimb") -- FS17 to FS19
    XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.woodHarvester.cutSound",
        "vehicle.woodHarvester.sounds.cut") -- FS17 to FS19
    XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.woodHarvester.treeSizeMeasure#index",
        "vehicle.woodHarvester.treeSizeMeasure#node") -- FS17 to FS19
    XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.woodHarvester.forwardingWheels.wheel(0)",
        "vehicle.woodHarvester.forwardingNodes.animationNode") -- FS17 to FS19
    XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.woodHarvester.cutParticleSystems",
        "vehicle.woodHarvester.cutEffects") -- FS17 to FS19
    XMLUtil.checkDeprecatedXMLElements(self.xmlFile, "vehicle.woodHarvester.delimbParticleSystems",
        "vehicle.woodHarvester.delimbEffects") -- FS17 to FS19

    spec.curSplitShape = nil
    spec.attachedSplitShape = nil
    spec.hasAttachedSplitShape = false
    spec.isAttachedSplitShapeMoving = false
    spec.attachedSplitShapeLastDelimbTime = 0
    spec.attachedSplitShapeX = 0
    spec.attachedSplitShapeY = 0
    spec.attachedSplitShapeZ = 0
    spec.attachedSplitShapeTargetY = 0
    spec.attachedSplitShapeLastCutY = 0
    spec.attachedSplitShapeStartY = 0
    spec.attachedSplitShapeOnlyMove = false
    spec.attachedSplitShapeOnlyMoveDelay = 0
    spec.attachedSplitShapeMoveEffectActive = false
    spec.attachedSplitShapeDelimbEffectActive = false
    spec.cutTimer = -1

    spec.lastCutEventTime = 0
    spec.cutEventCoolDownTime = 1000 -- alllow cut event only every second so on the client side there is enough time to reseive the correct state from the server

    spec.automaticCuttingEnabled = true
    spec.automaticCuttingIsDirty = false

    spec.lastTreeSize = nil
    spec.lastTreeJointPos = nil
    spec.loadedSplitShapeFromSavegame = false

    spec.cutNode = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#node", nil, self.components, self.i3dMappings)
    spec.cutMaxRadius = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#maxRadius", 1)
    spec.cutSizeY = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#sizeY", 1)
    spec.cutSizeZ = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#sizeZ", 1)
    spec.cutAttachNode = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#attachNode", nil, self.components,
        self.i3dMappings)
    spec.cutAttachReferenceNode = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#attachReferenceNode", nil,
        self.components, self.i3dMappings)
    spec.cutAttachMoveSpeed = self.xmlFile:getValue("vehicle.woodHarvester.cutNode#attachMoveSpeed", 3) * 0.001
    local cutReleasedComponentJointIndex = self.xmlFile:getValue(
        "vehicle.woodHarvester.cutNode#releasedComponentJointIndex")
    if cutReleasedComponentJointIndex ~= nil then
        spec.cutReleasedComponentJoint = self.componentJoints[cutReleasedComponentJointIndex]
        spec.cutReleasedComponentJointRotLimitX = 0
        spec.cutReleasedComponentJointRotLimitXSpeed = self.xmlFile:getValue(
            "vehicle.woodHarvester.cutNode#releasedComponentJointRotLimitXSpeed", 100) * 0.001
    end
    local cutReleasedComponentJoint2Index = self.xmlFile:getValue(
        "vehicle.woodHarvester.cutNode#releasedComponentJoint2Index")
    if cutReleasedComponentJoint2Index ~= nil then
        spec.cutReleasedComponentJoint2 = self.componentJoints[cutReleasedComponentJoint2Index]
        spec.cutReleasedComponentJoint2RotLimitX = 0
        spec.cutReleasedComponentJoint2RotLimitXSpeed = self.xmlFile:getValue(
            "vehicle.woodHarvester.cutNode#releasedComponentJointRotLimitXSpeed", 100) * 0.001
    end

    spec.headerJointTilt = {}
    if not self:loadWoodHarvesterHeaderTiltFromXML(spec.headerJointTilt, self.xmlFile,
        "vehicle.woodHarvester.headerJointTilt") then
        spec.headerJointTilt = nil
    end

    if spec.cutAttachReferenceNode ~= nil and spec.cutAttachNode ~= nil then
        spec.cutAttachHelperNode = createTransformGroup("helper")
        link(spec.cutAttachReferenceNode, spec.cutAttachHelperNode)
        setTranslation(spec.cutAttachHelperNode, 0, 0, 0)
        setRotation(spec.cutAttachHelperNode, 0, 0, 0)
    end

    spec.cutAttachDirection = 1
    spec.lastCutAttachDirection = 1

    spec.delimbNode = self.xmlFile:getValue("vehicle.woodHarvester.delimbNode#node", nil, self.components,
        self.i3dMappings)
    spec.delimbSizeX = self.xmlFile:getValue("vehicle.woodHarvester.delimbNode#sizeX", 0.1)
    spec.delimbSizeY = self.xmlFile:getValue("vehicle.woodHarvester.delimbNode#sizeY", 1)
    spec.delimbSizeZ = self.xmlFile:getValue("vehicle.woodHarvester.delimbNode#sizeZ", 1)
    spec.delimbOnCut = self.xmlFile:getValue("vehicle.woodHarvester.delimbNode#delimbOnCut", false)

    spec.cutLengthMin = self.xmlFile:getValue("vehicle.woodHarvester.cutLengths#min", 1)
    spec.cutLengthMax = self.xmlFile:getValue("vehicle.woodHarvester.cutLengths#max", 5)
    spec.cutLengthStep = self.xmlFile:getValue("vehicle.woodHarvester.cutLengths#step", 0.5)

    spec.cutLengths = self.xmlFile:getValue("vehicle.woodHarvester.cutLengths#values", nil, true)
    if spec.cutLengths == nil or #spec.cutLengths == 0 then
        spec.cutLengths = {}
        for i = spec.cutLengthMin, spec.cutLengthMax, spec.cutLengthStep do
            table.insert(spec.cutLengths, i)
        end
    else
        for i = 1, #spec.cutLengths do
            if spec.cutLengths[i] == 0 then
                spec.cutLengths[i] = math.huge
            end
        end
    end

    spec.currentCutLengthIndex = MathUtil.clamp(self.xmlFile:getValue("vehicle.woodHarvester.cutLengths#startIndex", 1),
        1, #spec.cutLengths)
    spec.currentCutLength = spec.cutLengths[spec.currentCutLengthIndex] or 1

    if self.isClient then
        spec.cutEffects = g_effectManager:loadEffect(self.xmlFile, "vehicle.woodHarvester.cutEffects", self.components,
            self, self.i3dMappings)
        spec.delimbEffects = g_effectManager:loadEffect(self.xmlFile, "vehicle.woodHarvester.delimbEffects",
            self.components, self, self.i3dMappings)
        spec.forwardingNodes = g_animationManager:loadAnimations(self.xmlFile, "vehicle.woodHarvester.forwardingNodes",
            self.components, self, self.i3dMappings)

        spec.samples = {}
        spec.samples.cut = g_soundManager:loadSampleFromXML(self.xmlFile, "vehicle.woodHarvester.sounds", "cut",
            self.baseDirectory, self.components, 0, AudioGroup.VEHICLE, self.i3dMappings, self)
        spec.samples.delimb = g_soundManager:loadSampleFromXML(self.xmlFile, "vehicle.woodHarvester.sounds", "delimb",
            self.baseDirectory, self.components, 0, AudioGroup.VEHICLE, self.i3dMappings, self)
        spec.isCutSamplePlaying = false
        spec.isDelimbSamplePlaying = false
    end

    spec.cutAnimation = {}
    spec.cutAnimation.name = self.xmlFile:getValue("vehicle.woodHarvester.cutAnimation#name")
    spec.cutAnimation.speedScale = self.xmlFile:getValue("vehicle.woodHarvester.cutAnimation#speedScale", 1)
    spec.cutAnimation.cutTime = self.xmlFile:getValue("vehicle.woodHarvester.cutAnimation#cutTime", 1)

    spec.grabAnimation = {}
    spec.grabAnimation.name = self.xmlFile:getValue("vehicle.woodHarvester.grabAnimation#name")
    spec.grabAnimation.speedScale = self.xmlFile:getValue("vehicle.woodHarvester.grabAnimation#speedScale", 1)

    spec.treeSizeMeasure = {}
    spec.treeSizeMeasure.node = self.xmlFile:getValue("vehicle.woodHarvester.treeSizeMeasure#node", nil,
        self.components, self.i3dMappings)
    spec.treeSizeMeasure.rotMaxRadius = self.xmlFile:getValue("vehicle.woodHarvester.treeSizeMeasure#rotMaxRadius", 1)
    spec.treeSizeMeasure.rotMaxAnimTime = self.xmlFile:getValue("vehicle.woodHarvester.treeSizeMeasure#rotMaxAnimTime",
        1)

    spec.warnInvalidTree = false
    spec.warnInvalidTreeRadius = false
    spec.warnInvalidTreePosition = false
    spec.warnTreeNotOwned = false

    spec.lastDiameter = 0

    spec.texts = {}
    spec.texts.actionChangeCutLength = g_i18n:getText("action_woodHarvesterChangeCutLength")
    spec.texts.woodHarvesterTiltHeader = g_i18n:getText("action_woodHarvesterTiltHeader")
    spec.texts.uiMax = g_i18n:getText("ui_max")
    spec.texts.unitMeterShort = g_i18n:getText("unit_mShort")
    spec.texts.actionCut = g_i18n:getText("action_woodHarvesterCut")
    spec.texts.warningFoldingTreeMounted = g_i18n:getText("warning_foldingTreeMounted")
    spec.texts.warningTreeTooThick = g_i18n:getText("warning_treeTooThick")
    spec.texts.warningTreeTooThickAtPosition = g_i18n:getText("warning_treeTooThickAtPosition")
    spec.texts.warningTreeTypeNotSupported = g_i18n:getText("warning_treeTypeNotSupported")
    spec.texts.warningYouDontHaveAccessToThisLand = g_i18n:getText("warning_youAreNotAllowedToCutThisTree")
    spec.texts.warningFirstTurnOnTheTool = string.format(g_i18n:getText("warning_firstTurnOnTheTool"), self.typeDesc)

    if self.loadDashboardsFromXML ~= nil then
        self:loadDashboardsFromXML(self.xmlFile, "vehicle.woodHarvester.dashboards", {
            valueTypeToLoad = "cutLength",
            valueObject = spec,
            valueFunc = function()
                if spec.currentCutLength == math.huge then
                    return 9999999
                else
                    return spec.currentCutLength * 100
                end
            end
        })

        -- self:loadDashboardsFromXML(self.xmlFile, "vehicle.woodHarvester.dashboards", {
        --     valueTypeToLoad = "curCutLength",
        --     valueObject = spec,
        --     valueFunc = function()
        --         return math.abs(spec.attachedSplitShapeStartY - spec.attachedSplitShapeY) * 100
        --     end
        -- })

        self:loadDashboardsFromXML(self.xmlFile, "vehicle.woodHarvester.dashboards", {
            valueTypeToLoad = "diameter",
            valueObject = spec,
            valueFunc = function()
                return spec.lastDiameter * 1000
            end
        })
    end
end

-- wood harvester measurement compatibility 
function WoodHarvesterControls:whmOnUpdate()
    local spec = self.spec_woodHarvester

    self:setCurrentLength((spec.currentLength * spec.cutAttachDirection) * 100)
end

function WoodHarvesterControls:onLoad(savegame)
    local spec = self.spec_woodHarvester

    -- get rotator node
    for _, movingTool in pairs(self.spec_cylindered.movingTools) do
        if movingTool.axisActionIndex == "AXIS_CRANE_TOOL2" then
            spec.rotatorMovingTool = movingTool
            spec.rotatorRotAcceleration = movingTool.rotAcceleration
            spec.rotatorInvertAxis = movingTool.invertAxis
            spec.rotatorRotSpeed = movingTool.rotSpeed
            spec.rotatorRotMax = movingTool.rotMax
            spec.rotatorRotMin = movingTool.rotMin
            spec.rotatorCurRot = movingTool.curRot
            spec.rotatorRotationAxis = movingTool.rotationAxis
            spec.rotatorNode = movingTool.node
            spec.rotatorComponentJoints = movingTool.componentJoints
            break
        end
    end

    if spec.cutReleasedComponentJoint ~= nil then
        spec.cutReleasedComponentJointRotLimitXNegative = 0
    end

    -- easy controls
    spec.autoProgramWithCut = false
    spec.automaticTiltUp = false
    spec.automaticOpen = false
    spec.grabOnCut = false
    -- bucking system
    spec.numberOfAssortments = 1;
    spec.bucking = {{
        length = 4.6,
        minDiameter = 0.40
    }, {
        length = 5.2,
        minDiameter = 0.22
    }, {
        length = 4.3,
        minDiameter = 0.16
    }, {
        length = 4,
        minDiameter = 0
    }}
    -- automatic program
    spec.autoProgramFeeding = WHC.AUTO_HOLD
    spec.autoProgramFellingCut = WHC.AUTO_HOLD
    spec.autoProgramBuckingCut = WHC.AUTO_PUSH
    spec.autoProgramWithClose = true
    spec.automaticFeedingOption = false
    -- rotator options
    spec.rotatorMode = WHC.ROTATOR_FREE
    spec.rotatorRotLimitForceLimit = 15
    spec.rotatorThreshold = 0.5236
    -- saw options
    spec.sawMode = WHC.AUTOMATIC
    -- length presets
    spec.lengthPreset1 = 3
    spec.lengthPreset2 = 4
    spec.lengthPreset3 = 5
    spec.lengthPreset4 = 6
    spec.repeatLengthPreset = false
    -- feeding options
    spec.breakingDistance = 1
    spec.slowFeedingTiltedUp = true
    spec.feedingSpeed = 0.0045
    spec.slowFeedingSpeed = 0.001
    -- tilt options
    spec.tiltDownOnFellingCut = true
    spec.tiltUpWithOpenButton = true
    spec.tiltUpDelay = 500
    spec.tiltMaxRot = 95 / 180 * math.pi
    -- user preferences
    spec.registerSound = true
    spec.maxRemovingLength = 3.5
    spec.allSplitType = true

    -- state
    spec.tempDiameter = 0
    spec.tiltControl = true
    spec.tiltDownForce = 30
    spec.tiltDownDamping = 20
    spec.tiltMaxRotDriveForce = 0.01
    spec.forcedTiltDown = false
    spec.forcedTiltUp = false
    spec.currentTiltDownForce = WHC.DEFAULT_TILT_DOWN_FORCE
    spec.currentTiltDownDamping = WHC.DEFAULT_TILT_DOWN_DAMPING

    spec.currentLength = 0
    spec.registerFound = false
    spec.automaticFeedingStarted = false
    spec.tiltedUp = WHC.isTiltSupported(self)
    spec.tiltedUpOnCut = nil
    spec.isHeadClosed = true
    spec.currentAssortmentIndex = nil
    spec.lastAssortment = nil

    spec.cutSawSpeedMultiplier = 1
    spec.sawSpeedMultiplier = 2
    spec.currentLengthPreset = 0
    spec.currentFeedingSpeed = 0
    spec.isSawOut = false
    spec.currentSawMode = nil
    spec.referenceCutDone = false
    spec.autoProgramStarted = false
    spec.autoProgramHoldTimer = -1
    spec.autoProgramTransitionTimer = -1
    spec.autoProgramTransitionTargetTime = 250
    spec.autoFeedingTimer = -1
    spec.autoFeedingDelay = 200
    spec.closeHoldTimer = -1
    spec.openHoldTimer = -1
    spec.closeHoldTargetTime = 250
    spec.playCutSound = false

    spec.lastPreset1Time = -1
    spec.lastPreset2Time = -1
    spec.doublePressPresetTime = 500

    -- override rotator force
    if self.isServer then
        if spec.cutReleasedComponentJoint2 ~= nil then
            local jointIndex = spec.cutReleasedComponentJoint2.index
            spec.rotatorOriginalRotLimitForce = self.componentJoints[jointIndex].rotLimitForceLimit[1]
        end
    end

    -- get initial forwarding nodes rotation speed
    spec.forwardingNodesSpeed = {}
    for key, forwardingAnimation in pairs(spec.forwardingNodes) do
        spec.forwardingNodesSpeed[key] = spec.forwardingNodes[key].rotSpeed
    end

    -- get head size
    spec.headHeight = 1
    if spec.cutNode and spec.delimbNode then
        local cx, cy, cz = getWorldTranslation(spec.cutNode)
        local dx, dy, dz = getWorldTranslation(spec.delimbNode)
        local distance = MathUtil.vector3Length(cx - dx, cy - dy, cz - dz)
        spec.headHeight = MathUtil.clamp(distance, 0.5, 2)
    end

    -- animations
    local sawAnimation = {}
    sawAnimation.name = self.xmlFile:getValue("vehicle.woodHarvesterControls.sawAnimation#name")
    sawAnimation.speedScale = self.xmlFile:getValue("vehicle.woodHarvesterControls.sawAnimation#speedScale", 1)
    sawAnimation.maxCutDiameter = self.xmlFile:getValue("vehicle.woodHarvesterControls.sawAnimation#maxCutDiameter", 1)

    if (sawAnimation.name ~= nil and sawAnimation.maxCutDiameter ~= nil) then
        spec.cutAnimation.name = sawAnimation.name
        spec.cutAnimation.maxCutDiameter = sawAnimation.maxCutDiameter
        spec.cutAnimation.speedScale = sawAnimation.speedScale
        spec.advancedCut = true
    end

    spec.frontGrabAnimation = {}
    spec.frontGrabAnimation.name = self.xmlFile:getValue("vehicle.woodHarvesterControls.frontGrabAnimation#name")
    spec.frontGrabAnimation.speedScale = self.xmlFile:getValue(
        "vehicle.woodHarvesterControls.frontGrabAnimation#speedScale", 1)
    spec.backGrabAnimation = {}
    spec.backGrabAnimation.name = self.xmlFile:getValue("vehicle.woodHarvesterControls.backGrabAnimation#name")
    spec.backGrabAnimation.speedScale = self.xmlFile:getValue(
        "vehicle.woodHarvesterControls.backGrabAnimation#speedScale", 1)
    spec.rollersGrabAnimation = {}
    spec.rollersGrabAnimation.name = self.xmlFile:getValue("vehicle.woodHarvesterControls.rollersGrabAnimation#name")
    spec.rollersGrabAnimation.speedScale = self.xmlFile:getValue(
        "vehicle.woodHarvesterControls.rollersGrabAnimation#speedScale", 1)

    if (spec.frontGrabAnimation.name ~= nil or spec.backGrabAnimation.name ~= nil) and spec.rollersGrabAnimation.name ~=
        nil then
        spec.advancedOpenClose = true
    end

    -- get sounds
    if self.isClient then
        if WoodHarvesterControls.registerFoundSample == nil then
            local fileName = Utils.getFilename("assets/register.ogg",
                g_currentMission.woodHarvesterControls.modDirectory)
            WoodHarvesterControls.registerFoundSample = createSample("RegisterFound")
            loadSample(WoodHarvesterControls.registerFoundSample, fileName, false)
        end

        if WoodHarvesterControls.assortmentChangedSample == nil then
            local fileName = Utils.getFilename("assets/assortment.ogg",
                g_currentMission.woodHarvesterControls.modDirectory)
            WoodHarvesterControls.assortmentChangedSample = createSample("AssortmentChanged")
            loadSample(WoodHarvesterControls.assortmentChangedSample, fileName, false)
        end

        local cutSound = g_soundManager:loadSampleFromXML(self.xmlFile, "vehicle.woodHarvesterControls.sounds", "cut",
            self.baseDirectory, self.components, 0, AudioGroup.VEHICLE, self.i3dMappings, self)

        if cutSound ~= nil then
            spec.samples.cut = cutSound
        end

        spec.samples.cutEnd = g_soundManager:loadSampleFromXML(self.xmlFile, "vehicle.woodHarvesterControls.sounds",
            "cutEnd", self.baseDirectory, self.components, 1, AudioGroup.VEHICLE, self.i3dMappings, self)

    end

    -- dashboards
    if self.loadDashboardsFromXML ~= nil then
        self:loadDashboardsFromXML(self.xmlFile, "vehicle.woodHarvester.dashboards", {
            valueTypeToLoad = "curCutLength",
            valueObject = spec,
            valueFunc = function(spec)
                return math.abs(spec.currentLength * 100)
            end
        })
    end

end

function WoodHarvesterControls:onPostLoad(savegame)
    local spec = self.spec_woodHarvester

    if savegame == nil or savegame.resetVehicles then
        return
    end

    local key = savegame.key .. "." .. g_woodHarvesterControlsModName .. ".woodHarvesterControls"

    -- easy controls
    spec.autoProgramWithCut = savegame.xmlFile:getValue(key .. "#autoProgramWithCut", spec.autoProgramWithCut)
    spec.automaticTiltUp = savegame.xmlFile:getValue(key .. "#automaticTiltUp", spec.automaticTiltUp)
    spec.automaticOpen = savegame.xmlFile:getValue(key .. "#automaticOpen", spec.automaticOpen)
    spec.grabOnCut = savegame.xmlFile:getValue(key .. "#grabOnCut", spec.grabOnCut)

    -- bucking system
    spec.numberOfAssortments = savegame.xmlFile:getValue(key .. "#numberOfAssortments", spec.numberOfAssortments)
    for i = 1, 4 do
        local toolKey = string.format("%s.buckingSystem(%d)", key, i - 1)
        spec.bucking[i].minDiameter = savegame.xmlFile:getValue(toolKey .. "#minDiameter", spec.bucking[i].minDiameter)
        spec.bucking[i].length = savegame.xmlFile:getValue(toolKey .. "#length", spec.bucking[i].length)
    end

    -- automatic program
    spec.autoProgramFeeding = savegame.xmlFile:getValue(key .. "#autoProgramFeeding", spec.autoProgramFeeding)
    spec.autoProgramFellingCut = savegame.xmlFile:getValue(key .. "#autoProgramFellingCut", spec.autoProgramFellingCut)
    spec.autoProgramBuckingCut = savegame.xmlFile:getValue(key .. "#autoProgramBuckingCut", spec.autoProgramBuckingCut)
    spec.autoProgramWithClose = savegame.xmlFile:getValue(key .. "#autoProgramWithClose", spec.autoProgramWithClose)
    spec.automaticFeedingOption = savegame.xmlFile:getValue(key .. "#automaticFeedingOption",
        spec.automaticFeedingOption)

    -- rotator options
    spec.rotatorMode = savegame.xmlFile:getValue(key .. "#rotatorMode", spec.rotatorMode)
    spec.rotatorRotLimitForceLimit = savegame.xmlFile:getValue(key .. "#rotatorRotLimitForceLimit",
        spec.rotatorRotLimitForceLimit)
    spec.rotatorThreshold = savegame.xmlFile:getValue(key .. "#rotatorThreshold", spec.rotatorThreshold)

    -- saw options
    spec.sawMode = savegame.xmlFile:getValue(key .. "#sawMode", spec.sawMode)

    -- length presets
    for i = 1, 4 do
        local toolKey = string.format("%s.lengthPreset(%d)", key, i - 1)
        spec["lengthPreset" .. i] = savegame.xmlFile:getValue(toolKey .. "#length", spec["lengthPreset" .. i])
    end
    spec.repeatLengthPreset = savegame.xmlFile:getValue(key .. "#repeatLengthPreset", spec.repeatLengthPreset)

    -- feeding options
    spec.breakingDistance = savegame.xmlFile:getValue(key .. "#breakingDistance", spec.breakingDistance)
    spec.slowFeedingTiltedUp = savegame.xmlFile:getValue(key .. "#slowFeedingTiltedUp", spec.slowFeedingTiltedUp)
    spec.feedingSpeed = savegame.xmlFile:getValue(key .. "#feedingSpeed", spec.feedingSpeed)
    spec.slowFeedingSpeed = savegame.xmlFile:getValue(key .. "#slowFeedingSpeed", spec.slowFeedingSpeed)

    -- tilt options
    spec.tiltDownOnFellingCut = savegame.xmlFile:getValue(key .. "#tiltDownOnFellingCut", spec.tiltDownOnFellingCut)
    spec.tiltUpWithOpenButton = savegame.xmlFile:getValue(key .. "#tiltUpWithOpenButton", spec.tiltUpWithOpenButton)
    spec.tiltUpDelay = savegame.xmlFile:getValue(key .. "#tiltUpDelay", spec.tiltUpDelay)
    spec.tiltMaxRot = savegame.xmlFile:getValue(key .. "#tiltMaxRot", spec.tiltMaxRot)

    -- user preferences
    spec.registerSound = savegame.xmlFile:getValue(key .. "#registerSound", spec.registerSound)
    spec.maxRemovingLength = savegame.xmlFile:getValue(key .. "#maxRemovingLength", spec.maxRemovingLength)
    spec.allSplitType = savegame.xmlFile:getValue(key .. "#allSplitType", spec.allSplitType)
end

function WoodHarvesterControls:onLoadFinished(superFunc, savegame)
    local spec = self.spec_woodHarvester
    if savegame ~= nil and not savegame.resetVehicles then
        if savegame.xmlFile:getValue(savegame.key .. ".woodHarvester#isTurnedOn", false) then
            self:setIsTurnedOn(true)
        end

        if spec.grabAnimation.name ~= nil then
            AnimatedVehicle.updateAnimationByName(self, spec.grabAnimation.name, 99999999, true)
        end

        local minY, maxY, minZ, maxZ = savegame.xmlFile:getValue(savegame.key .. ".woodHarvester#lastTreeSize")
        if minY ~= nil then
            spec.lastTreeSize = {minY, maxY, minZ, maxZ}
        end

        local x, y, z = savegame.xmlFile:getValue(savegame.key .. ".woodHarvester#lastTreeJointPos")
        if x ~= nil then
            spec.lastTreeJointPos = {x, y, z}
        end

        spec.lastCutAttachDirection = savegame.xmlFile:getValue(savegame.key .. ".woodHarvester#lastCutAttachDirection",
            spec.lastCutAttachDirection)

        if savegame.xmlFile:getValue(savegame.key .. ".woodHarvester#hasAttachedSplitShape", false) then
            if self:getIsTurnedOn() then
                self:findSplitShapesInRange(0.5, true)

                if spec.curSplitShape ~= nil and spec.curSplitShape ~= 0 then
                    spec.loadedSplitShapeFromSavegame = true
                end
            end
        end

        if self.isServer then
            self:updateRotatorMode()
        end

    end
end

function WoodHarvesterControls:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_woodHarvester

    -- easy controls
    xmlFile:setValue(key .. "#autoProgramWithCut", spec.autoProgramWithCut)
    xmlFile:setValue(key .. "#automaticTiltUp", spec.automaticTiltUp)
    xmlFile:setValue(key .. "#automaticOpen", spec.automaticOpen)
    xmlFile:setValue(key .. "#grabOnCut", spec.grabOnCut)

    -- bucking system
    xmlFile:setValue(key .. "#numberOfAssortments", spec.numberOfAssortments)
    for i = 1, 4 do
        local toolKey = string.format("%s.buckingSystem(%d)", key, i - 1)
        xmlFile:setValue(toolKey .. "#minDiameter", spec.bucking[i].minDiameter)
        xmlFile:setValue(toolKey .. "#length", spec.bucking[i].length)
    end

    -- automatic program
    xmlFile:setValue(key .. "#autoProgramFeeding", spec.autoProgramFeeding)
    xmlFile:setValue(key .. "#autoProgramFellingCut", spec.autoProgramFellingCut)
    xmlFile:setValue(key .. "#autoProgramBuckingCut", spec.autoProgramBuckingCut)
    xmlFile:setValue(key .. "#autoProgramWithClose", spec.autoProgramWithClose)
    xmlFile:setValue(key .. "#automaticFeedingOption", spec.automaticFeedingOption)

    -- rotator options
    xmlFile:setValue(key .. "#rotatorMode", spec.rotatorMode)
    xmlFile:setValue(key .. "#rotatorRotLimitForceLimit", spec.rotatorRotLimitForceLimit)
    xmlFile:setValue(key .. "#rotatorThreshold", spec.rotatorThreshold)

    -- saw options
    xmlFile:setValue(key .. "#sawMode", spec.sawMode)

    -- length presets
    for i = 1, 4 do
        local toolKey = string.format("%s.lengthPreset(%d)", key, i - 1)
        xmlFile:setValue(toolKey .. "#length", spec["lengthPreset" .. i])
    end
    xmlFile:setValue(key .. "#repeatLengthPreset", spec.repeatLengthPreset)

    -- feeding options
    xmlFile:setValue(key .. "#breakingDistance", spec.breakingDistance)
    xmlFile:setValue(key .. "#slowFeedingTiltedUp", spec.slowFeedingTiltedUp)
    xmlFile:setValue(key .. "#feedingSpeed", spec.feedingSpeed)
    xmlFile:setValue(key .. "#slowFeedingSpeed", spec.slowFeedingSpeed)

    -- tilt options
    xmlFile:setValue(key .. "#tiltDownOnFellingCut", spec.tiltDownOnFellingCut)
    xmlFile:setValue(key .. "#tiltUpWithOpenButton", spec.tiltUpWithOpenButton)
    xmlFile:setValue(key .. "#tiltUpDelay", spec.tiltUpDelay)
    xmlFile:setValue(key .. "#tiltMaxRot", spec.tiltMaxRot)

    -- user preferences
    xmlFile:setValue(key .. "#registerSound", spec.registerSound)
    xmlFile:setValue(key .. "#maxRemovingLength", spec.maxRemovingLength)
    xmlFile:setValue(key .. "#allSplitType", spec.allSplitType)
end

---
function WoodHarvesterControls:onReadStream(superFunc, streamId, connection)
    local spec = self.spec_woodHarvester
    spec.hasAttachedSplitShape = streamReadBool(streamId)
    if spec.hasAttachedSplitShape then
        local animTime = streamReadUIntN(streamId, 7) / 127
        self:setAnimationTime(spec.grabAnimation.name, animTime, true)

        self:setAnimationTime(spec.cutAnimation.name, 0, true)
    end

    -- easy controls
    spec.autoProgramWithCut = streamReadBool(streamId)
    spec.automaticTiltUp = streamReadBool(streamId)
    spec.automaticOpen = streamReadBool(streamId)
    spec.grabOnCut = streamReadBool(streamId)

    -- bucking system
    spec.numberOfAssortments = streamReadUIntN(streamId, 3)
    spec.bucking = {}
    for i = 1, 4 do
        spec.bucking[i] = {}
        spec.bucking[i].minDiameter = streamReadFloat32(streamId)
        spec.bucking[i].length = streamReadFloat32(streamId)
    end

    -- automatic program
    spec.autoProgramFeeding = streamReadUIntN(streamId, 3)
    spec.autoProgramFellingCut = streamReadUIntN(streamId, 3)
    spec.autoProgramBuckingCut = streamReadUIntN(streamId, 3)
    spec.autoProgramWithClose = streamReadBool(streamId)
    spec.automaticFeedingOption = streamReadBool(streamId)

    -- rotator options
    spec.rotatorMode = streamReadUIntN(streamId, 3)
    spec.rotatorRotLimitForceLimit = streamReadFloat32(streamId)
    spec.rotatorThreshold = streamReadFloat32(streamId)

    -- saw options
    spec.sawMode = streamReadUIntN(streamId, 3)

    -- length presets
    for i = 1, 4 do
        spec["lengthPreset" .. i] = streamReadFloat32(streamId)
    end
    spec.repeatLengthPreset = streamReadBool(streamId)

    -- feeding options
    spec.breakingDistance = streamReadFloat32(streamId)
    spec.slowFeedingTiltedUp = streamReadBool(streamId)
    spec.feedingSpeed = streamReadFloat32(streamId)
    spec.slowFeedingSpeed = streamReadFloat32(streamId)

    -- tilt options
    spec.tiltDownOnFellingCut = streamReadBool(streamId)
    spec.tiltUpWithOpenButton = streamReadBool(streamId)
    spec.tiltUpDelay = streamReadFloat32(streamId)
    spec.tiltMaxRot = streamReadFloat32(streamId)

    -- user preferences
    spec.registerSound = streamReadBool(streamId)
    spec.maxRemovingLength = streamReadFloat32(streamId)
    spec.allSplitType = streamReadBool(streamId)

end

---
function WoodHarvesterControls:onWriteStream(superFunc, streamId, connection)
    local spec = self.spec_woodHarvester
    if streamWriteBool(streamId, spec.hasAttachedSplitShape) then
        local animTime = self:getAnimationTime(spec.grabAnimation.name)
        streamWriteUIntN(streamId, animTime * 127, 7)
    end

    -- easy controls
    streamWriteBool(streamId, spec.autoProgramWithCut)
    streamWriteBool(streamId, spec.automaticTiltUp)
    streamWriteBool(streamId, spec.automaticOpen)
    streamWriteBool(streamId, spec.grabOnCut)

    -- bucking system
    streamWriteUIntN(streamId, spec.numberOfAssortments, 3)
    for i = 1, 4 do
        streamWriteFloat32(streamId, spec.bucking[i].minDiameter)
        streamWriteFloat32(streamId, spec.bucking[i].length)
    end

    -- automatic program
    streamWriteUIntN(streamId, spec.autoProgramFeeding, 3)
    streamWriteUIntN(streamId, spec.autoProgramFellingCut, 3)
    streamWriteUIntN(streamId, spec.autoProgramBuckingCut, 3)
    streamWriteBool(streamId, spec.autoProgramWithClose)
    streamWriteBool(streamId, spec.automaticFeedingOption)

    -- rotator options
    streamWriteUIntN(streamId, spec.rotatorMode, 3)
    streamWriteFloat32(streamId, spec.rotatorRotLimitForceLimit)
    streamWriteFloat32(streamId, spec.rotatorThreshold)

    -- saw options
    streamWriteUIntN(streamId, spec.sawMode, 3)

    -- length presets
    for i = 1, 4 do
        streamWriteFloat32(streamId, spec["lengthPreset" .. i])
    end
    streamWriteBool(streamId, spec.repeatLengthPreset)

    -- feeding options
    streamWriteFloat32(streamId, spec.breakingDistance)
    streamWriteBool(streamId, spec.slowFeedingTiltedUp)
    streamWriteFloat32(streamId, spec.feedingSpeed)
    streamWriteFloat32(streamId, spec.slowFeedingSpeed)

    -- tilt options
    streamWriteBool(streamId, spec.tiltDownOnFellingCut)
    streamWriteBool(streamId, spec.tiltUpWithOpenButton)
    streamWriteFloat32(streamId, spec.tiltUpDelay)
    streamWriteFloat32(streamId, spec.tiltMaxRot)

    -- user preferences
    streamWriteBool(streamId, spec.registerSound)
    streamWriteFloat32(streamId, spec.maxRemovingLength)
    streamWriteBool(streamId, spec.allSplitType)

end

---
function WoodHarvesterControls:onReadUpdateStream(superFunc, streamId, timestamp, connection)
    if connection:getIsServer() then
        local spec = self.spec_woodHarvester

        spec.currentLength = streamReadFloat32(streamId)
    end
end

---
function WoodHarvesterControls:onWriteUpdateStream(superFunc, streamId, connection, dirtyMask)
    if not connection:getIsServer() then
        local spec = self.spec_woodHarvester

        streamWriteFloat32(streamId, spec.currentLength)
    end
end

function WoodHarvesterControls:onUpdate(superFunc, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_woodHarvester

    -- Verify that the split shapes still exist (possible that someone has cut them)
    if self.isServer then
        local lostShape = false
        if spec.attachedSplitShape ~= nil then
            if not entityExists(spec.attachedSplitShape) then
                spec.attachedSplitShape = nil
                spec.attachedSplitShapeJointIndex = nil
                spec.isAttachedSplitShapeMoving = false
                spec.cutTimer = -1
                lostShape = true
            end
        elseif spec.curSplitShape ~= nil then
            if not entityExists(spec.curSplitShape) then
                spec.curSplitShape = nil
                lostShape = true
            end
        end
        if lostShape then
            self:setLastTreeDiameter(0)
            SpecializationUtil.raiseEvent(self, "onCutTree", 0)
            if g_server ~= nil then
                g_server:broadcastEvent(WoodHarvesterOnCutTreeEvent.new(self, 0), nil, nil, self)
            end
        end
    end

    if self.isServer and (spec.attachedSplitShape ~= nil or spec.curSplitShape ~= nil) then
        if spec.cutTimer > 0 then
            if spec.cutAnimation.name ~= nil then
                local targetAnimTime = spec.cutAnimation.cutTime
                if spec.advancedCut == true then
                    targetAnimTime = math.min(1.0, (spec.tempDiameter / spec.cutAnimation.maxCutDiameter) * 1.1)
                end
                if self:getAnimationTime(spec.cutAnimation.name) >= targetAnimTime then
                    spec.cutTimer = 0
                    if spec.currentSawMode == WHC.SAW_SENSOR then
                        self:raiseSaw()
                        spec.registerFound = false
                    elseif spec.currentSawMode == WHC.SAW_MANUAL then
                        if spec.advancedCut == true then
                            self:playAnimation(spec.cutAnimation.name,
                                spec.cutAnimation.speedScale * spec.sawSpeedMultiplier,
                                self:getAnimationTime(spec.cutAnimation.name), false)
                        end
                    else
                        self:raiseSaw()
                    end

                end
            else
                spec.cutTimer = math.max(spec.cutTimer - dt, 0)
            end
        end

        local readyToCut = spec.cutTimer == 0

        if readyToCut and spec.attachedSplitShape ~= nil then
            local x, y, z = localToWorld(spec.cutNode, 0, 0, 0)
            local nx, ny, nz = localDirectionToWorld(spec.cutNode, 1, 0, 0)
            local yx, yy, yz = localDirectionToWorld(spec.cutNode, 0, 1, 0)
            local minY, maxY, minZ, maxZ = testSplitShape(spec.attachedSplitShape, x, y, z, nx, ny, nz, yx, yy, yz,
                spec.cutSizeY, spec.cutSizeZ)
            if minY == nil then
                spec.cutTimer = -1
                readyToCut = false
            end
        end

        -- cut
        if readyToCut then
            spec.cutTimer = -1

            spec.currentLength = 0

            local x, y, z = getWorldTranslation(spec.cutNode)
            local nx, ny, nz = localDirectionToWorld(spec.cutNode, 1, 0, 0)
            local yx, yy, yz = localDirectionToWorld(spec.cutNode, 0, 1, 0)
            local newTreeCut = false

            if WHC.isStandingTreeAttached(self) or WHC.isStandingTreeInRange(self) then
                newTreeCut = true
            end

            local currentSplitShape
            if spec.attachedSplitShapeJointIndex ~= nil then
                removeJoint(spec.attachedSplitShapeJointIndex)
                spec.attachedSplitShapeJointIndex = nil
                currentSplitShape = spec.attachedSplitShape
                spec.attachedSplitShape = nil
            else
                currentSplitShape = spec.curSplitShape
                spec.curSplitShape = nil
            end

            -- remember split type name for later (achievement)
            local splitTypeName = ""
            local splitType = g_splitTypeManager:getSplitTypeByIndex(getSplitType(currentSplitShape))
            if splitType ~= nil then
                splitTypeName = splitType.name
            end

            if spec.delimbOnCut then
                local xD, yD, zD = getWorldTranslation(spec.delimbNode)
                local nxD, nyD, nzD = localDirectionToWorld(spec.delimbNode, 1, 0, 0)
                local yxD, yyD, yzD = localDirectionToWorld(spec.delimbNode, 0, 1, 0)
                local vx, vy, vz = x - xD, y - yD, z - zD
                local sizeX = MathUtil.vector3Length(vx, vy, vz)
                removeSplitShapeAttachments(currentSplitShape, xD + vx * 0.5, yD + vy * 0.5, zD + vz * 0.5, nxD, nyD,
                    nzD, yxD, yyD, yzD, sizeX * 0.7 + spec.delimbSizeX, spec.delimbSizeY, spec.delimbSizeZ)
            end

            spec.attachedSplitShape = nil
            spec.curSplitShape = nil
            spec.prevSplitShape = currentSplitShape

            if not spec.loadedSplitShapeFromSavegame then
                g_currentMission:removeKnownSplitShape(currentSplitShape)
                self.shapeBeingCut = currentSplitShape
                self.shapeBeingCutIsTree = getRigidBodyType(currentSplitShape) == RigidBodyType.STATIC
                splitShape(currentSplitShape, x, y, z, nx, ny, nz, yx, yy, yz, spec.cutSizeY, spec.cutSizeZ,
                    "woodHarvesterSplitShapeCallback", self)
                g_treePlantManager:removingSplitShape(currentSplitShape)
            else
                self:woodHarvesterSplitShapeCallback(currentSplitShape, false, true, unpack(spec.lastTreeSize))
            end

            if spec.attachedSplitShape == nil then
                -- in this case the diameter is not set to 0 so WoodHarvesterMeasurement can register the cutted log
                SpecializationUtil.raiseEvent(self, "onCutTree", 0)
                if g_server ~= nil then
                    g_server:broadcastEvent(WoodHarvesterOnCutTreeEvent.new(self, 0), nil, nil, self)
                end
            else
                if spec.delimbOnCut then
                    local xD, yD, zD = getWorldTranslation(spec.delimbNode)
                    local nxD, nyD, nzD = localDirectionToWorld(spec.delimbNode, 1, 0, 0)
                    local yxD, yyD, yzD = localDirectionToWorld(spec.delimbNode, 0, 1, 0)
                    local vx, vy, vz = x - xD, y - yD, z - zD
                    local sizeX = MathUtil.vector3Length(vx, vy, vz)
                    removeSplitShapeAttachments(spec.attachedSplitShape, xD + vx * 3, yD + vy * 3, zD + vz * 3, nxD,
                        nyD, nzD, yxD, yyD, yzD, sizeX * 3 + spec.delimbSizeX, spec.delimbSizeY, spec.delimbSizeZ)
                end
            end

            if newTreeCut then
                local stats = g_currentMission:farmStats(self:getActiveFarm())

                -- increase tree cut counter for achievements
                local cutTreeCount = stats:updateStats("cutTreeCount", 1)

                g_achievementManager:tryUnlock("CutTreeFirst", cutTreeCount)
                g_achievementManager:tryUnlock("CutTree", cutTreeCount)

                -- update the types of trees cut so far (achievement)
                if splitTypeName ~= "" then
                    stats:updateTreeTypesCut(splitTypeName)
                end
            end
        end

        -- delimb
        if spec.attachedSplitShape ~= nil and spec.isAttachedSplitShapeMoving then

            -- compute translated distance
            local translatedDistance = spec.currentFeedingSpeed
            if (not spec.manualFeedingForward and not spec.manualFeedingBackward) then
                local distanceToTarget = math.abs(spec.attachedSplitShapeY - spec.attachedSplitShapeTargetY)
                if (distanceToTarget < spec.breakingDistance) then
                    translatedDistance = MathUtil.lerp(WHC.MIN_BREAKING_SPEED, translatedDistance,
                        distanceToTarget / spec.breakingDistance)
                end
            end
            translatedDistance = translatedDistance * dt

            -- prevent feeding back into the ground when handling standing trees
            if WHC.isStandingTreeAttached(self) and spec.manualFeedingBackward then
                local _, cutNodeHeight, _ = localToWorld(spec.cutNode, -WHC.MIN_DISTANCE_TO_GROUND, 0, 0)

                local limitHeight = cutNodeHeight - translatedDistance

                local terrainHeight = getTerrainHeightAtWorldPos(g_currentMission.terrainRootNode,
                    getWorldTranslation(spec.cutNode))

                if limitHeight < terrainHeight then
                    if cutNodeHeight < terrainHeight then
                        translatedDistance = 0
                    else
                        translatedDistance = math.min(cutNodeHeight - terrainHeight, translatedDistance)
                    end
                end
            end

            if spec.delimbNode ~= nil then
                local x, y, z = getWorldTranslation(spec.delimbNode)
                local nx, ny, nz = localDirectionToWorld(spec.delimbNode, 1, 0, 0)
                local yx, yy, yz = localDirectionToWorld(spec.delimbNode, 0, 1, 0)

                removeSplitShapeAttachments(spec.attachedSplitShape, x, y, z, nx, ny, nz, yx, yy, yz,
                    spec.delimbSizeX + translatedDistance * 2, spec.delimbSizeY, spec.delimbSizeZ)
            end

            if spec.cutNode ~= nil and spec.attachedSplitShapeJointIndex ~= nil then
                local x, y, z = getWorldTranslation(spec.cutAttachReferenceNode)
                local nx, ny, nz = localDirectionToWorld(spec.cutAttachReferenceNode, 0, 1, 0)
                local lengthToBottom, lengthToTop = getSplitShapePlaneExtents(spec.attachedSplitShape, x, y, z, nx, ny,
                    nz)

                if lengthToTop == nil or lengthToTop <= 0.1 or lengthToBottom == nil or lengthToBottom <=
                    -spec.headHeight then

                    -- end of tree
                    removeJoint(spec.attachedSplitShapeJointIndex)
                    spec.attachedSplitShapeJointIndex = nil
                    spec.attachedSplitShape = nil

                    self:setDelimbStatus(0, false, false)
                    self:setLastTreeDiameter(0)

                    SpecializationUtil.raiseEvent(self, "onCutTree", 0)
                    if g_server ~= nil then
                        g_server:broadcastEvent(WoodHarvesterOnCutTreeEvent.new(self, 0), nil, nil, self)
                    end
                else
                    spec.registerFound = false
                    local registerFound = false

                    if spec.manualFeedingForward or spec.manualFeedingBackward then
                        -- manual feeding
                        if spec.manualFeedingForward then
                            spec.attachedSplitShapeY = spec.attachedSplitShapeY + translatedDistance *
                                                           spec.cutAttachDirection
                        elseif spec.manualFeedingBackward then
                            spec.attachedSplitShapeY = spec.attachedSplitShapeY - translatedDistance *
                                                           spec.cutAttachDirection
                        end
                    elseif spec.attachedSplitShapeY < spec.attachedSplitShapeTargetY then
                        -- feeding forward
                        local changedRegister = false
                        if spec.currentAssortmentIndex ~= nil then
                            local assortment = spec.bucking[spec.currentAssortmentIndex]

                            if spec.currentAssortmentIndex ~= spec.numberOfAssortments and assortment ~= nil and
                                assortment.minDiameter ~= nil and assortment.minDiameter > spec.lastDiameter then
                                self:findRegister()
                                changedRegister = true
                            end
                        end

                        if changedRegister == false then
                            spec.attachedSplitShapeY = spec.attachedSplitShapeY + translatedDistance
                            if spec.attachedSplitShapeY >= spec.attachedSplitShapeTargetY then
                                registerFound = true
                            end
                        end
                    else
                        -- feeding backward
                        spec.attachedSplitShapeY = spec.attachedSplitShapeY - translatedDistance
                        if spec.attachedSplitShapeY <= spec.attachedSplitShapeTargetY then
                            registerFound = true
                        end
                    end

                    if registerFound then
                        spec.attachedSplitShapeY = spec.attachedSplitShapeTargetY
                        self:setDelimbStatus(0, false, false)
                    end

                    -- updating tree postition
                    if spec.attachedSplitShapeJointIndex ~= nil then
                        x, y, z = localToWorld(spec.cutNode, 0.3, 0, 0)
                        nx, ny, nz = localDirectionToWorld(spec.cutNode, 1, 0, 0)
                        local yx, yy, yz = localDirectionToWorld(spec.cutNode, 0, 1, 0)
                        local shape, minY, maxY, minZ, maxZ =
                            findSplitShape(x, y, z, nx, ny, nz, yx, yy, yz, spec.cutSizeY, spec.cutSizeZ)
                        if shape == spec.attachedSplitShape then
                            local treeCenterX, treeCenterY, treeCenterZ = localToWorld(spec.cutNode, 0,
                                (minY + maxY) * 0.5, (minZ + maxZ) * 0.5)
                            spec.attachedSplitShapeX, _, spec.attachedSplitShapeZ = worldToLocal(
                                spec.attachedSplitShape, treeCenterX, treeCenterY, treeCenterZ)
                            self:setLastTreeDiameter((maxY - minY + maxZ - minZ) * 0.5)
                        end
                        x, y, z = localToWorld(spec.attachedSplitShape, spec.attachedSplitShapeX,
                            spec.attachedSplitShapeY, spec.attachedSplitShapeZ)
                        setJointPosition(spec.attachedSplitShapeJointIndex, 1, x, y, z)

                        local cutLength = spec.attachedSplitShapeTargetY - spec.attachedSplitShapeLastCutY
                        local remainingLength = spec.attachedSplitShapeTargetY - spec.attachedSplitShapeY
                        spec.currentLength = cutLength - remainingLength
                    end

                    if registerFound then
                        self:onRegisterFound()
                    end
                end
            end
        end
    end

    -- physical rotator mode
    if self.isServer then
        if spec.rotatorMode == WHC.ROTATOR_PHYSICAL and spec.cutReleasedComponentJoint2 ~= nil and spec.rotatorNode ~=
            nil then
            local jointNodeActor1 = spec.cutReleasedComponentJoint2.jointNodeActor1
            local mountNode = spec.cutReleasedComponentJoint2.jointNode
            local rotNode = spec.rotatorNode

            if jointNodeActor1 ~= nil and mountNode ~= nil and rotNode ~= nil then

                local x = spec.rotatorRotationAxis == 1 and 1 or 0
                local y = spec.rotatorRotationAxis == 2 and 1 or 0
                local z = spec.rotatorRotationAxis == 3 and 1 or 0

                local dirYRotX, dirYRotY, dirYRotZ = localDirectionToWorld(rotNode, x, y, z)
                -- we assume that the joint rotator axis is always X as the original WoodHarvester script used that
                local dirXActorX, dirXActorY, dirXActorZ = localDirectionToWorld(jointNodeActor1, 0.1, 0.1, 1)

                local dir = MathUtil.dotProduct(dirXActorX, dirXActorY, dirXActorZ, dirYRotX, dirYRotY, dirYRotZ)
                dir = dir > 0 and 1 or -1

                local dirMountX, dirMountY, dirMountZ = localDirectionToWorld(mountNode, 0, 0, 1)
                local posMountX, posMountY, posMountZ = localToWorld(mountNode, 0, 0, 0)

                local rotX, rotY, rotZ = getRotation(rotNode)
                local dirActorX, dirActorY, dirActorZ = localDirectionToWorld(jointNodeActor1, 0, 0, 1)

                local posActorX, posActorY, posActorZ = localToWorld(jointNodeActor1, 0, 0, 0)

                local rotAxisX, rotAxisY, rotAxisZ = MathUtil.crossProduct(dirMountX, dirMountY, dirMountZ, dirActorX,
                    dirActorY, dirActorZ)

                local nActorX, nActorY, nActorZ = localDirectionToWorld(jointNodeActor1, 1, 0, 0)

                local dot = MathUtil.dotProduct(dirMountX, dirMountY, dirMountZ, dirActorX, dirActorY, dirActorZ)

                local x = dot
                local y = MathUtil.dotProduct(nActorX, nActorY, nActorZ, rotAxisX, rotAxisY, rotAxisZ)

                local angleBetween = math.atan2(y, x)

                if math.abs(angleBetween) > spec.rotatorThreshold then
                    if spec.rotatorRotationAxis == 1 then
                        local newRotX = rotX - angleBetween * dir
                        if spec.rotatorRotMin ~= nil and spec.rotatorRotMax ~= nil then
                            newRotX = MathUtil.clamp(rotX - angleBetween * dir, spec.rotatorRotMin, spec.rotatorRotMax)
                        end
                        setRotation(rotNode, newRotX, rotY, rotZ)
                    elseif spec.rotatorRotationAxis == 2 then
                        local newRotY = rotY - angleBetween * dir
                        if spec.rotatorRotMin ~= nil and spec.rotatorRotMax ~= nil then
                            newRotY = MathUtil.clamp(rotY - angleBetween * dir, spec.rotatorRotMin, spec.rotatorRotMax)
                        end
                        setRotation(rotNode, rotX, newRotY, rotZ)
                    elseif spec.rotatorRotationAxis == 3 then
                        local newRotZ = rotZ - angleBetween * dir
                        if spec.rotatorRotMin ~= nil and spec.rotatorRotMax ~= nil then
                            newRotZ = MathUtil.clamp(rotZ - angleBetween * dir, spec.rotatorRotMin, spec.rotatorRotMax)
                        end
                        setRotation(rotNode, rotX, rotY, newRotZ)
                    end

                end

                -- update joint
                local componentJoint = self.componentJoints[spec.cutReleasedComponentJoint2.index]
                self:setComponentJointFrame(componentJoint, 1)
            end
        end
    end

    -- hold timers
    if self.isServer then
        if spec.closeHoldTimer >= 0 then
            spec.closeHoldTimer = spec.closeHoldTimer + dt
            if spec.isHeadClosed == false then
                if spec.closeHoldTimer >= spec.closeHoldTargetTime then
                    self:setAttachStatus(true)
                    spec.closeHoldTimer = -1
                end
            end
        end

        if spec.autoProgramHoldTimer >= 0 then
            spec.autoProgramHoldTimer = spec.autoProgramHoldTimer + dt
            if spec.isHeadClosed == false then
            else
                if spec.registerFound == false then
                    if spec.autoProgramFeeding == WHC.AUTO_HOLD then
                        if spec.hasAttachedSplitShape then
                            if not spec.isAttachedSplitShapeMoving and not spec.isSawOut then
                                spec.autoFeedingTimer = spec.autoFeedingTimer + dt
                                if spec.autoFeedingTimer > spec.autoFeedingDelay then
                                    self:findRegister()
                                    spec.autoFeedingTimer = -1
                                end
                            end
                        end
                    end
                else
                    if WHC.checkAutoProgramCut(self, WHC.AUTO_HOLD) then
                        if spec.hasAttachedSplitShape then
                            if spec.autoProgramTransitionTimer == -1 and not spec.isAttachedSplitShapeMoving and
                                not spec.isSawOut then
                                spec.autoProgramTransitionTimer = 0
                            end
                        end
                    end
                end
            end
        end

        if spec.autoProgramTransitionTimer >= 0 then
            spec.autoProgramTransitionTimer = spec.autoProgramTransitionTimer + dt
            if spec.autoProgramTransitionTimer > spec.autoProgramTransitionTargetTime then
                if not spec.isAttachedSplitShapeMoving and not spec.isSawOut then
                    self:lowerSaw(WHC.SAW_SENSOR)
                    spec.autoProgramTransitionTimer = -1
                end
            end
        end

        if WHC.isTiltSupported(self) and spec.tiltUpWithOpenButton and spec.openHoldTimer >= 0 then
            spec.openHoldTimer = spec.openHoldTimer + dt
            if spec.openHoldTimer >= spec.tiltUpDelay then
                spec.tiltedUp = true
                spec.openHoldTimer = -1
            end
        end

        if spec.isSawOut and not self:getIsAnimationPlaying(spec.cutAnimation.name) and
            self:getAnimationTime(spec.cutAnimation.name) == 0 then
            spec.isSawOut = false
        end
    end

    -- effect and sound for cut and delimb
    if self.isServer then
        -- cut
        if spec.cutAnimation.name ~= nil then
            if spec.isSawOut and spec.playCutSound == true then
                local targetAnimTime = spec.cutAnimation.cutTime
                if spec.advancedCut == true then
                    targetAnimTime = math.min(1.0, (spec.tempDiameter / spec.cutAnimation.maxCutDiameter) * 1.1)
                end

                -- play effects if is cutting a tree
                if (spec.hasAttachedSplitShape or spec.curSplitShape ~= nil) and
                    self:getAnimationTime(spec.cutAnimation.name) < targetAnimTime then
                    self:handleCutEffects(true, true)
                else
                    self:handleCutEffects(true, false)
                end
            else
                self:handleCutEffects(false, false)
            end
        end

        -- delimb
        if spec.isAttachedSplitShapeMoving then
            -- forward by default
            local forwardFeed = true
            if spec.manualFeedingBackward or
                (not spec.manualFeedingForward and spec.hasAttachedSplitShape and spec.attachedSplitShapeY >=
                    spec.attachedSplitShapeTargetY) then
                -- backward
                forwardFeed = false
            end

            -- play effect if is moving a tree
            if spec.hasAttachedSplitShape then
                self:handleDelimbEffects(true, true, forwardFeed)
            else
                self:handleDelimbEffects(true, false, forwardFeed)
            end
        else
            self:handleDelimbEffects(false, false)
        end
    end
end

function WoodHarvesterControls:handleCutEffects(sound, particles, noEventSend)

    if sound == nil then
        sound = false
    end

    if particles == nil then
        particles = false
    end

    WoodHarvesterControlsCutEffectsEvent.sendEvent(self, sound, particles, noEventSend)

    if self.isClient then
        local spec = self.spec_woodHarvester

        if spec.samples.cut then
            if sound then
                if not spec.isCutSamplePlaying then
                    g_soundManager:playSample(spec.samples.cut)
                    spec.isCutSamplePlaying = true
                end
            elseif spec.isCutSamplePlaying then
                g_soundManager:stopSample(spec.samples.cut)
                spec.isCutSamplePlaying = false

                if spec.samples.cutEnd ~= nil then
                    g_soundManager:playSample(spec.samples.cutEnd, 0, spec.samples.cut)
                end
            end
        end

        if spec.cutEffects then
            if particles then
                if not spec.isCutEffectPlaying then
                    g_effectManager:setFillType(spec.cutEffects, FillType.WOODCHIPS)
                    g_effectManager:startEffects(spec.cutEffects)
                    spec.isCutEffectPlaying = true
                end
            else
                g_effectManager:stopEffects(spec.cutEffects)
                spec.isCutEffectPlaying = false
            end
        end

    end
end

function WoodHarvesterControls:handleDelimbEffects(sound, particles, forward, noEventSend)

    if sound == nil then
        sound = false
    end

    if particles == nil then
        particles = false
    end

    if forward == nil then
        forward = true
    end

    WoodHarvesterControlsDelimbEffectsEvent.sendEvent(self, sound, particles, forward, noEventSend)

    if self.isClient then
        local spec = self.spec_woodHarvester

        if spec.samples.delimb then
            if sound then
                if not spec.isDelimbSamplePlaying then
                    g_soundManager:playSample(spec.samples.delimb)
                    spec.isDelimbSamplePlaying = true
                end
            else
                g_soundManager:stopSample(spec.samples.delimb)
                spec.isDelimbSamplePlaying = false
            end
        end

        if spec.forwardingNodes then
            if sound then
                if not spec.isDelimbAnimationPlaying then
                    local animationSpeed = 1

                    if not forward then
                        animationSpeed = -1
                    end

                    for key, forwardingAnimation in pairs(spec.forwardingNodes) do
                        spec.forwardingNodes[key].rotSpeed = spec.forwardingNodesSpeed[key] * animationSpeed
                    end

                    g_animationManager:startAnimations(spec.forwardingNodes)
                    spec.isDelimbAnimationPlaying = true
                end
            else
                g_animationManager:stopAnimations(spec.forwardingNodes)
                spec.isDelimbAnimationPlaying = false
            end
        end

        if spec.delimbEffects then
            if particles then
                if not spec.isDelimbEffectPlaying then
                    g_effectManager:setFillType(spec.delimbEffects, FillType.WOODCHIPS)
                    g_effectManager:startEffects(spec.delimbEffects)
                    spec.isDelimbEffectPlaying = true
                end
            else
                g_effectManager:stopEffects(spec.delimbEffects)
                spec.isDelimbEffectPlaying = false
            end
        end

    end
end

function WoodHarvesterControls:onUpdateTick(superFunc, dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    local spec = self.spec_woodHarvester

    spec.warnInvalidTree = false
    spec.warnInvalidTreeRadius = false
    spec.warnInvalidTreePosition = false
    spec.warnTreeNotOwned = false

    if self.isServer and self:getIsTurnedOn() then
        if spec.attachedSplitShape == nil and spec.cutNode ~= nil then
            local x, y, z = getWorldTranslation(spec.cutNode)
            local nx, ny, nz = localDirectionToWorld(spec.cutNode, 1, 0, 0)
            local yx, yy, yz = localDirectionToWorld(spec.cutNode, 0, 1, 0)

            self:findSplitShapesInRange()

            if spec.curSplitShape ~= nil then
                local minY, maxY, minZ, maxZ = testSplitShape(spec.curSplitShape, x, y, z, nx, ny, nz, yx, yy, yz,
                    spec.cutSizeY, spec.cutSizeZ)
                if minY == nil then
                    spec.curSplitShape = nil
                else
                    -- check if cut would be below y=0 (tree CoSy)
                    local cutTooLow = false
                    local _
                    _, y, _ = localToLocal(spec.cutNode, spec.curSplitShape, 0, minY, minZ)
                    cutTooLow = cutTooLow or y < 0.01
                    _, y, _ = localToLocal(spec.cutNode, spec.curSplitShape, 0, minY, maxZ)
                    cutTooLow = cutTooLow or y < 0.01
                    _, y, _ = localToLocal(spec.cutNode, spec.curSplitShape, 0, maxY, minZ)
                    cutTooLow = cutTooLow or y < 0.01
                    _, y, _ = localToLocal(spec.cutNode, spec.curSplitShape, 0, maxY, maxZ)
                    cutTooLow = cutTooLow or y < 0.01
                    if cutTooLow then
                        spec.curSplitShape = nil
                    end
                end
            end

            if spec.curSplitShape == nil and spec.cutTimer > -1 then
                self:setLastTreeDiameter(0)
                SpecializationUtil.raiseEvent(self, "onCutTree", 0)
                if g_server ~= nil then
                    g_server:broadcastEvent(WoodHarvesterOnCutTreeEvent.new(self, 0), nil, nil, self)
                end
            end

        end
    end

    if self.isServer then
        -- tilt control
        if spec.tiltControl == true then
            local shouldUpdateLimit = false
            local shouldUpdateSpring = false
            -- tilt up / down / push
            if WHC.isTiltSupported(self) then
                if spec.tiltedUp == false and spec.forcedTiltDown == true then
                    if spec.cutReleasedComponentJointRotLimitX ~= spec.tiltMaxRot then
                        spec.cutReleasedComponentJointRotLimitX = spec.tiltMaxRot
                        shouldUpdateLimit = true
                    end

                    if spec.cutReleasedComponentJointRotLimitXNegative ~= spec.tiltMaxRot then
                        spec.cutReleasedComponentJointRotLimitXNegative = math.min(spec.tiltMaxRot,
                            spec.cutReleasedComponentJointRotLimitXNegative +
                                spec.cutReleasedComponentJointRotLimitXSpeed * dt)
                        shouldUpdateLimit = true
                    end

                    if spec.currentTiltDownForce ~= spec.tiltDownForce or spec.currentTiltDownDamping ~=
                        spec.tiltDownDamping then
                        spec.currentTiltDownForce = spec.tiltDownForce
                        spec.currentTiltDownDamping = spec.tiltDownDamping
                        shouldUpdateSpring = true
                    end

                elseif spec.tiltedUp == false and not spec.forcedTiltUp then
                    if spec.cutReleasedComponentJointRotLimitXNegative ~= 0 then
                        spec.cutReleasedComponentJointRotLimitXNegative = 0
                        shouldUpdateLimit = true
                    end

                    if spec.cutReleasedComponentJointRotLimitX ~= spec.tiltMaxRot then
                        spec.cutReleasedComponentJointRotLimitX = spec.tiltMaxRot
                        shouldUpdateLimit = true
                    end

                    if spec.currentTiltDownForce ~= WHC.DEFAULT_TILT_DOWN_FORCE or spec.currentTiltDownDamping ~=
                        WHC.DEFAULT_TILT_DOWN_DAMPING then
                        spec.currentTiltDownForce = WHC.DEFAULT_TILT_DOWN_FORCE
                        spec.currentTiltDownDamping = WHC.DEFAULT_TILT_DOWN_DAMPING
                        shouldUpdateSpring = true
                    end

                elseif spec.tiltedUp == true then
                    if spec.cutReleasedComponentJointRotLimitXNegative ~= 0 then
                        spec.cutReleasedComponentJointRotLimitXNegative = 0
                        shouldUpdateLimit = true
                    end

                    if spec.cutReleasedComponentJointRotLimitX ~= 0 then
                        spec.cutReleasedComponentJointRotLimitX =
                            math.max(0, spec.cutReleasedComponentJointRotLimitX -
                                spec.cutReleasedComponentJointRotLimitXSpeed * dt)
                        shouldUpdateLimit = true
                    end

                    if spec.currentTiltDownForce ~= WHC.DEFAULT_TILT_DOWN_FORCE or spec.currentTiltDownDamping ~=
                        WHC.DEFAULT_TILT_DOWN_DAMPING then
                        spec.currentTiltDownForce = WHC.DEFAULT_TILT_DOWN_FORCE
                        spec.currentTiltDownDamping = WHC.DEFAULT_TILT_DOWN_DAMPING
                        shouldUpdateSpring = true
                    end
                end

                if shouldUpdateLimit then
                    setJointRotationLimit(spec.cutReleasedComponentJoint.jointIndex, 0, true,
                        spec.cutReleasedComponentJointRotLimitXNegative, spec.cutReleasedComponentJointRotLimitX)
                end
                if shouldUpdateSpring then
                    setJointRotationLimitSpring(spec.cutReleasedComponentJoint.jointIndex, 0, spec.currentTiltDownForce,
                        spec.currentTiltDownDamping)
                end
            end
        else
            if spec.attachedSplitShape == nil then
                -- in-game behaviour
                if spec.cutReleasedComponentJoint ~= nil and spec.cutReleasedComponentJointRotLimitX ~= 0 then
                    spec.cutReleasedComponentJointRotLimitX =
                        math.max(0, spec.cutReleasedComponentJointRotLimitX -
                            spec.cutReleasedComponentJointRotLimitXSpeed * dt)
                    setJointRotationLimit(spec.cutReleasedComponentJoint.jointIndex, 0, true, 0,
                        spec.cutReleasedComponentJointRotLimitX)
                end
            end
        end

        -- rotator mode
        if spec.rotatorMode == WHC.ROTATOR_FREE then
            -- in-game behaviour
            if spec.attachedSplitShape == nil then
                if spec.cutReleasedComponentJoint2 ~= nil and spec.cutReleasedComponentJoint2RotLimitX ~= 0 then
                    spec.cutReleasedComponentJoint2RotLimitX = math.max(
                        spec.cutReleasedComponentJoint2RotLimitX - spec.cutReleasedComponentJoint2RotLimitXSpeed * dt, 0)
                    setJointRotationLimit(spec.cutReleasedComponentJoint2.jointIndex, 0, true,
                        -spec.cutReleasedComponentJoint2RotLimitX, spec.cutReleasedComponentJoint2RotLimitX)
                end
            end
        end
    end

    if self.isServer then
        if spec.automaticFeedingOption == true and spec.automaticFeedingStarted == true then
            if spec.autoProgramFeeding ~= WHC.AUTO_HOLD then
                if spec.registerFound == false then
                    if spec.hasAttachedSplitShape then
                        if not spec.isAttachedSplitShapeMoving and not spec.isSawOut then
                            spec.autoFeedingTimer = spec.autoFeedingTimer + dt
                            if spec.autoFeedingTimer > spec.autoFeedingDelay then
                                if spec.repeatLengthPreset then
                                    self:findRegister(spec.currentLengthPreset)
                                else
                                    self:findRegister()
                                end
                                spec.autoFeedingTimer = -1
                            end
                        end
                    end
                end
            end
        end
    end

    if self.isClient then
        local actionEvent = spec.actionEvents[InputAction.IMPLEMENT_EXTRA2]
        if actionEvent ~= nil then
            if spec.autoProgramWithCut == true then
                g_inputBinding:setActionEventText(actionEvent.actionEventId,
                    g_i18n:getText("action_feedCutAutomaticProgram"))
            elseif not spec.isAttachedSplitShapeMoving then
                g_inputBinding:setActionEventText(actionEvent.actionEventId, g_i18n:getText("action_saw"))
            end
        end
    end
end

function WoodHarvesterControls:cutTree(superFunc, length, noEventSend)
    length = length or 0
    WoodHarvesterCutTreeEvent.sendEvent(self, length, noEventSend)
end

-- event when tree is cut or lost
function WoodHarvesterControls:onCutTree(superFunc, radius)
    local spec = self.spec_woodHarvester
    if radius > 0 then
        spec.hasAttachedSplitShape = true
        if self.isServer then
            self:setLastTreeDiameter(2 * radius)
            self:setGrabStatus(true, false, true)
        end
    else
        spec.cutTimer = -1
        if spec.currentSawMode == WHC.SAW_AUTO then
            self:raiseSaw()
        end

        if spec.hasAttachedSplitShape == true then
            spec.hasAttachedSplitShape = false
            if self.isServer then
                spec.tempDiameter = 0
                spec.referenceCutDone = false
                spec.automaticFeedingStarted = false
                spec.autoProgramStarted = false
                spec.currentAssortmentIndex = nil
                spec.lastAssortment = nil

                -- automatic tilt up
                if WHC.isTiltSupported(self) and spec.tiltedUp == false and spec.automaticTiltUp == true and
                    spec.tiltedUpOnCut then
                    spec.tiltedUp = true
                    spec.tiltedUpOnCut = false
                end

                -- close head when it finishes the tree
                if spec.automaticOpen == false then
                    if spec.isHeadClosed then
                        self:setGrabStatus(true, false, true)
                    end
                else
                    spec.isHeadClosed = false
                    self:setGrabStatus(false, false, true)
                end
            end
        end
    end
end

function WoodHarvesterControls:updateSettings(settings, noEventSend)

    WoodHarvesterControlsUpdateSettingsEvent.sendEvent(self, settings, noEventSend)

    local spec = self.spec_woodHarvester

    -- easy controls
    spec.autoProgramWithCut = settings.autoProgramWithCut
    spec.automaticTiltUp = settings.automaticTiltUp
    if self.isServer and settings.automaticOpen and spec.automaticOpen == false and spec.attachedSplitShape == nil then
        self:setAttachStatus(false)
    end
    spec.automaticOpen = settings.automaticOpen
    spec.grabOnCut = settings.grabOnCut

    -- bucking system
    spec.numberOfAssortments = settings.numberOfAssortments
    for i = 1, 4 do
        spec.bucking[i].minDiameter = settings.bucking[i].minDiameter
        spec.bucking[i].length = settings.bucking[i].length
    end

    -- automatic program
    spec.autoProgramFeeding = settings.autoProgramFeeding
    spec.autoProgramFellingCut = settings.autoProgramFellingCut
    spec.autoProgramBuckingCut = settings.autoProgramBuckingCut
    spec.autoProgramWithClose = settings.autoProgramWithClose
    spec.automaticFeedingOption = settings.automaticFeedingOption

    -- rotator options
    spec.rotatorMode = settings.rotatorMode
    spec.rotatorRotLimitForceLimit = settings.rotatorRotLimitForceLimit
    spec.rotatorThreshold = settings.rotatorThreshold

    -- saw options
    spec.sawMode = settings.sawMode

    -- length presets
    for i = 1, 4 do
        spec["lengthPreset" .. i] = settings["lengthPreset" .. i]
    end
    spec.repeatLengthPreset = settings.repeatLengthPreset

    -- feeding options
    spec.breakingDistance = settings.breakingDistance
    spec.slowFeedingTiltedUp = settings.slowFeedingTiltedUp
    spec.feedingSpeed = settings.feedingSpeed
    spec.slowFeedingSpeed = settings.slowFeedingSpeed

    -- tilt options
    spec.tiltDownOnFellingCut = settings.tiltDownOnFellingCut
    spec.tiltUpWithOpenButton = settings.tiltUpWithOpenButton
    spec.tiltUpDelay = settings.tiltUpDelay
    spec.tiltMaxRot = settings.tiltMaxRot

    -- user preferences
    spec.registerSound = settings.registerSound
    spec.maxRemovingLength = settings.maxRemovingLength
    spec.allSplitType = settings.allSplitType

    if self.isServer then
        self:updateRotatorMode()
    end
end

function WoodHarvesterControls:updateRotatorMode()
    local spec = self.spec_woodHarvester

    if spec.cutReleasedComponentJoint2 ~= nil then
        if spec.rotatorMode == WHC.ROTATOR_FREE then
            setJointRotationLimitForceLimit(spec.cutReleasedComponentJoint2.jointIndex, 0,
                spec.rotatorOriginalRotLimitForce)
            if spec.attachedSplitShape ~= nil then
                spec.cutReleasedComponentJoint2RotLimitX = math.pi * 0.9
                if spec.cutReleasedComponentJoint2.jointIndex ~= 0 then
                    setJointRotationLimit(spec.cutReleasedComponentJoint2.jointIndex, 0, true,
                        -spec.cutReleasedComponentJoint2RotLimitX, spec.cutReleasedComponentJoint2RotLimitX)
                end
            end
        elseif spec.rotatorMode == WHC.ROTATOR_FIXED then
            setJointRotationLimitForceLimit(spec.cutReleasedComponentJoint2.jointIndex, 0,
                spec.rotatorOriginalRotLimitForce)
        elseif spec.rotatorMode == WHC.ROTATOR_PHYSICAL then
            setJointRotationLimitForceLimit(spec.cutReleasedComponentJoint2.jointIndex, 0,
                spec.rotatorRotLimitForceLimit)

            if spec.cutReleasedComponentJoint2RotLimitX ~= 0 then
                spec.cutReleasedComponentJoint2RotLimitX = 0
                setJointRotationLimit(spec.cutReleasedComponentJoint2.jointIndex, 0, true,
                    -spec.cutReleasedComponentJoint2RotLimitX, spec.cutReleasedComponentJoint2RotLimitX)
            end
        end
    end
end

function WoodHarvesterControls:setGrabStatus(close, stop, full, targetAnimTime, noEventSend)

    if self.isServer then
        local spec = self.spec_woodHarvester
        targetAnimTime = math.min(1.0, spec.tempDiameter / 2 / spec.treeSizeMeasure.rotMaxRadius)

        if close == nil then
            close = true
        end
        if stop == nil then
            stop = false
        end
        if full == nil then
            full = false
        end

        WoodHarvesterControlsSetGrabEvent.sendEvent(self, close, stop, full, targetAnimTime, noEventSend)
    end

    if self.isClient then
        if stop then
            WHC.stopCloseHeadAnimation(self, full)
        else
            if close then
                WHC.playCloseHeadAnimation(self, full, targetAnimTime)
            else
                WHC.playOpenHeadAnimation(self)
            end
        end

    end
end

function WoodHarvesterControls:setAttachStatus(attach, noEventSend)
    if attach then
        self:attachTree()
    else
        self:detachTree()
    end
end

function WoodHarvesterControls:setDelimbStatus(speed, manualFeedingForward, manualFeedingBackward, noEventSend)
    if speed == nil then
        speed = 0
    end
    if manualFeedingForward == nil then
        manualFeedingForward = false
    end
    if manualFeedingBackward == nil then
        manualFeedingBackward = false
    end

    WoodHarvesterControlsSetDelimbEvent.sendEvent(self, speed, manualFeedingForward, manualFeedingBackward, noEventSend)

    if self.isServer then

        local spec = self.spec_woodHarvester

        spec.isAttachedSplitShapeMoving = false
        spec.currentFeedingSpeed = 0
        spec.manualFeedingForward = false
        spec.manualFeedingBackward = false

        -- only delimb if saw is not running
        if not spec.isSawOut then
            if speed > 0 then
                spec.isAttachedSplitShapeMoving = true
                if spec.slowFeedingTiltedUp and (WHC.isTiltedUp(self) or WHC.isStandingTreeAttached(self)) then
                    spec.currentFeedingSpeed = spec.slowFeedingSpeed
                else
                    spec.currentFeedingSpeed = speed
                end
            end

            if manualFeedingForward then
                spec.manualFeedingForward = true
            elseif manualFeedingBackward then
                spec.manualFeedingBackward = true
            end
        end

        if manualFeedingForward or manualFeedingBackward then
            -- disable automatic feeding
            spec.automaticFeedingStarted = false
            spec.autoProgramStarted = false

        end
    end
end

function WoodHarvesterControls:findRegister(desiredLength, noEventSend)
    desiredLength = desiredLength or 0

    WoodHarvesterControlsFindRegisterEvent.sendEvent(self, desiredLength, noEventSend)

    local spec = self.spec_woodHarvester

    if self.isServer and spec.attachedSplitShape ~= nil then
        local assortmentDefined = false
        local length = spec.currentCutLength
        spec.currentAssortmentIndex = nil

        if (desiredLength == 0) then
            for index, assortment in pairs(spec.bucking) do
                local minDiameter = assortment.minDiameter or 0

                if index == spec.numberOfAssortments then
                    minDiameter = 0
                end

                if assortment.length ~= nil and minDiameter < spec.lastDiameter then
                    -- find register
                    spec.currentAssortmentIndex = index
                    length = assortment.length
                    break
                end
            end
            spec.currentLengthPreset = 0
        else
            length = desiredLength
            spec.currentLengthPreset = length
        end

        spec.attachedSplitShapeTargetY = spec.attachedSplitShapeLastCutY + length * spec.cutAttachDirection
        spec.currentCutLength = length

        self:setDelimbStatus(spec.feedingSpeed, false, false)
    end
end

function WoodHarvesterControls:handleRegisterSound(newRegister, noEventSend)
    local spec = self.spec_woodHarvester

    WoodHarvesterControlsRegisterSoundEvent.sendEvent(self, newRegister, noEventSend)

    if self.isClient then
        local isEntered = false

        if self.getIsEntered ~= nil then
            isEntered = self:getIsEntered()
        elseif self.getAttacherVehicle ~= nil then
            local parentVehicle = self:getAttacherVehicle()
            while parentVehicle.getAttacherVehicle ~= nil do
                parentVehicle = parentVehicle:getAttacherVehicle()
            end
            if parentVehicle.getIsEntered ~= nil then
                isEntered = parentVehicle:getIsEntered()
            end
        end

        if isEntered then
            local sample = WoodHarvesterControls.registerFoundSample

            if newRegister then
                sample = WoodHarvesterControls.assortmentChangedSample
            end

            if spec.registerSound then
                playSample(sample, 1, 0.2, 0, 0, 0)
            end
        end
    end

end

function WoodHarvesterControls:onRegisterFound()
    local spec = self.spec_woodHarvester
    if spec.registerFound == true then
        return
    end

    spec.registerFound = true
    if spec.automaticFeedingOption == true and spec.automaticFeedingStarted == false then
        spec.automaticFeedingStarted = true
    end

    local newRegister = spec.lastAssortment ~= nil and spec.lastAssortment ~= spec.currentAssortmentIndex

    self:handleRegisterSound(newRegister)

    if spec.lastAssortment ~= nil and spec.lastAssortment ~= spec.currentAssortmentIndex then
        spec.autoProgramHoldTimer = -1
        spec.autoProgramTransitionTimer = -1
    end

    spec.lastAssortment = spec.currentAssortmentIndex
end

function WoodHarvesterControls:lowerSaw(mode)
    local spec = self.spec_woodHarvester

    if spec.isAttachedSplitShapeMoving then
        return
    end

    if mode == WHC.SAW_AUTO and spec.attachedSplitShape == nil and spec.curSplitShape == nil then
        return
    end

    -- wood harvester measurement compatibility 
    if self.setCutOnGoing ~= nil then
        self:setCutOnGoing(true)
    end

    spec.currentSawMode = mode

    if spec.currentSawMode == WHC.SAW_SENSOR then
        spec.registerFound = true
    else
        spec.referenceCutDone = true
        spec.registerFound = false
        spec.attachedSplitShapeLastCutY = spec.attachedSplitShapeY
        spec.attachedSplitShapeStartY = spec.attachedSplitShapeY
        spec.attachedSplitShapeTargetY = spec.attachedSplitShapeY
        spec.currentLength = 0
    end

    if not spec.isAttachedSplitShapeMoving then

        spec.cutTimer = 100
        if spec.cutAnimation.name ~= nil then
            local speed = spec.cutAnimation.speedScale * spec.cutSawSpeedMultiplier
            if not spec.advancedCut then
                self:setAnimationStopTime(spec.cutAnimation.name, spec.cutAnimation.cutTime)
            else
                self:setAnimationStopTime(spec.cutAnimation.name, 1)
            end
            self:playAnimation(spec.cutAnimation.name, speed, self:getAnimationTime(spec.cutAnimation.name))
            spec.isSawOut = true
            spec.playCutSound = true
        end

    end
end

function WoodHarvesterControls:raiseSaw()
    local spec = self.spec_woodHarvester

    if spec.isSawOut == false then
        return
    end

    -- wood harvester measurement compatibility 
    if self.setCutOnGoing ~= nil then
        self:setCutOnGoing(false)
    end

    spec.currentSawMode = nil

    if spec.cutAnimation.name ~= nil then
        self:setAnimationStopTime(spec.cutAnimation.name, 0)

        self:playAnimation(spec.cutAnimation.name, -spec.cutAnimation.speedScale * spec.sawSpeedMultiplier,
            self:getAnimationTime(spec.cutAnimation.name), false)

        spec.playCutSound = false
    end
end

function WoodHarvesterControls:woodHarvesterSplitShapeCallback(superFunc, shape, isBelow, isAbove, minY, maxY, minZ,
    maxZ)
    local spec = self.spec_woodHarvester

    g_currentMission:addKnownSplitShape(shape)
    g_treePlantManager:addingSplitShape(shape, self.shapeBeingCut, self.shapeBeingCutIsTree)

    if isAbove and not isBelow then

        if spec.grabOnCut then
            spec.isHeadClosed = true
        end

        if spec.isHeadClosed then
            self:attachShape(shape, minY, maxY, minZ, maxZ)

            spec.referenceCutDone = true

            if spec.tiltControl ~= true then
                if spec.cutReleasedComponentJoint ~= nil then
                    spec.cutReleasedComponentJointRotLimitX = math.pi * 0.9
                    if spec.cutReleasedComponentJoint.jointIndex ~= 0 then
                        setJointRotationLimit(spec.cutReleasedComponentJoint.jointIndex, 0, true, 0,
                            spec.cutReleasedComponentJointRotLimitX)
                    end
                end
            else
                -- tilt down
                if WHC.isTiltedUp(self) and spec.tiltDownOnFellingCut then
                    spec.tiltedUpOnCut = true
                    spec.tiltedUp = false
                end
            end

            if spec.rotatorMode == WHC.ROTATOR_FREE then
                if spec.cutReleasedComponentJoint2 ~= nil then
                    spec.cutReleasedComponentJoint2RotLimitX = math.pi * 0.9
                    if spec.cutReleasedComponentJoint2.jointIndex ~= 0 then
                        setJointRotationLimit(spec.cutReleasedComponentJoint2.jointIndex, 0, true,
                            -spec.cutReleasedComponentJoint2RotLimitX, spec.cutReleasedComponentJoint2RotLimitX)
                    end
                end
            end

            local radius = ((maxY - minY) + (maxZ - minZ)) / 4
            SpecializationUtil.raiseEvent(self, "onCutTree", radius)
            if g_server ~= nil then
                g_server:broadcastEvent(WoodHarvesterOnCutTreeEvent.new(self, radius), nil, nil, self)
            end
        end
    end

    if spec.maxRemovingLength > 0 and isBelow and not isAbove then
        local sizeX, sizeY, sizeZ, _, _ = getSplitShapeStats(shape)
        local maxSize = math.max(sizeX, sizeY, sizeZ)
        if maxSize < spec.maxRemovingLength then
            delete(shape)
        end
    end
end

function WoodHarvesterControls:attachShape(shape, minY, maxY, minZ, maxZ)
    local spec = self.spec_woodHarvester

    if spec.attachedSplitShape == nil and spec.cutAttachNode ~= nil and spec.cutAttachReferenceNode ~= nil then
        spec.attachedSplitShape = shape
        spec.lastTreeSize = {minY, maxY, minZ, maxZ}

        -- Current tree center (mid of cut area)
        local treeCenterX, treeCenterY, treeCenterZ = localToWorld(spec.cutNode, 0, (minY + maxY) * 0.5,
            (minZ + maxZ) * 0.5)

        if spec.loadedSplitShapeFromSavegame then
            if spec.lastTreeJointPos ~= nil then
                treeCenterX, treeCenterY, treeCenterZ = localToWorld(shape, unpack(spec.lastTreeJointPos))
            end

            spec.loadedSplitShapeFromSavegame = false
        end
        spec.lastTreeJointPos = {worldToLocal(shape, treeCenterX, treeCenterY, treeCenterZ)}

        -- Target tree center (half tree size in front of the reference node)
        local x, y, z = localToWorld(spec.cutAttachReferenceNode, 0, 0, (maxZ - minZ) * 0.5)

        local dx, dy, dz = localDirectionToWorld(shape, 0, 0, 1)

        local _, treeYDirection, _ = localDirectionToLocal(shape, spec.cutAttachReferenceNode, 0, 1, 0)
        spec.cutAttachDirection = cutAttachDirection or (treeYDirection > 0 and 1 or -1)
        spec.lastCutAttachDirection = spec.cutAttachDirection

        local upx, upy, upz = localDirectionToWorld(spec.cutAttachReferenceNode, 0, spec.cutAttachDirection, 0)
        local sideX, sideY, sizeZ = MathUtil.crossProduct(upx, upy, upz, dx, dy, dz)
        dx, dy, dz = MathUtil.crossProduct(sideX, sideY, sizeZ, upx, upy, upz) -- Note: we want the up axis to be exact, thus orthogonalize the direction here
        I3DUtil.setWorldDirection(spec.cutAttachHelperNode, dx, dy, dz, upx, upy, upz, 2)

        local constr = JointConstructor.new()
        constr:setActors(spec.cutAttachNode, shape)
        -- Note: we assume that the direction of the tree is equal to the y axis
        constr:setJointTransforms(spec.cutAttachHelperNode, shape)
        constr:setJointWorldPositions(x, y, z, treeCenterX, treeCenterY, treeCenterZ)

        constr:setRotationLimit(0, 0, 0)
        constr:setRotationLimit(1, 0, 0)
        constr:setRotationLimit(2, 0, 0)

        constr:setEnableCollision(false)

        spec.attachedSplitShapeJointIndex = constr:finalize()

        spec.attachedSplitShapeX, spec.attachedSplitShapeY, spec.attachedSplitShapeZ =
            worldToLocal(shape, treeCenterX, treeCenterY, treeCenterZ)
        spec.attachedSplitShapeLastCutY = spec.attachedSplitShapeY
        spec.attachedSplitShapeStartY = spec.attachedSplitShapeY
        spec.attachedSplitShapeTargetY = spec.attachedSplitShapeY
        spec.currentLength = 0

        spec.hasAttachedSplitShape = true

    end
end

function WoodHarvesterControls:setLastTreeDiameter(superFunc, diameter, noEventSend)
    local spec = self.spec_woodHarvester
    spec.lastDiameter = diameter
    if self.isServer then
        spec.tempDiameter = diameter
    end

    WoodHarvesterControlsSetDiameterEvent.sendEvent(self, diameter, noEventSend)
end

function WoodHarvesterControls:getDoConsumePtoPower(superFunc)
    local spec = self.spec_woodHarvester
    return superFunc(self) or self:getIsTurnedOn()
end

function WoodHarvesterControls:onRegisterActionEvents(superFunc, isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_woodHarvester
        self:clearActionEventsTable(spec.actionEvents)

        if isActiveForInputIgnoreSelection then
            for _, action in pairs(WoodHarvesterControls.actions) do
                local actionName = action.name
                local triggerUp = action.triggerUp ~= nil and action.triggerUp or false
                local triggerDown = action.triggerDown ~= nil and action.triggerDown or true
                local triggerAlways = action.triggerAlways ~= nil and action.triggerAlways or false
                local startActive = action.startActive ~= nil and action.startActive or true
                local _, eventName = self:addActionEvent(spec.actionEvents, actionName, self,
                    WoodHarvesterControls.onActionCall, triggerUp, triggerDown, triggerAlways, startActive, nil)

                if g_inputBinding ~= nil and g_inputBinding.events ~= nil and g_inputBinding.events[eventName] ~= nil then
                    if action.priority ~= nil then
                        g_inputBinding:setActionEventTextPriority(eventName, action.priority)
                    end

                    if action.text ~= nil then
                        g_inputBinding:setActionEventText(eventName, action.text)
                    end
                end
            end
        end
    end
end

function WoodHarvesterControls:onActionCall(actionName, keyStatus, callbackStatus, isAnalog, arg6)
    local spec = self.spec_woodHarvester

    if actionName == "WOOD_HARVESTER_CONTROLS_TURN_ON_OFF_HEAD" then
        TurnOnVehicle.actionEventTurnOn(self, actionName, keyStatus, callbackStatus, isAnalog)
        return
    end

    local isHolding = keyStatus > 0

    if not self:getIsTurnedOn() then
        g_currentMission:showBlinkingWarning(g_i18n:getText("warning_turnOnHead"), 2000)
        return
    end

    if actionName == InputAction.IMPLEMENT_EXTRA2 or actionName == "WOOD_HARVESTER_CONTROLS_SAW" then
        self:onCutButton(isHolding)
    elseif actionName == InputAction.IMPLEMENT_EXTRA3 or actionName == "WOOD_HARVESTER_CONTROLS_MENU" then
        WHC.onToggleMenu(self, actionName, keyStatus, callbackStatus, isAnalog)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_TILT_UP_DOWN_HEAD" then
        self:onTiltButtons(WHC.TILT_TYPE_TOGGLE, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_TILT_UP_HEAD" then
        self:onTiltButtons(WHC.TILT_TYPE_UP, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_TILT_DOWN_HEAD" then
        self:onTiltButtons(WHC.TILT_TYPE_DOWN, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_OPEN_HEAD" then
        self:onGrabButtons(WHC.GRAB_TYPE_OPEN, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_CLOSE_HEAD" then
        self:onGrabButtons(WHC.GRAB_TYPE_CLOSE, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_OPEN_CLOSE_HEAD" then
        self:onGrabButtons(WHC.GRAB_TYPE_TOGGLE, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_FORWARD_FEED" then
        WHC.onForwardFeed(self, actionName, keyStatus, callbackStatus, isAnalog)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_BACKWARD_FEED" then
        WHC.onBackwardFeed(self, actionName, keyStatus, callbackStatus, isAnalog)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_SLOW_FORWARD_FEED" then
        WHC.onSlowForwardFeed(self, actionName, keyStatus, callbackStatus, isAnalog)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_SLOW_BACKWARD_FEED" then
        WHC.onSlowBackwardFeed(self, actionName, keyStatus, callbackStatus, isAnalog)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_AUTOMATIC_PROGRAM" then
        self:onButtonPressed(WHC.AUTOMATIC_PROGRAM_BUTTON_ID, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_STOP" then
        self:onButtonPressed(WHC.STOP_BUTTON_ID, isHolding)
    elseif actionName == "WOOD_HARVESTER_CONTROLS_LENGTH_PRESET_1" then
        if g_time - spec.lastPreset1Time < spec.doublePressPresetTime then
            self:findRegister(spec.lengthPreset2)
        else
            self:findRegister(spec.lengthPreset1)
        end
        spec.lastPreset1Time = g_time
    elseif actionName == "WOOD_HARVESTER_CONTROLS_LENGTH_PRESET_2" then
        if g_time - spec.lastPreset2Time < spec.doublePressPresetTime then
            self:findRegister(spec.lengthPreset4)
        else
            self:findRegister(spec.lengthPreset3)
        end
        spec.lastPreset2Time = g_time
    end
end

function WoodHarvesterControls:onCutButton(isHolding, noEventSend)

    WoodHarvesterControlsCutButtonEvent.sendEvent(self, isHolding, noEventSend)

    if self.isServer then
        local spec = self.spec_woodHarvester

        if isHolding then
            local automaticProgramOk = false
            if spec.autoProgramWithCut then
                automaticProgramOk = self:runAutomaticProgram(isHolding)
            end

            if automaticProgramOk == false then
                if spec.sawMode == WHC.MANUAL then
                    self:lowerSaw(WHC.SAW_MANUAL)
                elseif spec.sawMode == WHC.SEMIAUTOMATIC and
                    (WHC.isTiltedUp(self) or WHC.isStandingTreeAttached(self) or WHC.isStandingTreeInRange(self)) then
                    self:lowerSaw(WHC.SAW_MANUAL)
                else
                    self:lowerSaw(WHC.SAW_AUTO)
                end
            end
        else
            local automaticProgramOk = false
            if spec.autoProgramWithCut then
                automaticProgramOk = self:runAutomaticProgram(isHolding)
            end

            if automaticProgramOk == false then
                if spec.isSawOut and (spec.currentSawMode == WHC.SAW_SENSOR or spec.currentSawMode == WHC.SAW_MANUAL) then
                    self:raiseSaw()
                end
            end
        end
    end
end

function WoodHarvesterControls:onButtonPressed(buttonType, isHolding, noEventSend)

    WoodHarvesterControlsButtonPressEvent.sendEvent(self, buttonType, isHolding, noEventSend)

    if self.isServer then
        if buttonType == WHC.STOP_BUTTON_ID then
            if isHolding then
                self:stopHead()
            end
        elseif buttonType == WHC.AUTOMATIC_PROGRAM_BUTTON_ID then
            self:runAutomaticProgram(isHolding)
        end
    end
end

function WoodHarvesterControls:onTiltButtons(tiltType, isHolding, noEventSend)

    if not WHC.isTiltSupported(self) then
        return
    end

    WoodHarvesterControlsTiltButtonsEvent.sendEvent(self, tiltType, isHolding, noEventSend)

    if self.isServer then
        local spec = self.spec_woodHarvester

        spec.forcedTiltUp = false
        spec.forcedTiltDown = false

        if tiltType == WHC.TILT_TYPE_TOGGLE then
            spec.tiltedUp = not spec.tiltedUp
        elseif tiltType == WHC.TILT_TYPE_UP then
            if isHolding then
                spec.tiltedUp = true
            end
            spec.forcedTiltUp = isHolding
        elseif tiltType == WHC.TILT_TYPE_DOWN then
            if not spec.tiltedUp then
                spec.forcedTiltDown = isHolding
            end
            spec.tiltedUp = false
        end
    end
end

function WoodHarvesterControls:onGrabButtons(grabType, isHolding, noEventSend)

    WoodHarvesterControlsGrabButtonsEvent.sendEvent(self, grabType, isHolding, noEventSend)

    if self.isServer then
        local spec = self.spec_woodHarvester

        if grabType == WHC.GRAB_TYPE_TOGGLE then
            if isHolding then
                if spec.isHeadClosed == true then
                    self:setAttachStatus(false)
                    spec.openHoldTimer = 0
                else
                    self:setAttachStatus(true)
                end
            else
                spec.openHoldTimer = -1
            end

        elseif grabType == WHC.GRAB_TYPE_CLOSE then
            if spec.isHeadClosed then
                if spec.autoProgramWithClose then
                    self:runAutomaticProgram(isHolding)
                end
            else
                if isHolding then
                    spec.closeHoldTimer = 0
                    self:setGrabStatus(true, false, false)
                else
                    spec.closeHoldTimer = -1
                    self:setGrabStatus(true, true)
                end
            end

        elseif grabType == WHC.GRAB_TYPE_OPEN then
            if isHolding then
                if spec.isHeadClosed then
                    self:setAttachStatus(false)
                else
                    self:setGrabStatus(false, false, false)
                end
                spec.openHoldTimer = 0
            else
                spec.openHoldTimer = -1
            end
        end

    end
end

function WoodHarvesterControls.onForwardFeed(self, actionName, keyStatus, callbackState, isAnalog)
    local spec = self.spec_woodHarvester

    if keyStatus > 0 then
        self:setDelimbStatus(spec.feedingSpeed, true, false)
    else
        self:setDelimbStatus(0, false, false)
    end
end

function WoodHarvesterControls.onBackwardFeed(self, actionName, keyStatus, callbackState, isAnalog)
    local spec = self.spec_woodHarvester

    if keyStatus > 0 then
        self:setDelimbStatus(spec.feedingSpeed, false, true)
    else
        self:setDelimbStatus(0, false, false)
    end
end

function WoodHarvesterControls.onSlowForwardFeed(self, actionName, keyStatus, callbackState, isAnalog)
    local spec = self.spec_woodHarvester

    if keyStatus > 0 then
        self:setDelimbStatus(spec.slowFeedingSpeed, true, false)
    else
        self:setDelimbStatus(0, false, false)
    end
end

function WoodHarvesterControls.onSlowBackwardFeed(self, actionName, keyStatus, callbackState, isAnalog)
    local spec = self.spec_woodHarvester

    if keyStatus > 0 then
        self:setDelimbStatus(spec.slowFeedingSpeed, false, true)
    else
        self:setDelimbStatus(0, false, false)
    end
end

function WoodHarvesterControls.onToggleMenu(self, actionName, keyStatus, callbackState, isAnalog)
    local spec = self.spec_woodHarvester
    WoodHarvesterControls_Main.ui_menu:setVehicle(self)
    g_gui:showDialog("WoodHarvesterControls_UI")
end

function WoodHarvesterControls:stopHead()
    local spec = self.spec_woodHarvester

    self:setDelimbStatus(0)

    -- disable automatic feeding
    spec.automaticFeedingStarted = false
    spec.autoProgramStarted = false
end

function WoodHarvesterControls:runAutomaticProgram(isHolding)
    local spec = self.spec_woodHarvester

    if isHolding then
        if WHC.isTiltedUp(self) or WHC.isStandingTreeAttached(self) or WHC.isStandingTreeInRange(self) then
            if spec.autoProgramFellingCut == WHC.AUTO_PUSH then
                self:lowerSaw(WHC.SAW_AUTO)
                return true
            elseif spec.autoProgramFellingCut == WHC.AUTO_HOLD then
                self:lowerSaw(WHC.SAW_SENSOR)
                return true
            end
        elseif spec.attachedSplitShape == nil or spec.referenceCutDone == false then
            if spec.autoProgramBuckingCut == WHC.AUTO_PUSH then
                self:lowerSaw(WHC.SAW_AUTO)
                return true
            elseif spec.autoProgramBuckingCut == WHC.AUTO_HOLD then
                self:lowerSaw(WHC.SAW_SENSOR)
                return true
            end
        elseif spec.attachedSplitShape ~= nil then
            spec.autoProgramHoldTimer = 0
            if spec.registerFound then
                if spec.autoProgramBuckingCut == WHC.AUTO_HOLD then
                    self:lowerSaw(WHC.SAW_SENSOR)
                    return true
                elseif spec.autoProgramBuckingCut == WHC.AUTO_PUSH then
                    self:lowerSaw(WHC.SAW_AUTO)
                    return true
                end
            else
                spec.autoProgramStarted = true
                if spec.autoProgramFeeding == WHC.AUTO_HOLD then
                    self:findRegister()
                    return true
                elseif spec.autoProgramFeeding == WHC.AUTO_PUSH then
                    self:setDelimbStatus(0, false, false)
                    spec.automaticFeedingStarted = false
                    return true
                end
            end
        end
    else
        spec.autoProgramHoldTimer = -1
        spec.autoProgramTransitionTimer = -1
        if spec.isSawOut then
            if spec.currentSawMode == WHC.SAW_SENSOR then
                self:raiseSaw()
                return true
            end
        else
            if spec.autoProgramFeeding == WHC.AUTO_HOLD then
                if spec.isAttachedSplitShapeMoving then
                    self:setDelimbStatus(0, false, false)
                    return true
                end
            elseif spec.autoProgramFeeding == WHC.AUTO_PUSH then
                if not spec.registerFound and spec.autoProgramStarted then
                    self:findRegister()
                    return true
                end
            end
        end
    end

    return false
end

function WoodHarvesterControls:attachTree(noEventSend)
    local spec = self.spec_woodHarvester

    spec.isHeadClosed = true

    if self.isServer then
        local offset = 0
        -- if there is no tree in the cutNode try to find one in the middle of the head
        if spec.curSplitShape == nil then
            offset = spec.headHeight / 2
            self:findSplitShapesInRange(offset)
        end

        if spec.curSplitShape ~= nil then
            local x, y, z = localToWorld(spec.cutNode, offset, 0, 0)
            local nx, ny, nz = localDirectionToWorld(spec.cutNode, 1, 0, 0)
            local yx, yy, yz = localDirectionToWorld(spec.cutNode, 0, 1, 0)
            local minY, maxY, minZ, maxZ = testSplitShape(spec.curSplitShape, x, y, z, nx, ny, nz, yx, yy, yz,
                spec.cutSizeY, spec.cutSizeZ)
            if minY ~= nil and minY ~= 0 then
                self:setLastTreeDiameter(math.max(maxY - minY, maxZ - minZ))
                self:attachShape(spec.curSplitShape, minY, maxY, minZ, maxZ)
                self:setGrabStatus(true, false, true)
            end

            self:setAnimationTime(spec.cutAnimation.name, 0, true)
            spec.curSplitShape = nil
        else
            self:setGrabStatus(true, false, true)
        end
    end
end

function WoodHarvesterControls:detachTree()
    local spec = self.spec_woodHarvester

    spec.isHeadClosed = false

    spec.referenceCutDone = false
    spec.automaticFeedingStarted = false
    spec.autoProgramStarted = false
    spec.currentAssortmentIndex = nil
    spec.lastAssortment = nil

    spec.curSplitShape = nil
    spec.hasAttachedSplitShape = false
    spec.isAttachedSplitShapeMoving = false

    if spec.attachedSplitShapeJointIndex ~= nil then
        removeJoint(spec.attachedSplitShapeJointIndex)
        spec.attachedSplitShapeJointIndex = nil
        spec.attachedSplitShape = nil

        self:setLastTreeDiameter(0)

        SpecializationUtil.raiseEvent(self, "onCutTree", 0)
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterOnCutTreeEvent.new(self, 0), nil, nil, self)
        end
    end

    -- automatic tilt up
    if WHC.isTiltSupported(self) and spec.tiltedUp == false and spec.automaticTiltUp == true and spec.tiltedUpOnCut then
        spec.tiltedUp = true
        spec.tiltedUpOnCut = false
    end

    self:setGrabStatus(false, false, true)

    self:handleDelimbEffects(false, false)
    self:handleCutEffects(false, false)
end

function WoodHarvesterControls:onDeactivate()
    local spec = self.spec_woodHarvester
    spec.curSplitShape = nil
end

function WoodHarvesterControls:onTurnedOn()
    local spec = self.spec_woodHarvester

    if spec.automaticOpen and spec.grabAnimation.name ~= nil and spec.attachedSplitShape == nil then
        self:setAttachStatus(false)
    end
end

function WoodHarvesterControls:onTurnedOff()
    local spec = self.spec_woodHarvester

    if spec.automaticOpen and spec.attachedSplitShape == nil then
        self:setGrabStatus(true, false, true)
    end

    if self.isServer then
        self:handleDelimbEffects(false, false, false)
        self:handleCutEffects(false, false)
    end
end

function WoodHarvesterControls:getCanSplitShapeBeAccessed(superFunc, x, z, shape)
    return g_currentMission.accessHandler:canFarmAccessLand(self:getActiveFarm(), x, z) and
               g_currentMission:getHasPlayerPermission("cutTrees", self:getOwner())
end

function WoodHarvesterControls:findSplitShapesInRange(superFunc, yOffset, skipCutAnimation)
    local spec = self.spec_woodHarvester
    if spec.attachedSplitShape == nil and spec.cutNode ~= nil then
        local x, y, z = localToWorld(spec.cutNode, yOffset or 0, 0, 0)
        local nx, ny, nz = localDirectionToWorld(spec.cutNode, 1, 0, 0)
        local yx, yy, yz = localDirectionToWorld(spec.cutNode, 0, 1, 0)

        -- #debug local zx,zy,zz = localDirectionToWorld(spec.cutNode, 0,0,1)
        -- #debug DebugUtil.drawDebugNode(spec.cutNode, "", false)
        -- #debug DebugUtil.drawDebugAreaRectangle(x,y,z, x+zx*spec.cutSizeZ,y+zy*spec.cutSizeZ,z+zz*spec.cutSizeZ, x+yx*spec.cutSizeY,y+yy*spec.cutSizeY,z+yz*spec.cutSizeY, false, 1,0,0)

        local shape, minY, maxY, minZ, maxZ = findSplitShape(x, y, z, nx, ny, nz, yx, yy, yz, spec.cutSizeY,
            spec.cutSizeZ)

        if shape ~= 0 then
            local splitType = g_splitTypeManager:getSplitTypeByIndex(getSplitType(shape))
            if not spec.allSplitType and (splitType == nil or not splitType.allowsWoodHarvester) then
                spec.warnInvalidTree = true
            else
                if self:getCanSplitShapeBeAccessed(x, z, shape) then
                    local treeDx, treeDy, treeDz = localDirectionToWorld(shape, 0, 1, 0) -- wood harvester trees always grow in the y direction
                    local cosTreeAngle = MathUtil.dotProduct(nx, ny, nz, treeDx, treeDy, treeDz)

                    local angleLimit = 0.2617 -- 15° angle for standing trees

                    -- Only allow cutting if the cut header is approximately parallel to the tree
                    -- allow in both directions, so we can also pickup split shapes in any rotation
                    local angle = 1.57079 - math.abs(math.acos(cosTreeAngle) - 1.57079)
                    if angle <= angleLimit then
                        local radius = math.max(maxY - minY, maxZ - minZ) * 0.5 * math.cos(angle)

                        -- #debug local x1, y1, z1 = localToWorld(spec.cutNode, yOffset or 0, minY, minZ)
                        -- #debug local x2, y2, z2 = localToWorld(spec.cutNode, yOffset or 0, minY, maxZ)
                        -- #debug local x3, y3, z3 = localToWorld(spec.cutNode, yOffset or 0, maxY, minZ)
                        -- #debug Utils.renderTextAtWorldPosition((x1+x3) / 2, (y1+y3) / 2, (z1+z3) / 2, string.format("diam: %.1f/%.1f", math.deg(radius*2), math.deg(spec.cutMaxRadius*2)), getCorrectTextSize(0.012), 0)
                        -- #debug DebugUtil.drawDebugAreaRectangle(x1, y1, z1, x2, y2, z2, x3, y3, z3, false, 0,1,0)

                        if radius > spec.cutMaxRadius then
                            spec.warnInvalidTreeRadius = true

                            -- check one meter higher if the tree would fit and then display different warning
                            x, y, z = localToWorld(spec.cutNode, yOffset or 0 + 1, 0, 0)
                            shape, minY, maxY, minZ, maxZ = findSplitShape(x, y, z, nx, ny, nz, yx, yy, yz,
                                spec.cutSizeY, spec.cutSizeZ)
                            if shape ~= 0 then
                                radius = math.max(maxY - minY, maxZ - minZ) * 0.5 * math.cos(angle)

                                -- #debug x1, y1, z1 = localToWorld(spec.cutNode, yOffset or 0 + 1, minY, minZ)
                                -- #debug x2, y2, z2 = localToWorld(spec.cutNode, yOffset or 0 + 1, minY, maxZ)
                                -- #debug x3, y3, z3 = localToWorld(spec.cutNode, yOffset or 0 + 1, maxY, minZ)
                                -- #debug Utils.renderTextAtWorldPosition((x1+x3) / 2, (y1+y3) / 2, (z1+z3) / 2, string.format("diam: %.1f/%.1f", math.deg(radius*2), math.deg(spec.cutMaxRadius*2)), getCorrectTextSize(0.012), 0)
                                -- #debug DebugUtil.drawDebugAreaRectangle(x1, y1, z1, x2, y2, z2, x3, y3, z3, false, 0,1,0)

                                if radius <= spec.cutMaxRadius then
                                    spec.warnInvalidTreeRadius = false
                                    spec.warnInvalidTreePosition = true
                                end
                            end
                        else
                            spec.tempDiameter = math.max(maxY - minY, maxZ - minZ)
                            spec.curSplitShape = shape

                            if skipCutAnimation then
                                self:setAnimationTime(spec.cutAnimation.name, 0, true)
                                spec.cutTimer = 0
                            end
                        end
                    end
                else
                    spec.warnTreeNotOwned = true
                end
            end
        else
            spec.tempDiameter = 0
        end
    end
end

function WHC:isTiltedUp()
    local spec = self.spec_woodHarvester

    return WHC.isTiltSupported(self) and spec.tiltedUp
end

function WHC:isTiltSupported()
    local spec = self.spec_woodHarvester

    return spec.cutReleasedComponentJoint ~= nil
end

function WHC:checkAutoProgramCut(mode)
    local spec = self.spec_woodHarvester

    if (WHC.isTiltedUp(self)) then
        return spec.autoProgramFellingCut == mode
    end

    return spec.autoProgramBuckingCut == mode
end

function WHC:isStandingTreeAttached()
    local spec = self.spec_woodHarvester

    return spec.attachedSplitShape ~= nil and getRigidBodyType(spec.attachedSplitShape) == RigidBodyType.STATIC
end

function WHC:isStandingTreeInRange()
    local spec = self.spec_woodHarvester

    return spec.attachedSplitShape == nil and spec.curSplitShape ~= nil and getRigidBodyType(spec.curSplitShape) ==
               RigidBodyType.STATIC
end

function WHC.playOpenHeadAnimation(self)
    local spec = self.spec_woodHarvester

    if spec.advancedOpenClose == true then
        WHC.playAnimation(self, "frontGrabAnimation")
        WHC.playAnimation(self, "backGrabAnimation")
        WHC.playAnimation(self, "rollersGrabAnimation")
    else
        WHC.playAnimation(self, "grabAnimation")
    end
end

function WHC:playCloseHeadAnimation(full, targetAnimTime)
    local spec = self.spec_woodHarvester

    if spec.advancedOpenClose == true then
        WHC.playAnimation(self, "frontGrabAnimation", 0, targetAnimTime)
        WHC.playAnimation(self, "backGrabAnimation", 0, targetAnimTime)

        if full == true then
            WHC.playAnimation(self, "rollersGrabAnimation", 0, targetAnimTime)
        end
    else
        WHC.playAnimation(self, "grabAnimation", 0, targetAnimTime)
    end
end

function WHC:stopCloseHeadAnimation(full)
    local spec = self.spec_woodHarvester

    if spec.advancedOpenClose == true then
        self:stopAnimation(spec.frontGrabAnimation.name, true)
        self:stopAnimation(spec.backGrabAnimation.name, true)

        if full == true then
            self:stopAnimation(spec.rollersGrabAnimation.name, true)
        end
    else
        self:stopAnimation(spec.grabAnimation.name, true)
    end
end

function WHC:playAnimation(animationKey, direction, targetAnimTime)
    local spec = self.spec_woodHarvester

    if spec[animationKey].name ~= nil then
        direction = direction or 1
        targetAnimTime = targetAnimTime or 1

        if spec[animationKey].speedScale < 0 then
            targetAnimTime = 1.0 - targetAnimTime
        end

        if direction == 0 then
            local currentAnimTime = self:getAnimationTime(spec[animationKey].name)
            if currentAnimTime < targetAnimTime and spec[animationKey].speedScale > 0 then
                direction = 1
            else
                direction = -1
            end
        end

        self:setAnimationStopTime(spec[animationKey].name, targetAnimTime)

        self:playAnimation(spec[animationKey].name, spec[animationKey].speedScale * direction,
            self:getAnimationTime(spec[animationKey].name), true)
    end
end
