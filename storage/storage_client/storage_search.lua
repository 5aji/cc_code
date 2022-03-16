local mass_storage = require("storage_api")
local interface_name = "minecraft:barrel_5"
local index

local search = function()
	local width, height = term.getSize()
	local scroll_window = window.create(term.current(), 1, 1, width, height - 1)
	scroll_window.clear()
	local input_window = window.create(term.current(), 1, height, width, 1)
	input_window.clear()
	local old_term = term.redirect(input_window)

	term.setTextColor(colors.orange)
	write("search> ")
	term.setTextColor(colors.white)
	local top_choice = nil
	local query = read(nil, nil, function(text)
		scroll_window.clear()

		local y = 1
		top_choice = nil
		for k,v in pairs(index) do
			if k ~= "empty" and string.find(string.lower(v.display_name), string.lower(text)) then
				scroll_window.setCursorPos(1, y)
				scroll_window.write(v.display_name)
				if top_choice == nil then top_choice = k end

				local count_str = tostring(v.count)

				scroll_window.setCursorPos(width - #count_str + 1, y)
				scroll_window.write(count_str)

				y = y + 1
			end

			if y > height - 1 then break end
		end
	end)
	term.redirect(old_term)

	return top_choice
end

while true do
	index = mass_storage.get_index()
	local name = search()

	print(name)
	write("Item count? ")
	local count = tonumber(read())

	if index[name] ~= nil and count ~= nil then
		mass_storage.get_items(interface_name, name, count)
	end
end
