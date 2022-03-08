local tArgs = { ... }
if #tArgs ~= 1 then
	print("Usage: miner <distance>")
	return
end

local distance = tonumber(tArgs[1])
if distance < 1 then
	print("Excavate diameter must be positive")
	return
end

local try_refuel = function()
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

local go_up = function()
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

local go_forwards = function()
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

local turn = function(dir)
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

local dig = function(dir)
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

local mine_sides = function()
	turn("left")
	dig()
	turn("right")
	dig("down")
	turn("right")
	dig()
	turn("left")
end

local execute = function ()
	local travelled = 0

	go_up()
	for i = 1,distance do
		mine_sides()
		go_forwards()
	end
end

execute()
