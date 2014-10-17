local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(options)
	self.spy = options.spy
	self.object = options.object
	self.original = options.original
	
	self:stub()
end

function prototype:exec(...)
	return self.plan(...)
end

function prototype:callThrough()
	self.plan = bind(self.original, self.object)
	return self.spy
end

function prototype:returnValue(...)
	local result = { ... }
	self.plan = function()
		return unpack(result, 1, table.maxn(result))
	end
	return self.spy
end

function prototype:returnValues(...)
	local results = { ... }
	self.plan = function()
		if table.empty(results) then
			return
		end
		local result = table.remove(results, 1)
		return unpack(result, 1, table.maxn(result))
	end
	return self.spy
end

function prototype:throw(err)
	self.plan = function()
		error(err)
	end
	return self.spy
end

function prototype:callFake(fn)
	self.plan = fn
	return self.spy
end

function prototype:stub()
	self.plan = function()
	end
	return self.spy
end

return prototype
