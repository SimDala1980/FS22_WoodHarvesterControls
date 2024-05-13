WoodHarvesterControlsSetDelimbEvent = {}
local WoodHarvesterControlsSetDelimbEvent_mt = Class(WoodHarvesterControlsSetDelimbEvent, Event)

InitEventClass(WoodHarvesterControlsSetDelimbEvent, "WoodHarvesterControlsSetDelimbEvent")

function WoodHarvesterControlsSetDelimbEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsSetDelimbEvent_mt)

    return self
end

function WoodHarvesterControlsSetDelimbEvent.new(object, speed, manualFeedingForward, manualFeedingBackward)
    local self = WoodHarvesterControlsSetDelimbEvent.emptyNew()

    self.object = object
    self.speed = speed
    self.manualFeedingForward = manualFeedingForward
    self.manualFeedingBackward = manualFeedingBackward

    return self
end

function WoodHarvesterControlsSetDelimbEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteFloat32(streamId, self.speed)
    streamWriteBool(streamId, self.manualFeedingForward)
    streamWriteBool(streamId, self.manualFeedingBackward)
end

function WoodHarvesterControlsSetDelimbEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.speed = streamReadFloat32(streamId)
    self.manualFeedingForward = streamReadBool(streamId)
    self.manualFeedingBackward = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsSetDelimbEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsSetDelimbEvent.new(self.object, self.speed,
            self.manualFeedingForward, self.manualFeedingBackward), nil, connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:setDelimbStatus(self.speed, self.manualFeedingForward, self.manualFeedingBackward, true)
    end
end

function WoodHarvesterControlsSetDelimbEvent.sendEvent(object, speed, manualFeedingForward, manualFeedingBackward,
    noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsSetDelimbEvent.new(object, speed, manualFeedingForward,
                manualFeedingBackward), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsSetDelimbEvent.new(object, speed,
                manualFeedingForward, manualFeedingBackward))
        end
    end
end
