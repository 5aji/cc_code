local pretty = require("cc.pretty")

local protocol_name = "storage"

local mass_storage = { peripheral.find("minecraft:chest") }

local storage_table = { }
local storage_ops = { }

-- {{{ Table caching helpers
-- Save table to file
local save = function(table, name)
	local file = fs.open(name, "w")
	file.write(textutils.serialize(table, { compact = true }))
	file.close()
end

-- Load table from file
local load = function(name)
	local file = fs.open(name, "r")
	local data = file.readAll()
	file.close()
	return textutils.unserialize(data)
end
-- }}}

-- {{{ Health/status operations
-- Enumerate current contents
storage_ops.scan_mass_storage = function()
	storage_table = { }
	storage_table.empty = { }

	for _, chest in ipairs(mass_storage) do
		local size = chest.size()
		for i=size,1,-1 do
			--for i, item in pairs(chest.list()) do
			local item = chest.getItemDetail(i)

			local name = item and item.name or "empty"

			if not storage_table[name] then storage_table[name] = { } end
			table.insert(storage_table[name], {
				chest = peripheral.getName(chest),
				slot = i,
				item = item
			})
		end
	end
	save(storage_table, "storage_table.txt")
end

storage_ops.usage = function()
	local filled_num = 0
	local num_items = 0
	for k,v in pairs(storage_table) do
		if k ~= "empty" then
			filled_num = filled_num + #v
			num_items = num_items + 1
		end
	end

	return filled_num,
	filled_num + #storage_table.empty,
	num_items
end

storage_ops.get_index = function()
	local index = { }

	for k, v in pairs(storage_table) do
		if k ~= "empty" then
			-- Get total count
			local count = 0
			for _, slot in ipairs(v) do
				count = count + slot.item.count
			end

			index[k] = {
				count = count,
				display_name = v[1].item.displayName
			}
		end
	end

	return index
end
-- }}}

-- {{{ Item retrieval
-- Move items from mass storage to interface
storage_ops.get_items = function(interface_name, name, count)
	local interface_storage = peripheral.wrap(interface_name)
	local count_left = count

	local deleted = {}
	for i, filled_slot in ipairs(storage_table[name]) do
		count_taken = interface_storage.pullItems(filled_slot.chest, filled_slot.slot, count_left)

		count_left = count_left - count_taken

		-- Mark emptied elements for deletion
		filled_slot.item.count = filled_slot.item.count - count_taken
		if filled_slot.item.count <= 0 then
			deleted[i] = true
		end

		if count_left <= 0 then break end
	end

	-- Delete marked elements
	new_table = {}
	for i, filled_slot in ipairs(storage_table[name]) do
		if deleted[i] ~= true then
			table.insert(new_table, filled_slot)
		else
			filled_slot.item = nil
			table.insert(storage_table.empty, filled_slot)
		end
	end
	storage_table[name] = new_table

	-- Remove emptied item types
	if #storage_table[name] <= 0 then
		storage_table[name] = nil
	end

	save(storage_table, "storage_table.txt")
	return count - count_left
end
-- }}}

-- {{{ Item storage
-- Take interface slot to new storage slot
local new_slot = function(interface, interface_slot)
	new_slot = table.remove(storage_table.empty)
	new_slot.item = interface.getItemDetail(interface_slot)

	interface.pushItems(new_slot.chest, interface_slot, 64, new_slot.slot)

	if storage_table[new_slot.item.name] == nil then storage_table[new_slot.item.name] = { } end
	table.insert(storage_table[new_slot.item.name], new_slot)
end

local put_item = function(interface, interface_slot, item)
	-- Put items
	if storage_table[item.name] == nil then
		new_slot(interface, interface_slot)
	else
		-- Add to existing slots
		for _, slot in ipairs(storage_table[item.name]) do
			if slot.item.count < slot.item.maxCount then
				local num_taken = interface.pushItems(slot.chest, interface_slot,
				slot.item.maxCount - slot.item.count, slot.slot)

				item.count = item.count - num_taken
				slot.item.count = slot.item.count + num_taken
			end
		end

		-- Fill new slot if needed
		if item.count > 0 then
			new_slot(interface_slot)
		end
	end
end

storage_ops.put_item = function(interface_name, interface_slot)
	local interface_storage = peripheral.wrap(interface_name)
	local item = interface_storage.list()[interface_slot]

	put_item(interface_storage, interface_slot, item)
	save(storage_table, "storage_table.txt")
end

storage_ops.put_all_items = function(interface_name)
	local interface_storage = peripheral.wrap(interface_name)

	for i, item in pairs(interface_storage.list()) do
		put_item(interface_storage, i, item)
	end
	save(storage_table, "storage_table.txt")
end
-- }}}

local process_rednet_command = function()
	-- Wait for command
	local id, mesg = rednet.receive(protocol_name)
	pretty.pretty_print(mesg)

	if #mesg < 1 then
		rednet.send(id, { -1, "no function given" }, protocol_name)
		return
	end

	-- Perform command
	local func_name = table.remove(mesg, 1)

	if storage_ops[func_name] == nil then
		rednet.send(id, { -1, "function does not exist"})
		return
	end

	local resp = { storage_ops[func_name](unpack(mesg)) }

	pretty.pretty_print(resp)

	-- Send response
	rednet.send(id, resp, protocol_name)
end

-- Load or generate storage table
if fs.exists("storage_table.txt") then
	storage_table = load("storage_table.txt")
else
	storage_ops.scan_mass_storage()
end

-- Open and register to rednet
peripheral.find("modem", rednet.open)
rednet.host(protocol_name, "mass_storage")

while true do
	process_rednet_command()
end
