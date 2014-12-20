local Matcher = require "Roem.Matcher"
local Spy     = require "Roem.Spy"

local prototype = Matcher{}

function prototype:compare(actual, ...)
	if not Spy:isSpy(actual) then
		error(string.format("Expected a spy, but got %s.", 
							self:prettyPrint(actual)))
	end
	
	if not actual.calls:any() then
		local result = { pass = false }
		local fmt = "Expected spy %s to have been called with %s but it was never called."
		result.message = string.format(fmt, actual.name, 
											self:prettyPrint({ ... }))
		return result
	end
	
	if self.util:contains(actual.calls:allArgs(), { ... }) then
		local result = { pass = true }
		local fmt = "Expected spy %s not to have been called with %s but it was."
		result.message = string.format(fmt, actual.name, 
											self:prettyPrint({ ... }))
		return result
	end
	
	local result = { pass = false }
	local fmt = "Expected spy %s to have been called with %s but actual calls were %s."
	local allArgs = setmetatable(actual.calls:allArgs(), nil)
	result.message = string.format(fmt, actual.name, 
										self:prettyPrint({ ... }), 
										self:prettyPrint(allArgs))
	return result
end

return prototype
