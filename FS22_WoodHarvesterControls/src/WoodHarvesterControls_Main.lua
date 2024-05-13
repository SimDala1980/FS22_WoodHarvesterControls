--
-- Mod: WoodHarvesterControls
-- Author: Bargon Mods
-- Email: bargonmods@gmail.com
-- Date: 10/01/2023
-- Version: 1.2.0.0
-- 
-- this file is based on Wopster GuidanceSteering Mod
WoodHarvesterControls_Main = {}

local WoodHarvesterControls_Main_mt = Class(WoodHarvesterControls_Main)

function WoodHarvesterControls_Main:new(mission, modDirectory, modName, i18n, gui, inputManager, messageCenter)
    local self = {}

    setmetatable(self, WoodHarvesterControls_Main_mt)

    self.isServer = mission:getIsServer()
    self.isClient = mission:getIsClient()

    self.mission = mission

    self.modDirectory = modDirectory
    self.modName = modName

    return self
end

function WoodHarvesterControls_Main:onMissionLoaded(mission)
    g_gui:loadProfiles(self.modDirectory .. "src/ui/guiProfiles.xml")
    WoodHarvesterControls_Main.ui_menu = WoodHarvesterControls_UI:new(self.modName)
    g_gui:loadGui(self.modDirectory .. "src/ui/WoodHarvesterControls_UI.xml", "WoodHarvesterControls_UI",
        WoodHarvesterControls_Main.ui_menu)
end

function WoodHarvesterControls_Main.installSpecializations(vehicleTypeManager, specializationManager, modDirectory,
    modName)
    specializationManager:addSpecialization("woodHarvesterControls", "WoodHarvesterControls", Utils.getFilename(
        "src/specialization/WoodHarvesterControls.lua", modDirectory), nil) -- Nil is important here

    if specializationManager:getSpecializationByName("woodHarvesterControls") == nil then
        print("ERROR: woodHarvesterControls | Failed to add specialization")
    else
        for typeName, typeEntry in pairs(vehicleTypeManager:getTypes()) do
            if SpecializationUtil.hasSpecialization(WoodHarvester, typeEntry.specializations) then
                vehicleTypeManager:addSpecialization(typeName, modName .. ".woodHarvesterControls")
            end
        end

        -- ovewrite functions
        WoodHarvester.onLoad = Utils.overwrittenFunction(WoodHarvester.onLoad, WoodHarvesterControls.originalOnLoad)
        WoodHarvester.onLoadFinished = Utils.overwrittenFunction(WoodHarvester.onLoadFinished,
            WoodHarvesterControls.onLoadFinished)

        WoodHarvester.onReadStream = Utils.overwrittenFunction(WoodHarvester.onReadStream,
            WoodHarvesterControls.onReadStream)
        WoodHarvester.onWriteStream = Utils.overwrittenFunction(WoodHarvester.onWriteStream,
            WoodHarvesterControls.onWriteStream)
        WoodHarvester.onReadUpdateStream = Utils.overwrittenFunction(WoodHarvester.onReadUpdateStream,
            WoodHarvesterControls.onReadUpdateStream)
        WoodHarvester.onWriteUpdateStream = Utils.overwrittenFunction(WoodHarvester.onWriteUpdateStream,
            WoodHarvesterControls.onWriteUpdateStream)

        WoodHarvester.actionEventCutTree = Utils.overwrittenFunction(WoodHarvester.actionEventCutTree,
            WoodHarvesterControls.actionEventCutTree)
        WoodHarvester.onUpdateTick = Utils.overwrittenFunction(WoodHarvester.onUpdateTick,
            WoodHarvesterControls.onUpdateTick)
        WoodHarvester.onRegisterActionEvents = Utils.overwrittenFunction(WoodHarvester.onRegisterActionEvents,
            WoodHarvesterControls.onRegisterActionEvents)
        WoodHarvester.onCutTree = Utils.overwrittenFunction(WoodHarvester.onCutTree, WoodHarvesterControls.onCutTree)
        WoodHarvester.onUpdate = Utils.overwrittenFunction(WoodHarvester.onUpdate, WoodHarvesterControls.onUpdate)
        WoodHarvester.onDeactivate = Utils.overwrittenFunction(WoodHarvester.onDeactivate,
            WoodHarvesterControls.onDeactivate)
        WoodHarvester.onTurnedOn = Utils.overwrittenFunction(WoodHarvester.onTurnedOn, WoodHarvesterControls.onTurnedOn)
        WoodHarvester.onTurnedOff = Utils.overwrittenFunction(WoodHarvester.onTurnedOff,
            WoodHarvesterControls.onTurnedOff)

        -- woodHarvesterMeasurement compatibility
        if FS22_WoodHarvesterMeasurement ~= nil and FS22_WoodHarvesterMeasurement.WoodHarvesterMeasurement ~= nil then
            FS22_WoodHarvesterMeasurement.WoodHarvesterMeasurement.onUpdate = Utils.overwrittenFunction(
                FS22_WoodHarvesterMeasurement.WoodHarvesterMeasurement.onUpdate, WoodHarvesterControls.whmOnUpdate)
        end
    end
end

function WoodHarvesterControls_Main:delete()
    WoodHarvesterControls_Main.ui_menu:delete();
end
