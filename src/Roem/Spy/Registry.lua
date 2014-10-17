local Object = require "Roem.Object"
local Spy    = require "Roem.Spy"

local prototype = Object{}

function prototype:initialize(options)
	options = options or {}
	
	self.currentSpies = options.currentSpies or function()
		return {}
	end
end

function prototype:spyOn(object, name)
	if object == nil then
		error("spyOn could not find an object to spy upon for " .. name .. "()")
	end
	
	if object[name] == nil then
		error(name .. "() method does not exist")
	end
	
	if Spy:isSpy(object[name]) then
		error(name .. " has already been spied upon")
	end
	
	local spy = Spy:create(object, name)
	
	local entry = 
	{
		spy = spy, 
		object = object, 
		name = name, 
		original = object[name], 
	}
	table.insert(self.currentSpies(), entry)
	object[name] = spy
	
	return spy
end

function prototype:clearSpies()
	for _, entry in ipairs(self.currentSpies()) do
		entry.object[entry.name] = entry.original
	end
end

return prototype
