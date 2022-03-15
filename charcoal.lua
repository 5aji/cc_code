-- goals
-- take excess wood from chest and convert it into charcoal put it in the top chest


-- steps:
-- count wood in left chest. put excess in furance to make charcoal
-- take charcoal from top chest and put it into fuel for furnace
-- extract charcoal from furnace output and put up top.

max_wood = 6 * 64 -- amount of wood that we want
woodchest = peripheral.wrap("left")
coalchest = peripheral.wrap("top")
furnace = peripheral.wrap("right")

function find(inv, name)
	for slot, item in pairs(inv.list()) do
		if item.name == name then
			return slot
		end
	end
	return -1
end

function takeExcess()
	wood_count = 0
	for slot, item in pairs(woodchest.list()) do
		if item.name == "minecraft:birch_log" then
			wood_count = wood_count + item.count
		end
	end
	print("wood count: " .. wood_count)
	if wood_count < max_wood then
		return
	end
	wood_to_process = 64

	slot = find(woodchest, "minecraft:birch_log")
	if (slot == -1) then
		printError("Couldn't find wood in wood chest")
	end
	sent = woodchest.pushItems(peripheral.getName(furnace), slot, wood_to_process, 1)
	wood_to_process = wood_to_process - sent

	print("process_wood")
end

-- keep the furnace topped up on fuel.
function fuelFurnace()
	current_fuel = furnace.getItemDetail(2)
	if current_fuel == nil then
		current_fuel = 0
	else
		current_fuel = current_fuel.count
	end
	if current_fuel < 5 then
		fuel_slot = find(coalchest, "minecraft:charcoal")
		if (fuel_slot == -1) then
			printError("couldn't find fuel")
		end
		furnace.pullItems(peripheral.getName(coalchest), fuel_slot, 5 - current_fuel, 2)
		print("refueled")
	end
end


function takeFuel()
	products = furnace.getItemDetail(3)
	if products == nil then
		return
	end
	products = products.count
	if products > 0 then
		res = furnace.pushItems(peripheral.getName(coalchest), 3)

		print("sent " .. res .. " charcoal to storage")
	end
end



print("starting routines")

-- parallel.waitForAll(lop(5, takeFuel), lop(2, fuelFurnace), lop(30, takeExcess))

while true do
	takeFuel()
	fuelFurnace()
	takeExcess()
	os.sleep(5)
end


print("finished")
