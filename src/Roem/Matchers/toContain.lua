local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual, expected)
	return { pass = self.util:contains(actual, expected) }
end

return prototype
