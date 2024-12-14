WoodHarvesterControlsUpdateSettingsEvent = {}
local WoodHarvesterControlsUpdateSettingsEvent_mt = Class(WoodHarvesterControlsUpdateSettingsEvent, Event)

InitEventClass(WoodHarvesterControlsUpdateSettingsEvent, "WoodHarvesterControlsUpdateSettingsEvent")

function WoodHarvesterControlsUpdateSettingsEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsUpdateSettingsEvent_mt)

    return self
end

function WoodHarvesterControlsUpdateSettingsEvent.new(object, settings)
    local self = WoodHarvesterControlsUpdateSettingsEvent.emptyNew()

    self.object = object
    self.settings = settings

    return self
end

function WoodHarvesterControlsUpdateSettingsEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)

    -- easy controls
    streamWriteBool(streamId, self.settings.autoProgramWithCut)
    streamWriteBool(streamId, self.settings.automaticTiltUp)
    streamWriteBool(streamId, self.settings.automaticOpen)
    streamWriteBool(streamId, self.settings.grabOnCut)

    -- bucking system
    streamWriteUIntN(streamId, self.settings.numberOfAssortments, 3)
    for i = 1, 4 do
        streamWriteFloat32(streamId, self.settings.bucking[i].minDiameter)
        streamWriteFloat32(streamId, self.settings.bucking[i].length)
    end

    -- automatic program
    streamWriteUIntN(streamId, self.settings.autoProgramFeeding, 3)
    streamWriteUIntN(streamId, self.settings.autoProgramFellingCut, 3)
    streamWriteUIntN(streamId, self.settings.autoProgramBuckingCut, 3)
    streamWriteBool(streamId, self.settings.autoProgramWithClose)
    streamWriteBool(streamId, self.settings.automaticFeedingOption)

    -- rotator options
    streamWriteUIntN(streamId, self.settings.rotatorMode, 3)
    streamWriteFloat32(streamId, self.settings.rotatorRotLimitForceLimit)
    streamWriteFloat32(streamId, self.settings.rotatorThreshold)

    -- saw options
    streamWriteUIntN(streamId, self.settings.sawMode, 3)

    -- length presets
    for i = 1, 4 do
        streamWriteFloat32(streamId, self.settings["lengthPreset" .. i])
    end
    streamWriteBool(streamId, self.settings.repeatLengthPreset)

    -- feeding options
    streamWriteFloat32(streamId, self.settings.breakingDistance)
    streamWriteBool(streamId, self.settings.slowFeedingTiltedUp)
    streamWriteFloat32(streamId, self.settings.feedingSpeed)
    streamWriteFloat32(streamId, self.settings.slowFeedingSpeed)

    -- tilt options
    streamWriteBool(streamId, self.settings.tiltDownOnFellingCut)
    streamWriteBool(streamId, self.settings.tiltUpWithOpenButton)
    streamWriteFloat32(streamId, self.settings.tiltUpDelay)
    streamWriteFloat32(streamId, self.settings.tiltMaxRot)

    -- user preferences
    streamWriteBool(streamId, self.settings.registerSound)
    streamWriteFloat32(streamId, self.settings.maxRemovingLength)
    streamWriteBool(streamId, self.settings.allSplitType)

end

function WoodHarvesterControlsUpdateSettingsEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)

    self.settings = {}

    -- easy controls
    self.settings.autoProgramWithCut = streamReadBool(streamId)
    self.settings.automaticTiltUp = streamReadBool(streamId)
    self.settings.automaticOpen = streamReadBool(streamId)
    self.settings.grabOnCut = streamReadBool(streamId)

    -- bucking system
    self.settings.numberOfAssortments = streamReadUIntN(streamId, 3)
    self.settings.bucking = {}
    for i = 1, 4 do
        self.settings.bucking[i] = {}
        self.settings.bucking[i].minDiameter = streamReadFloat32(streamId)
        self.settings.bucking[i].length = streamReadFloat32(streamId)
    end

    -- automatic program
    self.settings.autoProgramFeeding = streamReadUIntN(streamId, 3)
    self.settings.autoProgramFellingCut = streamReadUIntN(streamId, 3)
    self.settings.autoProgramBuckingCut = streamReadUIntN(streamId, 3)
    self.settings.autoProgramWithClose = streamReadBool(streamId)
    self.settings.automaticFeedingOption = streamReadBool(streamId)

    -- rotator options
    self.settings.rotatorMode = streamReadUIntN(streamId, 3)
    self.settings.rotatorRotLimitForceLimit = streamReadFloat32(streamId)
    self.settings.rotatorThreshold = streamReadFloat32(streamId)

    -- saw options
    self.settings.sawMode = streamReadUIntN(streamId, 3)

    -- length presets
    for i = 1, 4 do
        self.settings["lengthPreset" .. i] = streamReadFloat32(streamId)
    end
    self.settings.repeatLengthPreset = streamReadBool(streamId)

    -- feeding options
    self.settings.breakingDistance = streamReadFloat32(streamId)
    self.settings.slowFeedingTiltedUp = streamReadBool(streamId)
    self.settings.feedingSpeed = streamReadFloat32(streamId)
    self.settings.slowFeedingSpeed = streamReadFloat32(streamId)

    -- tilt options
    self.settings.tiltDownOnFellingCut = streamReadBool(streamId)
    self.settings.tiltUpWithOpenButton = streamReadBool(streamId)
    self.settings.tiltUpDelay = streamReadFloat32(streamId)
    self.settings.tiltMaxRot = streamReadFloat32(streamId)

    -- user preferences
    self.settings.registerSound = streamReadBool(streamId)
    self.settings.maxRemovingLength = streamReadFloat32(streamId)
    self.settings.allSplitType = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsUpdateSettingsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsUpdateSettingsEvent.new(self.object, self.settings), nil,
            connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:updateSettings(self.settings, true)
    end
end

function WoodHarvesterControlsUpdateSettingsEvent.sendEvent(object, settings, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsUpdateSettingsEvent.new(object, settings), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsUpdateSettingsEvent.new(object, settings))
        end
    end
end
