WoodHarvesterControlsRegisterSoundEvent = {}
local WoodHarvesterControlsRegisterSoundEvent_mt = Class(WoodHarvesterControlsRegisterSoundEvent, Event)

InitEventClass(WoodHarvesterControlsRegisterSoundEvent, "WoodHarvesterControlsRegisterSoundEvent")

function WoodHarvesterControlsRegisterSoundEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsRegisterSoundEvent_mt)

    return self
end

function WoodHarvesterControlsRegisterSoundEvent.new(object, newRegister)
    local self = WoodHarvesterControlsRegisterSoundEvent.emptyNew()

    self.object = object
    self.newRegister = newRegister

    return self
end

function WoodHarvesterControlsRegisterSoundEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.newRegister)
end

function WoodHarvesterControlsRegisterSoundEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.newRegister = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsRegisterSoundEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsRegisterSoundEvent.new(self.object, self.newRegister), nil,
            connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:handleRegisterSound(self.newRegister, true)
    end
end

function WoodHarvesterControlsRegisterSoundEvent.sendEvent(object, newRegister, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsRegisterSoundEvent.new(object, newRegister), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsRegisterSoundEvent.new(object, newRegister))
        end
    end
end
