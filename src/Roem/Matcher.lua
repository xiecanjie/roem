local Object = require "Roem.Object"
local Util   = require "Roem.Matchers.Util"

local prototype = Object{}

function prototype:initialize(util)
	self.util = util
end

function prototype:compare(actual, expected)
	error("not yet implemented")
end

function prototype:prettyPrint(value)
	return Util:prettyPrint(value)
end

return prototype
