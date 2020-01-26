addonName, NS = ...

NS.Commands = {}
local Commands = NS.Commands


local commandTbl = { desc=addonName, entries={} }

function Commands:CreateCategory(name, desc, cat)
	cat = cat or commandTbl
	cat.entries[name] = { desc=desc, entries={} }
	return cat.entries[name]
end

function Commands:AddCommand(name, desc, func, cat)
	assert(func ~= nil)
	cat = cat or commandTbl
	cat.entries[name] = { desc=desc, func=func }
end

-- help function
local function helpOn(entry)
	entry = entry or commandTbl

	print("Description:", entry.desc)

	-- this is a category
	if entry.entries ~= nil then
		print("Commands and Subcategories:")
		for name, cmd in pairs(entry.entries or commandTbl) do
			-- this is a command
			if cmd.func ~= nil then
				print(string.format("  |cff00cc66%s|r - %s", name, cmd.desc))
			-- this is a category
			else
				print(string.format("  |cffffff00%s|r - %s", name, cmd.desc))
			end
		end
	end
	
--	print(" ")
end

local function help(...)
	local args = {...}
	local foundArgs = {}
	local path = commandTbl

	for _, arg in ipairs(args) do
		arg = arg:lower()

		if path.entries~= nil and path.entries[arg] ~= nil then
			table.insert(foundArgs, arg)
			path = path.entries[arg]
		else
			break
		end
	end

	if #foundArgs > 0 then
		print(string.format("Help for |cff00cc66/wu %s|r:", table.concat(foundArgs, " ")))
	end
	helpOn(path)
end

local function HandleSlashCommands(str)
	if (#str == 0) then
		-- User entered "/wu" with no additional args.
		helpOn(commandTbl)
		return
	end	
	
	local args = {}
	for _, arg in ipairs({ string.split(" ", str) }) do
		if #arg > 0 then
			table.insert(args, arg)
		end
	end
	
	local path = commandTbl -- required for updating found table.

	for id, arg in ipairs(args) do
		arg = arg:lower()
		if path.entries ~= nil and path.entries[arg] ~= nil then
			path = path.entries[arg] -- sub-category found

			if path.func ~= nil then
				-- all remaining args passed to the function
				path.func(select(id + 1, unpack(args)))
				return
			end
		else
			-- does not exist!
			break
		end
	end

	print(string.format("|cffff0000'/wu %s' is not a viable command.|r", str))
	helpOn(path)
end

----------------------------------
-- Register Slash Commands
----------------------------------
Commands:AddCommand("help", "shows informations about slash commands", help)

function Commands:Register()
	SLASH_WarcraftUtils1 = "/wu"
	SlashCmdList.WarcraftUtils = HandleSlashCommands
end