local Matcher = require "Roem.Matcher"

local prototype = Matcher{}

function prototype:compare(actual)
	return { pass = (actual == nil or actual == false) }
end

return prototype
