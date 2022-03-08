local pretty = require("cc.pretty")

local mass_storage = { peripheral.find("minecraft:chest") }
local interface_storage = peripheral.find("minecraft:barrel")
local storage_table = { }

-- Save table to file
local save = function(table, name)
  local file = fs.open(name, "w")
  file.write(textutils.serialize(table))
  file.close()
end

-- Load table from file
local load = function(name)
  local file = fs.open(name, "r")
  local data = file.readAll()
  file.close()
  return textutils.unserialize(data)
end

-- Enumerate current contents
local scan_mass_storage = function()
  storage_table = { }
  storage_table.empty = { }

  print("Scanning mass storage...")
  for _, chest in ipairs(mass_storage) do
    local size = chest.size()
    for i=size,1,-1 do
    --for i, item in pairs(chest.list()) do
      local item = chest.getItemDetail(i)

      local name = item and item.name or "empty"

      if not storage_table[name] then storage_table[name] = { } end
      table.insert(storage_table[name], {
        chest = peripheral.getName(chest),
        slot = i,
        item = item
      })
    end
  end
  print("Finished scanning.")
  save(storage_table, "storage_table.txt")
end

-- Move items from mass storage to interface
local get_items = function(name, count)
  local deleted = {}
  for i, filled_slot in ipairs(storage_table[name]) do
    count_taken = interface_storage.pullItems(filled_slot.chest, filled_slot.slot, count)

    count = count - count_taken

    -- Mark emptied elements for deletion
    filled_slot.item.count = filled_slot.item.count - count_taken
    if filled_slot.item.count <= 0 then
      deleted[i] = true
    end

    if count <= 0 then break end
  end

  -- Delete marked elements
  new_table = {}
  for i, filled_slot in ipairs(storage_table[name]) do
    if deleted[i] ~= true then table.insert(new_table, filled_slot) end
  end
  storage_table[name] = new_table

  -- Remove emptied item types
  if #storage_table[name] <= 0 then
    storage_table[name] = nil
  end

  if count > 0 then
    print("Could not retrieve requested number of items.")
  end

  save(storage_table, "storage_table.txt")
end

-- Take interface slot to new storage slot
local new_slot = function(interface_slot)
  new_slot = table.remove(storage_table.empty)
  new_slot.item = interface_storage.getItemDetail(interface_slot)

  interface_storage.pushItems(new_slot.chest, interface_slot, 64, new_slot.slot)

  if storage_table[new_slot.item.name] == nil then storage_table[new_slot.item.name] = { } end
  table.insert(storage_table[new_slot.item.name], new_slot)
end

local put_item = function(item, interface_slot)
  if storage_table[item.name] == nil then
    new_slot(interface_slot)
  else
    -- Add to existing slots
    for _, slot in ipairs(storage_table[item.name]) do
      if slot.item.count < slot.item.maxCount then
        local num_taken = interface_storage.pushItems(slot.chest, interface_slot,
          slot.item.maxCount - slot.item.count, slot.slot)

        item.count = item.count - num_taken
        slot.item.count = slot.item.count + num_taken
      end
    end

    -- Fill new slot if needed
    if item.count > 0 then
      new_slot(interface_slot)
    end
  end

end

local put_all_items = function()
  for i, item in pairs(interface_storage.list()) do
    put_item(item, i)
  end
  save(storage_table, "storage_table.txt")
end

local list_storage = function()
  str = ""
  for k,v in pairs(storage_table) do
    if k ~= nil and k ~= "empty" then
      str = str .. k .. " "
      local count = 0
      for _, slot in ipairs(v) do
        count = count + slot.item.count
      end
      str = str .. count .. '\n'
    end
  end
  local width, height = term.getCursorPos()
  textutils.pagedPrint(str, height - 2)
end

if fs.exists("storage_table.txt") then
  storage_table = load("storage_table.txt")
else
  scan_mass_storage()
end

local search = function()
  local width, height = term.getSize()
  local scroll_window = window.create(term.current(), 1, 1, width, height - 1)
  scroll_window.clear()
  local input_window = window.create(term.current(), 1, height, width, 1)
  input_window.clear()
  local old_term = term.redirect(input_window)

  write(">>> ")
  local top_choice = nil
  local query = read(nil, nil, function(text)
    scroll_window.clear()

    local y = 1
    top_choice = nil
    for k,v in pairs(storage_table) do
      if string.find(k, text) and k ~= "empty" then
        scroll_window.setCursorPos(1, y)
        scroll_window.write(k)
        if top_choice == nil then top_choice = k end

        local count = 0
        for _, slot in ipairs(v) do
          count = count + slot.item.count
        end
        local count_str = tostring(count)

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

-- {{{ Basic command UI
local show_help = function()
  print("Commands:")
  print("put     puts all items in input into system")
  print("get     get items from system")
  print("list    list contents of system")
  print("search  search and get items from system")
  print("scan    rescan system")
  print("help    show this message")
  print("exit    exits system")
end

show_help()
while true do
  write(">> ")
  local cmd = read()

  if cmd == "exit" then
    save(storage_table, "storage_table.txt")
    break
  elseif cmd == "put" then
    put_all_items()
  elseif cmd == "list" then
    list_storage()
  elseif cmd == "scan" then
    scan_mass_storage()
  elseif cmd == "get" then
    write("Item name? ")
    local name = read()
    write("Item count? ")
    local count = tonumber(read())

    if storage_table[name] ~= nil then
      get_items(name, count)
    elseif storage_table["minecraft:" .. name] ~= nil then
      get_items("minecraft:" .. name, count)
    else
      print("Invalid item or not in storage.")
    end
  elseif cmd == "help" then
    show_help()
  elseif cmd == "search" then
    local name = search()
    print(name)
    write("Item count? ")
    local count = tonumber(read())

    if storage_table[name] ~= nil then
      get_items(name, count)
    else
      print("Invalid item or not in storage.")
    end
  else
    print("Invalid command.")
  end
end
-- }}}
