local Matchers = require "Roem.Matchers"

describe("toBe", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes when actual == expected", function()
		local matcher = matchers["toBe"]()
		local t = {}
		local result = matcher:compare(t, t)
		expect(result.pass):toBe(true)
	end)
	
	it("fails when actual ~= expected", function()
		local matcher = matchers["toBe"]()
		local result = matcher:compare({}, {})
		expect(result.pass):toBe(false)
	end)
end)
