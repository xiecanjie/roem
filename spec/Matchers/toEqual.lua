local Matchers = require "Roem.Matchers"

describe("toEqual", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("delegates to equals function", function()
		local util = createSpyObject("delegated-equals", "equals")
		util.equals.will:returnValue(true)
		matcher = matchers["toEqual"](util)
		
		local result = matcher:compare(1, 1)
		
		expect(util.equals):toHaveBeenCalledWith(1, 1)
		expect(result.pass):toBe(true)
	end)
end)
