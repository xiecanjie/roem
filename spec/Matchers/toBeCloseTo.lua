local Matchers = require "Roem.Matchers"

describe("toBeCloseTo", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes when within two decimal places by default", function()
		local matcher = matchers["toBeCloseTo"]()
		
		local result = matcher:compare(0, 0)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare(0, 0.001)
		expect(result.pass):toBe(true)
	end)
	
	it("fails when not within two decimal places by default", function()
		local matcher = matchers["toBeCloseTo"]()
		local result = matcher:compare(0, 0.01)
		expect(result.pass):toBe(false)
	end)
	
	it("accepts an optional precision argument", function()
		local matcher = matchers["toBeCloseTo"]()
		
		local result = matcher:compare(0, 0.1, 0)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare(0, 0.0001, 3)
		expect(result.pass):toBe(true)
	end)
	
	it("rounds expected values", function()
		local matcher = matchers["toBeCloseTo"]()
		
		local result = matcher:compare(1.23, 1.229)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare(1.23, 1.226)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare(1.23, 1.225)
		expect(result.pass):toBe(true)
		
		local result = matcher:compare(1.23, 1.2249999)
		expect(result.pass):toBe(false)
		
		local result = matcher:compare(1.23, 1.234)
		expect(result.pass):toBe(true)
	end)
end)
