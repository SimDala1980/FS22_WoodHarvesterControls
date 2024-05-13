WoodHarvesterControlsSetDiameterEvent = {}
local WoodHarvesterControlsSetDiameterEvent_mt = Class(WoodHarvesterControlsSetDiameterEvent, Event)

InitEventClass(WoodHarvesterControlsSetDiameterEvent, "WoodHarvesterControlsSetDiameterEvent")

function WoodHarvesterControlsSetDiameterEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsSetDiameterEvent_mt)

    return self
end

function WoodHarvesterControlsSetDiameterEvent.new(object, diameter)
    local self = WoodHarvesterControlsSetDiameterEvent.emptyNew()

    self.object = object
    self.diameter = diameter

    return self
end

function WoodHarvesterControlsSetDiameterEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteFloat32(streamId, self.diameter)
end

function WoodHarvesterControlsSetDiameterEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.diameter = streamReadFloat32(streamId)

    self:run(connection)
end

function WoodHarvesterControlsSetDiameterEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsSetDiameterEvent.new(self.object, self.diameter), nil, connection,
            self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:setLastTreeDiameter(self.diameter, true)
    end
end

function WoodHarvesterControlsSetDiameterEvent.sendEvent(object, diameter, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsSetDiameterEvent.new(object, diameter), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsSetDiameterEvent.new(object, diameter))
        end
    end
end
