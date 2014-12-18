local Object      = require "Roem.Object"
local Strategy    = require "Roem.Spy.Strategy"
local CallTracker = require "Roem.Spy.CallTracker"

local prototype = Object{}

function prototype:create(object, name, colonCall)
	local colonCall = (colonCall ~= false)
	local isObject = (name ~= nil)
	
	if not isObject then
		name = object
		object = {}
		object[name] = function()
		end
	end
	
	local spy = {}
	
	local mt = {}
	if isObject and colonCall then
		mt.__call = function(spy, object, ...)
			return spy.impl:call(...)
		end
	else
		mt.__call = function(spy, ...)
			return spy.impl:call(...)
		end
	end
	setmetatable(spy, mt)
	
	local impl = prototype:new(object, name, spy)
	spy.impl = impl
	spy.name = name
	spy.will = impl:getStrategy()
	spy.calls = impl:getCallTracker()
	return spy
end

function prototype:isSpy(value)
	return (type(value) == "table")
end

function prototype:initialize(object, name, spy)
	local original = object[name]
	local strategyData = 
	{
		spy = spy, 
		object = object, 
		original = original, 
	}
	self.strategy = Strategy:new(strategyData)
	self.callTracker = CallTracker:new()
	self.original = original
end

function prototype:call(...)
	local callData = { object = self, args = { ... }, }
	self.callTracker:track(callData)
	
	local returnValue = { self.strategy:exec(...) }
	callData.returnValue = returnValue
	return unpack(returnValue, 1, table.maxn(returnValue))
end

function prototype:getStrategy()
	return self.strategy
end

function prototype:getCallTracker()
	return self.callTracker
end

return prototype
