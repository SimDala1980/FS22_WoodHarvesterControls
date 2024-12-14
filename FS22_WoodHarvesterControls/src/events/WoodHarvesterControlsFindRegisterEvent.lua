WoodHarvesterControlsFindRegisterEvent = {}
local WoodHarvesterControlsFindRegisterEvent_mt = Class(WoodHarvesterControlsFindRegisterEvent, Event)

InitEventClass(WoodHarvesterControlsFindRegisterEvent, "WoodHarvesterControlsFindRegisterEvent")

function WoodHarvesterControlsFindRegisterEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsFindRegisterEvent_mt)

    return self
end

function WoodHarvesterControlsFindRegisterEvent.new(object, length)
    local self = WoodHarvesterControlsFindRegisterEvent.emptyNew()

    self.object = object
    self.length = length

    return self
end

function WoodHarvesterControlsFindRegisterEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteFloat32(streamId, self.length)
end

function WoodHarvesterControlsFindRegisterEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.length = streamReadFloat32(streamId)

    self:run(connection)
end

function WoodHarvesterControlsFindRegisterEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsFindRegisterEvent.new(self.object, self.length), nil, connection,
            self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:findRegister(self.length, true)
    end
end

function WoodHarvesterControlsFindRegisterEvent.sendEvent(object, length, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsFindRegisterEvent.new(object, length), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsFindRegisterEvent.new(object, length))
        end
    end
end
