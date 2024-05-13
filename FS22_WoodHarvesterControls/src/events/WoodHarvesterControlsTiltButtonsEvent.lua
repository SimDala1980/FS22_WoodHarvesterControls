WoodHarvesterControlsTiltButtonsEvent = {}
local WoodHarvesterControlsTiltButtonsEvent_mt = Class(WoodHarvesterControlsTiltButtonsEvent, Event)

InitEventClass(WoodHarvesterControlsTiltButtonsEvent, "WoodHarvesterControlsTiltButtonsEvent")

function WoodHarvesterControlsTiltButtonsEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsTiltButtonsEvent_mt)

    return self
end

function WoodHarvesterControlsTiltButtonsEvent.new(object, tiltType, isHolding)
    local self = WoodHarvesterControlsTiltButtonsEvent.emptyNew()

    self.object = object
    self.tiltType = tiltType
    self.isHolding = isHolding

    return self
end

function WoodHarvesterControlsTiltButtonsEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteUIntN(streamId, self.tiltType, 2)
    streamWriteBool(streamId, self.isHolding)
end

function WoodHarvesterControlsTiltButtonsEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.tiltType = streamReadUIntN(streamId, 2)
    self.isHolding = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsTiltButtonsEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsTiltButtonsEvent.new(self.object, self.tiltType, self.isHolding),
            nil, connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:onTiltButtons(self.tiltType, self.isHolding, true)
    end
end

function WoodHarvesterControlsTiltButtonsEvent.sendEvent(object, tiltType, isHolding, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsTiltButtonsEvent.new(object, tiltType, isHolding), nil, nil,
                object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsTiltButtonsEvent.new(object, tiltType,
                isHolding))
        end
    end
end
