local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(expectedType)
	self.expectedType = expectedType
end

function prototype:matches(value)
	if type(self.expectedType) == "table" then
		return self:checkPrototype(value)
	end
	
	return (self.expectedType == type(value))
end

--------------------------------------------------------------------------------
-- private

function prototype:checkPrototype(value)
	if getmetatable(self.expectedType) ~= nil then
		if self.expectedType.initialize ~= nil then
			return (self.expectedType.initialize == value.initialize)
		end
		return false
	end
	
	if type(value) ~= "table" then
		return false
	end
	
	for _, field in ipairs(self.expectedType) do
		if value[field] == nil then
			return false
		end
	end
	
	return true
end

return prototype
