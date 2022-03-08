local tab = {}
tab.pos = {x = 0, y = 0, z = 0, dir = 0};

local DIRS = {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

tab.setHome = function ()
	tab.pos.x = 0
	tab.pos.y = 0
	tab.pos.z = 0
	tab.pos.dir = DIRS.NORTH
end


tab.turnRight = function()
	turtle.turnRight()
	tab.pos.dir = (tab.pos.dir + 1) % 4
end

tab.turnLeft = function ()
	turtle.turnLeft()
	tab.pos.dir = (tab.pos.dir - 1) % 4
end

-- moves forward and increments pos in proper direction
tab.moveForward = function ()
	result,err = turtle.forward() -- bool if true
	if (not result) then
		print("move failed: " .. err)
		return result, err
	end
	-- at this point we have moved
	if (tab.pos.dir == DIRS.NORTH) then
		tab.pos.z = tab.pos.z - 1
	elseif (tab.pos.dir == DIRS.EAST) then
		tab.pos.x = tab.pos.x + 1
	elseif (tab.pos.dir == DIRS.SOUTH) then
		tab.pos.z = tab.pos.z + 1
	elseif (tab.pos.dir == DIRS.WEST) then
		tab.pos.x = tab.pos.x - 1
	end
	return true
end
tab.moveBack = function ()
	result,err = turtle.back() -- bool if true
	if (not result) then
		print("move failed: " .. err)
		return result, err
	end
	-- at this point we have moved
	if (tab.pos.dir == DIRS.NORTH) then
		tab.pos.z = tab.pos.z + 1
	elseif (tab.pos.dir == DIRS.EAST) then
		tab.pos.x = tab.pos.x - 1
	elseif (tab.pos.dir == DIRS.SOUTH) then
		tab.pos.z = tab.pos.z - 1
	elseif (tab.pos.dir == DIRS.WEST) then
		tab.pos.x = tab.pos.x + 1
	end
	return true
end

tab.moveUp = function()
	result, err = turtle.up()
	if (not result) then
		print("up failed: " .. err)
		return result, err
	end
	tab.pos.y = tab.pos.y + 1
	return true
end
tab.moveDown = function()
	result, err = turtle.down()
	if (not result) then
		print("down failed: " .. err)
		return result, err
	end
	tab.pos.y = tab.pos.y - 1
	return true
end


tab.setDirection = function(newDirection)
	while (newDirection ~= tab.pos.dir) do
		tab.turnLeft()
	end
end


tab.moveAbs = function (newPos)
	-- given pos with x,y,z and dir, and our current pos, we want to go there.
	
	-- for x
	newPos.x = newPos.x or tab.pos.x
	while (newPos.x ~= tab.pos.x) do
		if (newPos.x > tab.pos.x) then
			tab.setDirection(DIRS.EAST)
			res = tab.moveForward()
			if (not res) then return false end
		else 
			tab.setDirection(DIRS.WEST)
			res = tab.moveForward()
			if (not res) then return false end
		end
	end
	newPos.z = newPos.z or tab.pos.z
	while (newPos.z ~= tab.pos.z) do
		if (newPos.z > tab.pos.z) then
			tab.setDirection(DIRS.SOUTH)
			res = tab.moveForward()
			if (not res) then return false end
		else 
			tab.setDirection(DIRS.NORTH)
			res =tab.moveForward()
			if (not res) then return false end
		end
	end
	newPos.y = newPos.y or tab.pos.y
	while (newPos.y ~= tab.pos.y) do
		if (newPos.y > tab.pos.y) then
			res = tab.moveUp()
			if (not res) then return false end
		else
			res = tab.moveDown()
			if (not res) then return false end
		end
	end
	return true
end

tab.goHome = function()
	tab.moveAbs({x = 0, y = 0, z = 0})
end

-- offset is a table of {forward = 0, right = 0, up = 0}
tab._moveRel = function(offset)
	
	offset.forward = offset.forward or 0
	local fmag = math.abs(offset.forward)
	for i = 1,fmag do
		if (offset.forward > 0) then
			res = tab.moveForward()
			if (not res) then return false end
		else
			res = tab.moveBack()
			if (not res) then return false end
		end
	end

	tab.turnRight()
	offset.right = offset.right or 0
	local rmag = math.abs(offset.right)
	for i = 1, rmag do
		if (offset.right > 0) then
			res = tab.moveForward()
			if (not res) then return false end
		else
			res = tab.moveBack()
			if (not res) then return false end
		end
	end
	
	offset.up = offset.up or 0 
	local umag = math.abs(offset.up)
	for i = 1, umag do
		if (offset.up > 0) then
			res = tab.moveUp()
			if (not res) then return false end
		else
			res = tab.moveDown()
			if (not res) then return false end
		end
	end

	tab.setDirection(oldDirection)
	return true
end	

tab.moveRel = function(offset)
	local oldDirection = tab.pos.dir

	res = tab._moveRel(offset)
	tab.setDirection(oldDirection)
	return res
end




return tab
