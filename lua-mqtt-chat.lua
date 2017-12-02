--
-- lua-mqtt
-- Copyright (c) 2017 tacigar
--

local mqtt = require "mqtt"
local lapp = require "pl.lapp"

local args = lapp [[
Lua MQTT Chat
  -a,--addr (default "tcp://localhost:1883") Brocker Address
  -r,--room (string) RoomName
  -n,--name (default "<anonymous>") UserName
]]

local client = mqtt.AsyncClient {
	serverURI = args.addr,
	clientID  = args.name,
}

local function onMessageArrived(topicName, message)
	local segs = {}
	string.gsub(topicName, "([^//]+)", function(c)
		segs[#segs+1] = c
	end)

	local username = segs[#segs]
	io.write(string.format("\x1b[32m%12s: \x1b[33m%s\x1b[39m\x1b[49m\n",
		username, message.payload))
end

client:setCallbacks(nil, onMessageArrived, nil)
client:connect{}

local subTopicName = string.format("/chat/%s/+", args.room)
local pubTopicName = string.format("/chat/%s/%s", args.room, args.name)

client:subscribe(subTopicName, 1)

while true do
	local message = io.read()

	if message == ":quit" then
		break;
	end

	client:publish(pubTopicName, message)
end

client:disconnect(1000)
client:destroy()
