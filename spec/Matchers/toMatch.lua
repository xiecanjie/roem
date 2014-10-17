local Matchers = require "Roem.Matchers"

describe("toMatch", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes when pattern are equivalent", function()
		local matcher = matchers["toMatch"]()
		local result = matcher:compare("foo", "foo")
		expect(result.pass):toBe(true)
	end)
	
	it("fails when RegExps are not equivalent", function()
		local matcher = matchers["toMatch"]()
		local result = matcher:compare("bar", "foo")
		expect(result.pass):toBe(false)
	end)
	
	it("passes when the actual matches the expected string as a pattern", function()
		local matcher = matchers["toMatch"]()
		local result = matcher:compare("foosball", "foo")
		expect(result.pass):toBe(true)
	end)
	
	it("fails when the actual matches the expected string as a pattern", function()
		local matcher = matchers["toMatch"]()
		local result = matcher:compare("bar", "foo")
		expect(result.pass):toBe(false)
	end)
end)
