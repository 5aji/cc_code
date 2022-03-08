local storage_map = {}
-- Load storage map table
local file = fs.open("storage_map.txt", "r")
local data = file.readAll()
file.close()
textutils.unserialize(storage_map)

-- Get args
local tArgs = { ... }
if ~((#tArgs == 3 and tArgs[2] == "get") or
     (#tArgs == 1 and tArgs[2] == "put")) then
	print("Usage: storage get <item> <count>")
	print("Usage: storage put <item>")
	return
end

--local current_depth = 0
--local current_dir = "forward"
local function goto_slot(item_table)
	-- Go down
	for i=1,item_table.depth do
		turtle.down()
	end

	-- Rotate
	if item_table.dir == "left" then
		turtle.turnLeft()
	else if item_table.dir == "right" then
		turtle.turnRight()
	else if item_table.dir == "backwards" then
		turtle.turnLeft()
		turtle.turnLeft()
	end
end

local function goto_home(item_table)
	-- Rotate back
	if item_table.dir == "left" then
		turtle.turnRight()
	else if item_table.dir == "right" then
		turtle.turnLeft()
	else if item_table.dir == "backwards" then
		turtle.turnLeft()
		turtle.turnLeft()
	end

	-- Go up
	for i=1,item_table.depth do
		turtle.up()
	end
end

if tArgs[1] == "get" then
	local item_table = storage_map[tArgs[2]]
	local item_count = tonumber(tArgs[3])

	if item_count > item_table.count then
		print("Not enough items in storage for request!")
		return
	end

	goto_slot(item_table)

	-- Get items
	turtle.suck(item_count)
	item_table.count = item_table.count - item_count

	goto_home(item_table)
else if tArgs[1] == "put" then
	local item_table = storage_map(turtle.getItemDetail().name)
	local item_count = turtle.getItemDetail().count

	goto_slot(item_table)

	turtle.drop()
	item_table.count = item_table.count + item_count

	goto_home(item_table)
end

-- Store storage map table
local file = fs.open("storage_map.txt", "w")
file.write(textutils.serialize(storage_map))
file.close()
