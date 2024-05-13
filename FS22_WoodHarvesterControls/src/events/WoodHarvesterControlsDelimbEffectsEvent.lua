WoodHarvesterControlsDelimbEffectsEvent = {}
local WoodHarvesterControlsDelimbEffectsEvent_mt = Class(WoodHarvesterControlsDelimbEffectsEvent, Event)

InitEventClass(WoodHarvesterControlsDelimbEffectsEvent, "WoodHarvesterControlsDelimbEffectsEvent")

function WoodHarvesterControlsDelimbEffectsEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsDelimbEffectsEvent_mt)

    return self
end

function WoodHarvesterControlsDelimbEffectsEvent.new(object, sound, particles, forward)
    local self = WoodHarvesterControlsDelimbEffectsEvent.emptyNew()

    self.object = object
    self.sound = sound
    self.particles = particles
    self.forward = forward

    return self
end

function WoodHarvesterControlsDelimbEffectsEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.sound)
    streamWriteBool(streamId, self.particles)
    streamWriteBool(streamId, self.forward)
end

function WoodHarvesterControlsDelimbEffectsEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.sound = streamReadBool(streamId)
    self.particles = streamReadBool(streamId)
    self.forward = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsDelimbEffectsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsDelimbEffectsEvent.new(self.object, self.sound, self.particles,
            self.forward), nil, connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:handleDelimbEffects(self.sound, self.particles, self.forward, true)
    end
end

function WoodHarvesterControlsDelimbEffectsEvent.sendEvent(object, sound, particles, forward, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsDelimbEffectsEvent.new(object, sound, particles, forward), nil,
                nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsDelimbEffectsEvent.new(object, sound,
                particles, forward))
        end
    end
end
