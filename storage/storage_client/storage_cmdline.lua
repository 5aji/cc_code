local pretty = require("cc.pretty")
local mass_storage = require("storage_api")
local interface_name = "minecraft:barrel_5"

local show_help = function()
	print("Commands:")
	print("put     puts all items in input into system")
	print("list    list contents of system")
	print("usage   show storage system utilization")
	print("scan    rescan system")
	print("help    show this message")
end

term.clear()
show_help()
while true do
	term.setTextColor(colors.orange)
	write("storage> ")
	term.setTextColor(colors.white)
	local cmd = read()

	if cmd == "put" then
		mass_storage.put_all_items(interface_name)
	elseif cmd == "list" then
		pretty.pretty_print(mass_storage.get_index())
	elseif cmd == "scan" then
		mass_storage.scan_mass_storage()
	elseif cmd == "help" then
		show_help()
	elseif cmd == "usage" then
		local filled_num, total_num, num_items = mass_storage.usage()

		print(string.format("Filled %d of %d slots (%3.2f%%).",
			filled_num, total_num, filled_num / total_num * 100))
		print(string.format("%d unique items held.", num_items))
	else
		print("Invalid command.")
	end
end
