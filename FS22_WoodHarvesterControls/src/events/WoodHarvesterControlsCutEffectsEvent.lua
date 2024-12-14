WoodHarvesterControlsCutEffectsEvent = {}
local WoodHarvesterControlsCutEffectsEvent_mt = Class(WoodHarvesterControlsCutEffectsEvent, Event)

InitEventClass(WoodHarvesterControlsCutEffectsEvent, "WoodHarvesterControlsCutEffectsEvent")

function WoodHarvesterControlsCutEffectsEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsCutEffectsEvent_mt)

    return self
end

function WoodHarvesterControlsCutEffectsEvent.new(object, sound, particles)
    local self = WoodHarvesterControlsCutEffectsEvent.emptyNew()

    self.object = object
    self.sound = sound
    self.particles = particles

    return self
end

function WoodHarvesterControlsCutEffectsEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.sound)
    streamWriteBool(streamId, self.particles)
end

function WoodHarvesterControlsCutEffectsEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.sound = streamReadBool(streamId)
    self.particles = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsCutEffectsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsCutEffectsEvent.new(self.object, self.sound, self.particles), nil,
            connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:handleCutEffects(self.sound, self.particles, true)
    end
end

function WoodHarvesterControlsCutEffectsEvent.sendEvent(object, sound, particles, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsCutEffectsEvent.new(object, sound, particles), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsCutEffectsEvent.new(object, sound, particles))
        end
    end
end
