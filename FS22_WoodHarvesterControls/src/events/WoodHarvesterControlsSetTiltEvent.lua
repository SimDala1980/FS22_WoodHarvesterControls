WoodHarvesterControlsSetTiltEvent = {}
local WoodHarvesterControlsSetTiltEvent_mt = Class(WoodHarvesterControlsSetTiltEvent, Event)

InitEventClass(WoodHarvesterControlsSetTiltEvent, "WoodHarvesterControlsSetTiltEvent")

function WoodHarvesterControlsSetTiltEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsSetTiltEvent_mt)

    return self
end

function WoodHarvesterControlsSetTiltEvent.new(object, isUp, isForcedUp, isForcedDown)
    local self = WoodHarvesterControlsSetTiltEvent.emptyNew()

    self.object = object
    self.isUp = isUp
    self.isForcedUp = isForcedUp
    self.isForcedDown = isForcedDown

    return self
end

function WoodHarvesterControlsSetTiltEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.isUp, self.isForcedUp, self.isForcedDown)
end

function WoodHarvesterControlsSetTiltEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.isUp = streamReadBool(streamId)
    self.isForcedUp = streamReadBool(streamId)
    self.isForcedDown = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsSetTiltEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsSetTiltEvent.new(self.object, self.isUp, self.isForcedUp,
            self.isForcedDown), nil, connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:setTiltStatus(self.isUp, self.isForcedUp, self.isForcedDown, true)
    end
end

function WoodHarvesterControlsSetTiltEvent.sendEvent(object, isUp, isForcedUp, isForcedDown, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsSetTiltEvent.new(object, isUp, isForcedUp, isForcedDown), nil,
                nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsSetTiltEvent.new(object, isUp, isForcedUp,
                isForcedDown))
        end
    end
end
