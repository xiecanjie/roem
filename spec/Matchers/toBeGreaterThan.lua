local Matchers = require "Roem.Matchers"

describe("toBeGreaterThan", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes when actual > expected", function()
		local matcher = matchers["toBeGreaterThan"]()
		local result = matcher:compare(2, 1)
		expect(result.pass):toBe(true)
	end)
	
	it("fails when actual <= expected", function()
		local matcher = matchers["toBeGreaterThan"]()
		
		local result = matcher:compare(1, 1)
		expect(result.pass):toBe(false)
		
		local result = matcher:compare(1, 2)
		expect(result.pass):toBe(false)
	end)
end)
