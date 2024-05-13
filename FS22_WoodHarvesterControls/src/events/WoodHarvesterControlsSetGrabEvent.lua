WoodHarvesterControlsSetGrabEvent = {}
local WoodHarvesterControlsSetGrabEvent_mt = Class(WoodHarvesterControlsSetGrabEvent, Event)

InitEventClass(WoodHarvesterControlsSetGrabEvent, "WoodHarvesterControlsSetGrabEvent")

function WoodHarvesterControlsSetGrabEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsSetGrabEvent_mt)

    return self
end

function WoodHarvesterControlsSetGrabEvent.new(object, close, stop, full, targetAnimTime)
    local self = WoodHarvesterControlsSetGrabEvent.emptyNew()

    self.object = object
    self.close = close
    self.stop = stop
    self.full = full
    self.targetAnimTime = targetAnimTime

    return self
end

function WoodHarvesterControlsSetGrabEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.close)
    streamWriteBool(streamId, self.stop)
    streamWriteBool(streamId, self.full)
    streamWriteFloat32(streamId, self.targetAnimTime)

end

function WoodHarvesterControlsSetGrabEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.close = streamReadBool(streamId)
    self.stop = streamReadBool(streamId)
    self.full = streamReadBool(streamId)
    self.targetAnimTime = streamReadFloat32(streamId)

    self:run(connection)
end

function WoodHarvesterControlsSetGrabEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsSetGrabEvent.new(self.object, self.close, self.stop, self.full,
            self.targetAnimTime), nil, connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:setGrabStatus(self.close, self.stop, self.full, self.targetAnimTime, true)
    end
end

function WoodHarvesterControlsSetGrabEvent.sendEvent(object, close, stop, full, targetAnimTime, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsSetGrabEvent.new(object, close, stop, full, targetAnimTime),
                nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsSetGrabEvent.new(object, close, stop, full,
                targetAnimTime))
        end
    end
end
