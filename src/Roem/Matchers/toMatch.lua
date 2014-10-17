local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual, expected)
	return { pass = (string.match(actual, expected) ~= nil) }
end

return prototype
