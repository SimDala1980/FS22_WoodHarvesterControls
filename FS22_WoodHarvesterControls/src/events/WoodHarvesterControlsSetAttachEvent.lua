WoodHarvesterControlsSetAttachEvent = {}
local WoodHarvesterControlsSetAttachEvent_mt = Class(WoodHarvesterControlsSetAttachEvent, Event)

InitEventClass(WoodHarvesterControlsSetAttachEvent, "WoodHarvesterControlsSetAttachEvent")

function WoodHarvesterControlsSetAttachEvent.emptyNew()
    local self = Event.new(WoodHarvesterControlsSetAttachEvent_mt)

    return self
end

function WoodHarvesterControlsSetAttachEvent.new(object, attach)
    local self = WoodHarvesterControlsSetAttachEvent.emptyNew()

    self.object = object
    self.attach = attach

    return self
end

function WoodHarvesterControlsSetAttachEvent:writeStream(streamId, connection)
    NetworkUtil.writeNodeObject(streamId, self.object)
    streamWriteBool(streamId, self.attach)
end

function WoodHarvesterControlsSetAttachEvent:readStream(streamId, connection)
    self.object = NetworkUtil.readNodeObject(streamId)
    self.attach = streamReadBool(streamId)

    self:run(connection)
end

function WoodHarvesterControlsSetAttachEvent:run(connection)
    if not connection:getIsServer() then
        g_server:broadcastEvent(WoodHarvesterControlsSetAttachEvent.new(self.object, self.attach), nil, connection,
            self.object)
    end

    if self.object ~= nil and self.object:getIsSynchronized() then
        self.object:setAttachStatus(self.attach, true)
    end
end

function WoodHarvesterControlsSetAttachEvent.sendEvent(object, attach, noEventSend)
    if noEventSend == nil or noEventSend == false then
        if g_server ~= nil then
            g_server:broadcastEvent(WoodHarvesterControlsSetAttachEvent.new(object, attach), nil, nil, object)
        else
            g_client:getServerConnection():sendEvent(WoodHarvesterControlsSetAttachEvent.new(object, attach))
        end
    end
end
