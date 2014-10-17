local Matchers = require "Roem.Matchers"

describe("toContain", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("delegates to Matchers.Util.contains", function()
		local util = createSpyObject("delegated-contains", "contains")
		util.contains.will:returnValue(true)
		local matcher = matchers["toContain"](util)
		local result = matcher:compare("ABC", "B")
		expect(util.contains):toHaveBeenCalledWith("ABC", "B")
		expect(result.pass):toBe(true)
	end)
end)
