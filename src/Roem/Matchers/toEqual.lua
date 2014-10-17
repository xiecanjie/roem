local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual, expected)
	local result = { pass = false }
	result.pass = self.util:equals(actual, expected)
	return result
end

return prototype
