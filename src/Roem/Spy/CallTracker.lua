local table  = require "std.table"
local list   = require "std.list"
local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize()
	self.calls = {}
end

function prototype:track(context)
	table.insert(self.calls, context)
end

function prototype:any()
	return not table.empty(self.calls)
end

function prototype:count()
	return #self.calls
end

function prototype:argsFor(index)
	local call = self.calls[index]
	return (call ~= nil and call.args or {})
end

function prototype:all()
	return self.calls
end

function prototype:allArgs()
	return list.project("args", self.calls)
end

function prototype:first()
	return self.calls[1]
end

function prototype:mostRecent()
	return self.calls[#self.calls]
end

function prototype:reset()
	self.calls = {}
end

return prototype
