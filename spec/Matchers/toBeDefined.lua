local Matchers = require "Roem.Matchers"

describe("toBeDefined", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("matches for defined values", function()
		local matcher = matchers["toBeDefined"]()
		local result = matcher:compare("foo")
		expect(result.pass):toBe(true)
	end)
	
	it("fails when matching undefined values", function()
		local matcher = matchers["toBeDefined"]()
		local result = matcher:compare(nil)
		expect(result.pass):toBe(false)
	end)
end)
