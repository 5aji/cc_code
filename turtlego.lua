postion = {x = 0, y = 0, z = 0, dir = 0};

local DIRS = {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

function setHome()
	position.x = 0
	position.y = 0
	position.z = 0
	position.dir = DIRS.NORTH
end


function turnRight()
	turtle.turnRight()
	dir = (dir + 1) % 4
end
function turnLeft()
	turtle.turnLeft()
	dir = (dir - 1) % 4
end

-- moves forward and increments position in proper direction
function moveForward()
	result,err = turtle.forward() -- bool if true
	if (not result) then
		print("move failed: " .. err)
		return result, err
	end
	-- at this point we have moved
	if (dir == DIRS.NORTH) then
		postion.z = position.z - 1
	elseif (dir == DIRS.EAST) then
		postion.x = position.x + 1
	elseif (dir == DIRS.SOUTH) then
		postion.z = position.z + 1
	elseif (dir == DIRS.WEST) then
		postion.x = position.x - 1
	end
	return true
end

function setDirection(newDirection)
	while (newDirection ~= position.dir) do
		turnLeft()
	end
end


function moveTo(newPos)
	-- given position with x,y,z and dir, and our current position, we want to go there.
	
	-- for x
	while (newPos.x ~= position.x) do
		if (newPos.x > position.x) then
			setDirection(DIRS.EAST)
			moveForward()
		else 
			setDirection(DIRS.WEST)
			moveForward()
		end
	end
	while (newPos.z ~= position.z) do
		if (newPos.z > position.z) then
			setDirection(DIRS.NORTH)
			moveForward()
		else 
			setDirection(DIRS.SOUTH)
			moveForward()
		end
	end
end
