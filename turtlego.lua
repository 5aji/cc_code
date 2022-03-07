local turtlego = {}
turtlego.position = {x = 0, y = 0, z = 0, dir = 0};

local DIRS = {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

turtlego.setHome = function ()
	turtlego.position.x = 0
	turtlego.position.y = 0
	turtlego.position.z = 0
	turtlego.position.dir = DIRS.NORTH
end


turtlego.turnRight = function()
	turtle.turnRight()
	turtlego.position.dir = (turtlego.position.dir + 1) % 4
end

turtlego.turnLeft = function ()
	turtle.turnLeft()
	turtlego.position.dir = (turtlego.position.dir - 1) % 4
end

-- moves forward and increments position in proper direction
turtlego.moveForward = function ()
	result,err = turtle.forward() -- bool if true
	if (not result) then
		print("move failed: " .. err)
		return result, err
	end
	-- at this point we have moved
	if (turtlego.position.dir == DIRS.NORTH) then
		turtlego.position.z = turtlego.position.z - 1
	elseif (turtlego.position.dir == DIRS.EAST) then
		turtlego.position.x = turtlego.position.x + 1
	elseif (turtlego.position.dir == DIRS.SOUTH) then
		turtlego.position.z = turtlego.position.z + 1
	elseif (turtlego.position.dir == DIRS.WEST) then
		turtlego.position.x = turtlego.position.x - 1
	end
	return true
end

turtlego.setDirection = function(newDirection)
	while (newDirection ~= turtlego.position.dir) do
		turtlego.turnLeft()
	end
end


turtlego.moveTo = function (newPos)
	-- given position with x,y,z and dir, and our current position, we want to go there.
	
	-- for x
	while (newPos.x ~= turtlego.position.x) do
		if (newPos.x > turtlego.position.x) then
			turtlego.setDirection(DIRS.EAST)
			turtlego.moveForward()
		else 
			turtlego.setDirection(DIRS.WEST)
			turtlego.moveForward()
		end
	end
	while (newPos.z ~= turtlego.position.z) do
		if (newPos.z > turtlego.position.z) then
			turtlego.setDirection(DIRS.SOUTH)
			turtlego.moveForward()
		else 
			turtlego.setDirection(DIRS.NORTH)
			turtlego.moveForward()
		end
	end
end


return turtlego
