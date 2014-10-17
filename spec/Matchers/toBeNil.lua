local Matchers = require "Roem.Matchers"

describe("toBeNil", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes for nil", function()
		local matcher = matchers["toBeNil"]()
		local result = matcher:compare(nil)
		expect(result.pass):toBe(true)
	end)
	
	it("fails for non-nil", function()
		local matcher = matchers["toBeNil"]()
		local result = matcher:compare("foo")
		expect(result.pass):toBe(false)
	end)
end)
