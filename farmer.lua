local nav = require("turtlego")

-- assume we are at the home and orient ourself

for i = 0,4 do
	res, detail = turtle.inspect()
	if (res) then
		if detail.name == "minecraft:bricks" then
			turtle.turnRight()
			nav.setHome()
			break
		end
	end
	turtle.turnRight()
end

-- now we are oriented.


function fellTree()
	-- chop in front, move forward
	turtle.dig()
	nav.moveForward()
	while true do
		local block, data = turtle.inspectUp()
		if (block and data.name == "minecraft:birch_log") then
			turtle.digUp()
			nav.moveUp()
		else
			break
		end
	end
	while nav.moveDown() do end
	nav.moveBack()
	turtle.select(2)
	if (turtle.getItemCount() > 1) then
		turtle.place()
	end
end


-- begin big loop
-- 1. go to first tree
-- 2. check if tree is there (minecraft:birch_log)
-- if tree is there, begin felling routine
-- after felling, replant.
-- go to next tree
-- if no more trees (hit wall or smth) then go to collection
-- wait for leaves to decay, collect loot 
-- deposit wood, apples, sticks.
-- refuel if necessary (check fuel)

nav.moveAbs({ z = 5, x = 1, y = 0})

nav.setDirection(2)
-- check if tree

while true do
res, detail = turtle.inspect()
if (res) then
	if (detail.name == "minecraft:birch_log") then
		-- felling routine
		print("chop chop")
		fellTree()
	end
end

-- goto next tree
result = nav.moveRel({right = -2})
if (not result) then
	print("hit something")
	break
end
end

-- now go to collection point
nav.moveAbs({x = 6, y = -2, z = 0})

for i = 1,6 do
	os.sleep(10)
	turtle.suckDown()
end
nav.moveRel({up = 2})
nav.goHome()

-- deposit
nav.setDirection(0)
turtle.select(1)
turtle.drop(turtle.getItemCount() - 1)
-- refuel

print("end of program")
