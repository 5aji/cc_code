local tg = require("turtlego")

-- assume we are at the home and orient ourself

for i = 0,4 do
	res, detail = turtle.inspect()
	if (res) then
		if detail.name == "minecraft:bricks" then
			turtle.turnRight()
			tg.setHome()
			break
		end
	end
	turtle.turnRight()
end

-- now we are oriented.

function depositWood()
	for i = 1,16 do
		local tab = turtle.getItemDetail(i)
		if tab and tab.name == "minecraft:birch_log" then
			turtle.select(i)
			local ok, err = turtle.dropUp()
			if not ok then
				print("error: " .. err)
			end
		end
	end
end

function getItemFromNetwork(item_name, amt)
	amt = amt or 64
  local item_counter = 0

	local modem = peripheral.find("modem")
	local chest_names = modem.getNamesRemote()
	local turtle_name = modem.getNameLocal()
	for _,name in ipairs(chest_names) do
		local chest = peripheral.wrap(name)
		local chest_inventory = chest.list()

		for i,chest_item in pairs(chest_inventory) do
			if chest_item.name == item_name then
        amt = amt - chest.pushItems(turtle_name, i, amt)
        if amt <= 0 then return true end
			end
		end
	end

  return false
end
function fellTree()
	-- chop in front, move forward
	turtle.select(1)
	turtle.dig()
	tg.moveForward()
	while true do
		local block, data = turtle.inspectUp()
		if (block and data.name == "minecraft:birch_log") then
			turtle.digUp()
			tg.moveUp()
		else
			break
		end
	end
	while tg.moveDown() do end
	tg.moveBack()
	turtle.select(2) -- two is birch saplings
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
while true do
	tg.moveAbs({ z = 5, x = 0, y = 0})

	tg.moveAbs({x = 1})
	tg.setDirection(2)

	while true do
		-- do we have tree?
		tg.setDirection(tg.DIRS.SOUTH)
  res, detail = turtle.inspect()
		if (res) then
			if (detail.name == "minecraft:birch_log") then
				-- felling routine
				print("chop chop")
				fellTree()
			end
		end

		-- goto next tree
		result = tg.moveRel({right = -2})
		if (not result) then
			print("hit end of row")
			-- try next row
   tg.setDirection(2)
			result = tg.moveRel({forward = -3})
			if (not result) then
				print("hit end of farm, collecting")
				break
			end
			-- else we go back to x = 1
			tg.moveAbs({x = 1})
			tg.setDirection(2)
		end
	end

	-- now go to collection point
	tg.moveAbs({x = 6, y = -2, z = 0})

	for i = 1,30 do
		os.sleep(10)
		turtle.suckDown()
	end
	tg.moveRel({up = 2})
	tg.goHome()

	-- deposit
	tg.setDirection(nav.DIRS.NORTH)
	turtle.select(1)
	-- refuel
	if (turtle.getFuelLevel() < 600) then
  print("refueling")
		turtle.refuel(10)
	end

	turtle.drop(turtle.getItemCount())
	os.sleep(5 * 60)
end
print("end of program")
