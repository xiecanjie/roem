local Matcher = require "Roem.Matcher"
local Spy     = require "Roem.Spy"

local prototype = Matcher{}

function prototype:compare(actual, ...)
	if not Spy:isSpy(actual) then
		error(string.format("Expected a spy, but got %s.", 
							self:prettyPrint(actual)))
	end
	
	if select("#", ...) ~= 0 then
		error("toHaveBeenCalled does not take arguments, use toHaveBeenCalledWith")
	end
	
	local result = {}
	result.pass = actual.calls:any()
	
	if result.pass then
		local fmt = "Expected spy %s not to have been called."
		result.message = string.format(fmt, actual.name)
	else
		local fmt = "Expected spy %s to have been called."
		result.message = string.format(fmt, actual.name)
	end
	
	return result
end

return prototype
