local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual, ...)
	local expected = ...
	
	if type(actual) ~= "function" then
		error("Actual is not a function")
	end
	
	local pass = { pass = true }
	local fail = { pass = false }
	
	local succ, err = pcall(actual)
	if succ then
		fail.message = "Expected function to throw an exception."
		return fail
	end
	
	local exception = self:getException(err)
	
	if select("#", ...) == 0 then
		local fmt = "Expected function not to throw, but it threw %s."
		pass.message = string.format(fmt, self:prettyPrint(exception))
		return pass
	end
	
	if self.util:equals(exception, expected) then
		local fmt = "Expected function not to throw %s."
		pass.message = string.format(fmt, self:prettyPrint(exception))
		return pass
	end
	
	local fmt = "Expected function to throw %s, but it threw %s."
	fail.message = string.format(fmt, self:prettyPrint(expected), 
									  self:prettyPrint(exception))
	return fail
end

function prototype:getException(err)
	if err == nil then
		return "<nil>"
	end
	
	if type(err) == "string" then
		local exception = string.match(err, "^.-:%d+: (.*)$")
		if exception ~= nil then
			return exception
		end
	end
	
	return err
end

return prototype
