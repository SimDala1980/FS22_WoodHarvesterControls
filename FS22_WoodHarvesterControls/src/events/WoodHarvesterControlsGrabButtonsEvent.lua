WoodHarvesterControlsGrabButtonsEvent = {}
local WoodHarvesterControlsGrabButtonsEvent_mt = Class(WoodHarvesterControlsGrabButtonsEvent, Event)

InitEventClass(WoodHarvesterControlsGrabButtonsEvent, "WoodHarvesterControlsGrabButtonsEvent")

function WoodHarvesterControlsGrabButtonsEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsGrabButtonsEvent_mt)

    return self
end

function WoodHarvesterControlsGrabButtonsEvent.new(object, grabType, isHolding)
    local self = WoodHarvesterControlsGrabButtonsEvent.emptyNew()

    self.object = object
    self.grabType = grabType
    self.isHolding = isHolding

    return self
end

function WoodHarvesterControlsGrabButtonsEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteUIntN(streamId, self.grabType, 2)
    streamWriteBool(streamId, self.isHolding)
end

function WoodHarvesterControlsGrabButtonsEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.grabType = streamReadUIntN(streamId, 2)
    self.isHolding = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsGrabButtonsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsGrabButtonsEvent.new(self.object, self.isHolding), nil, connection,
            self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:onGrabButtons(self.grabType, self.isHolding, true)
    end
end

function WoodHarvesterControlsGrabButtonsEvent.sendEvent(object, grabType, isHolding, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsGrabButtonsEvent.new(object, grabType, isHolding), nil, nil,
                object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsGrabButtonsEvent.new(object, grabType,
                isHolding))
        end
    end
end
