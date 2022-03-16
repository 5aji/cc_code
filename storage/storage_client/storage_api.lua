local protocol_name = "storage"
local server_name = "mass_storage"

local api = { }

peripheral.find("modem", rednet.open)
local host_id = rednet.lookup(protocol_name, server_name)

return setmetatable(api, {
	__index = function(table, key)
		local entry = rawget(table, key)

		if not entry then
			entry = function(...)
				local cmd = { key, unpack(arg) }

				rednet.send(host_id, cmd, protocol_name)

				local id, mesg = rednet.receive(protocol)

				return unpack(mesg)
			end
			rawset(table, key, entry)
		end
		return entry
	end
})
