local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(sample)
	self.sample = sample
end

function prototype:matches(other, mismatchKeys, mismatchValues)
	local Util = require "Roem.Matchers.Util"
	
	if type(self.sample) ~= "table" then
		local fmt = "You must provide an object to objectContaining, not '%s'."
		error(string.format(fmt, tostring(self.sample)))
	end
	
	mismatchKeys = mismatchKeys or {}
	mismatchValues = mismatchValues or {}
	
	local hasKey = function(obj, key)
		return (obj[key] ~= nil)
	end
	
	for key, value in pairs(self.sample) do
		if not hasKey(other, key) then
			local fmt = "expected has key '%s', but missing from actual."
			table.insert(mismatchKeys, string.format(fmt, key))
		elseif not Util:equals(other[key], self.sample[key]) then
			local fmt = "'%s' was '%s' in actual, but was '%s' in expected."
			table.insert(mismatchValues, 
						 string.format(fmt, 
						 			   key, 
						 			   tostring(other[key]), 
									   tostring(self.sample[key])))
		end
	end
	
	return (table.empty(mismatchKeys) and table.empty(mismatchValues))
end

return prototype
