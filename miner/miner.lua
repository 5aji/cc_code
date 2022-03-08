local m = {}

local tArgs = { ... }
if #tArgs ~= 1 then
	print("Usage: miner <distance> <shape (optional)>")
	return
end

m.torchInterval = 26
m.shape = "line"
m.distance = tonumber(tArgs[1])
if m.distance < 1 then
	print("Excavate diameter must be positive")
	return
end

if #tArgs >= 2 then
	m.shape = tArgs[2]
	if not tArgs[2] == "line" or
		not tArgs[2] == "t" then
		error("Invalid shape: " .. tArgs[2])
	end
end


m.try_refuel = function()
	local ok, err
	local level = turtle.getFuelLevel()
	if level == "unlimited" then error("Turtle does not need refueling",0) end

	for i = 1,16 do
		assert(turtle.select(i))
		ok, err = turtle.refuel(1)
		if ok then
			local new_level = turtle.getFuelLevel()
			print(("Refuelled %d, current level is %d"):format(new_level-level,new_level))
		else
			printError(err)
		end
	end
	return false
end

m.go_up = function()
	local ok, err
	local blockAbove = turtle.detectUp()

	if blockAbove then
		ok, err = turtle.digUp()
		if not ok then
			error("Could not mine up: " .. err)
		end
	end

	ok, err = turtle.up()
	if not ok then
		error("Could not move up: " .. err)
	end

	return ok
end

m.go_forwards = function()
	local ok, err

	local blockFront = turtle.detect()

	if blockFront then
		ok, err = turtle.dig()
		if not ok then
			error("Could not mine: " .. err)
		end
	end

	ok, err = turtle.forward()
	if not ok then
		error("Could not move: " .. err)
	end

	return ok
end

m.turn = function(dir)
	local ok, err
	if dir == "left" then
		ok, err = turtle.turnLeft()
	elseif dir == "right" then
		ok, err = turtle.turnRight()
	else
		error("invalid turn direction")
		return
	end
	if not ok then
		error("Could not turn: " .. err)
	end
end

m.dig = function(dir)
	if not dir then dir = "forwards" end
	local ok, err
	if dir == "forwards" then
		ok, err = turtle.dig()
	elseif dir == "up" then
		ok, err = turtle.digUp()
	elseif dir == "down" then
		ok, err = turtle.digDown()
	end
end

m.mine_sides = function()
	m.turn("left")
	m.dig()
	m.turn("right")
	m.turn("right")
	m.dig()
	m.turn("left")
end

m.check_place_torch = function(travelled)
	if not travelled % m.torchInterval == 0 then
		return false
	end

	torchIdx = -1

	for i = 1,16 do
		local tab = turtle.getItemDetail(i)
		if tab and tab.name == "minecraft:torch" then
			torchIdx = i
		end
	end

	if torchIdx ~= -1 then
		turtle.select(torchIdx)
		turtle.placeDown()
	else
		error("No torch to place")
		return false
	end
end

m.check_place_chest = function()
	local chestIdx = -1
	-- check if there are any open inventory slots
	for i = 1,16 do
		local tab = turtle.getItemDetail(i)
		if not tab then
			return false
		elseif tab.name == "minecraft:chest" then
			chestIdx = i
		end
	end

	-- try to place a chest below
	if chestIdx ~= -1 then
		turtle.select(chestIdx)
		turtle.placeDown()

		for i = 1,16 do
			local tab = turtle.getItemDetail(i)
			if not tab or tab.name == "minecraft:chest" or tab.name == "minecraft:torch"
				then
				-- nothing
				do end
			else
				turtle.select(i)
				turtle.dropDown()
			end
		end
	end
end

m.execute = function ()
	-- go up one block if we aren't in the air already
	local isBlock, tab = turtle.inspectDown()
	if isBlock then
		m.go_up()
	end

	for travelled = 1,m.distance do
		if m.shape == "t" then
			m.mine_sides()
		end
		m.dig("down")
		m.check_place_chest()
		m.check_place_torch(travelled)
		m.go_forwards()
	end
end

m.execute()

return m
