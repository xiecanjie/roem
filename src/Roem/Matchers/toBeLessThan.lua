local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual, expected)
	return { pass = (actual < expected) }
end

return prototype
