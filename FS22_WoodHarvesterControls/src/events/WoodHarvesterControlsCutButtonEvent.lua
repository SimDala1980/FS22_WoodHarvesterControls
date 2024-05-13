WoodHarvesterControlsCutButtonEvent = {}
local WoodHarvesterControlsCutButtonEvent_mt = Class(WoodHarvesterControlsCutButtonEvent, Event)

InitEventClass(WoodHarvesterControlsCutButtonEvent, "WoodHarvesterControlsCutButtonEvent")

function WoodHarvesterControlsCutButtonEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsCutButtonEvent_mt)

    return self
end

function WoodHarvesterControlsCutButtonEvent.new(object, isSawRunning)
    local self = WoodHarvesterControlsCutButtonEvent.emptyNew()

    self.object = object
    self.isSawRunning = isSawRunning

    return self
end

function WoodHarvesterControlsCutButtonEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.isSawRunning)
end

function WoodHarvesterControlsCutButtonEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.isSawRunning = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsCutButtonEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsCutButtonEvent.new(self.object, self.isSawRunning), nil,
            connection, self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:onCutButton(self.isSawRunning, true)
    end
end

function WoodHarvesterControlsCutButtonEvent.sendEvent(object, isSawRunning, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsCutButtonEvent.new(object, isSawRunning), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsCutButtonEvent.new(object, isSawRunning))
        end
    end
end
