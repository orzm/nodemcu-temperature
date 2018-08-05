local ow_pin = 3
local read_temp = 0
local device_number = 0

local mqtt_server = "example.com"
local mqtt_port = 1883
local mqtt_user = "test"
local mqtt_pwd = "test"
local mqtt_id = "nodemcu"
local mqtt_devid = "device"..device_number


ds18b20.setup(ow_pin)

publish_temp = function(client)
    tmr.alarm(0, 1000, 1, function()
        ds18b20.read(function(ind, rom, res, temp, tdec, par)
            read_temp = temp
        end, {})
        topic = '/'..mqtt_user..'/'..mqtt_id..'/'..mqtt_devid.."/temperature"
        client:publish(topic, read_temp, 0, 0, function(client) 
            print("> PUBLISH ["..topic.."]: "..read_temp) 
        end)
    end)
end

m = mqtt.Client(mqtt_id, 30, mqtt_user, mqtt_pwd)

-- register connect, offline and publish message receive callbacks
m:on("connect", function(client) print("Connected to broker") end)
m:on("offline", function(client) print("Disconnected") end)

m:on("message", function(client, topic, data)
    print(topic..":")
    if data ~=nil then
        print(data)
    end
end)

m:connect(mqtt_server, mqtt_port, 0, function(client)
        print("Connected to broker")
        publish_temp(client)
    end,
    function(client, reason)
    print("Failed, reason: "..reason)
end)

m:close()
