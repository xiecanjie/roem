local Object = require "Roem.Object"

local prototype = Object{}

function prototype:addCoreMatchers(matchers)
	for name, matcher in pairs(matchers) do
		self[name] = self:wrapCompare(name, matcher)
	end
end

function prototype:Factory(options)
	options = options or {}
	
	local expect = self:new(options)
	
	options.isNot = true
	local opposite = self:new(options)
	expect.no = function(self)
		return opposite
	end
	
	return expect
end

function prototype:initialize(options)
	options = options or {}
	
	local nop = function()
	end
	
	self.util = options.util or { buildFailureMessage = nop }
	self.actual = options.actual
	self.addExpectationResult = options.addExpectationResult or nop
	self.isNot = options.isNot
end

function prototype:wrapCompare(name, matcherFactory)
	return function(self, ...)
		local matcher = matcherFactory(self.util)
		local compare = function(...)
			return matcher:compare(...)
		end
		
		if self.isNot then
			if matcher.negativeCompare ~= nil then
				compare = function(...)
					return matcher:negativeCompare(...)
				end
			else
				local original = compare
				compare = function(...)
					local result = original(...)
					result.pass = not result.pass
					return result
				end
			end
		end
		
		local message = ""
		local result = compare(self.actual, ...)
		if not result.pass then
			if not result.message then
				message = self.util:buildFailureMessage(name, 
														self.isNot, 
														self.actual, 
														...)
			else
				message = result.message
			end
		end
		
		local expected = ...
		if select("#", ...) > 1 then
			expected = { ... }
		end
		
		local params = 
		{
			matcherName = name, 
			passed = result.pass, 
			message = message, 
			actual = self.actual, 
			expected = expected, 
		}
		self.addExpectationResult(result.pass, params)
	end
end

return prototype
