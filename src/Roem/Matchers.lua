local Object = require "Roem.Object"

local prototype = Object{}

function prototype:getCoreMatchers()
	local matchers = 
	{
		"toBe", 
		"toBeNil", 
		"toBeDefined", 
		"toBeTruthy", 
		"toBeFalsy", 
		"toBeCloseTo", 
		"toBeGreaterThan", 
		"toBeLessThan", 
		"toContain", 
		"toEqual", 
		"toMatch", 
		"toThrow", 
		"toHaveBeenCalled", 
		"toHaveBeenCalledWith", 
	}
	return list.depair(list.map(function(name)
		local matcher = require("Roem.Matchers." .. name)
		return { name, bind(matcher.new, matcher), }
	end, matchers))
end

return prototype
