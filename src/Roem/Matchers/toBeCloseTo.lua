local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual, expected, precision)
	local tolerance = math.pow(10, -(precision or 2)) / 2
	return { pass = (math.abs(expected - actual) < tolerance) }
end

return prototype
