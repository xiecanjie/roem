local Matchers = require "Roem.Matchers"

describe("toBeTruthy", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes for 'truthy' values", function()
		local matcher = matchers["toBeTruthy"]()
		
		local result = matcher:compare(true)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare(1)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare("foo")
		expect(result.pass):toBe(true)
		
		local result = matcher:compare({})
		expect(result.pass):toBe(true)
	end)
	
	it("fails for 'falsy' values", function()
		local matcher = matchers["toBeTruthy"]()
		
		local result = matcher:compare(false)
		expect(result.pass):toBe(false)
		
		local result = matcher:compare(nil)
		expect(result.pass):toBe(false)
	end)
end)
