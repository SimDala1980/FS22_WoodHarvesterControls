--
-- Mod: WoodHarvesterControls
-- Author: Bargon Mods
-- Email: bargonmods@gmail.com
-- Date: 10/01/2023
-- Version: 1.2.0.0
--
-- this file is based on Wopster GuidanceSteering Mod
local directory = g_currentModDirectory
local modName = g_currentModName

g_woodHarvesterControlsModName = modName

source(Utils.getFilename("src/events/WoodHarvesterControlsCutButtonEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsTiltButtonsEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsGrabButtonsEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsButtonPressEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsSetDiameterEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsCutEffectsEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsDelimbEffectsEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsRegisterSoundEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsFindRegisterEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsSetDelimbEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsSetTiltEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsSetAttachEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsSetGrabEvent.lua", directory))
source(Utils.getFilename("src/events/WoodHarvesterControlsUpdateSettingsEvent.lua", directory))

source(Utils.getFilename("src/ui/WoodHarvesterControls_UI.lua", directory))

source(Utils.getFilename("src/WoodHarvesterControls_Main.lua", directory))

local woodHarvesterControls
local woodHarvesterControlsConfig = {}

local function isEnabled()
    return woodHarvesterControls ~= nil
end

function init()
    FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

    Mission00.load = Utils.prependedFunction(Mission00.load, loadMission)
    Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, loadedMission)

    TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, validateVehicleTypes)
end

function loadMission(mission)
    woodHarvesterControls = WoodHarvesterControls_Main:new(mission, directory, modName, g_i18n, g_gui,
        g_gui.inputManager, g_messageCenter)

    mission.woodHarvesterControls = woodHarvesterControls

    addModEventListener(woodHarvesterControls)
end

function loadedMission(mission, node)
    if not isEnabled() then
        return
    end

    if mission.cancelLoading then
        return
    end

    woodHarvesterControls:onMissionLoaded(mission)
end

function unload()
    if not isEnabled() then
        return
    end

    removeModEventListener(woodHarvesterControls)

    woodHarvesterControls:delete()
    woodHarvesterControls = nil -- Allows garbage collecting

    if g_currentMission ~= nil then
        g_currentMission.woodHarvesterControls = nil
    end
end

function validateVehicleTypes(typeManager)
    if typeManager.typeName == "vehicle" then
        WoodHarvesterControls_Main.installSpecializations(g_vehicleTypeManager, g_specializationManager, directory,
            modName)
    end
end

init()
