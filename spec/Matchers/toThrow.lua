local Matchers = require "Roem.Matchers"

describe("toThrow", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("throws an error when the actual is not a function", function()
		local matcher = matchers["toThrow"]()
		expect(function()
			matcher:compare({})
			matcherComparator({})
		end):toThrow("Actual is not a function")
	end)
	
	it("fails if actual does not throw", function()
		local matcher = matchers["toThrow"]()
		local fn = function()
			return true
		end
		
		local result = matcher:compare(fn)
		
		expect(result.pass):toBe(false)
		expect(result.message):toEqual("Expected function to throw an exception.")
	end)
	
	it("passes if it throws but there is no expected", function()
		local util = createSpyObject("delegated-equal", "equals")
		util.equals.will:returnValue(true)
		local matcher = matchers:toThrow(util)
		local fn = function()
			error("5")
		end
		
		local result = matcher:compare(fn)
		
		expect(result.pass):toBe(true)
		expect(result.message):toEqual('Expected function not to throw, but it threw "5".')
	end)
	
	it("passes even if what is thrown is falsy", function()
		local matcher = matchers["toThrow"]()
		local fn = function()
			error(nil)
		end
		
		local result = matcher:compare(fn)
		
		expect(result.pass):toBe(true)
		expect(result.message):toEqual("Expected function not to throw, but it threw nil.")
	end)
	
	it("passes if what is thrown is equivalent to what is expected", function()
		local util = createSpyObject("delegated-equals", "equals")
		util.equals.will:returnValue(true)
		local matcher = matchers["toThrow"](util)
		local fn = function()
			error("5")
		end
		
		local result = matcher:compare(fn, "5")
		
		expect(result.pass):toBe(true)
		expect(result.message):toEqual('Expected function not to throw "5".')
	end)
	
	it("fails if what is thrown is not equivalent to what is expected", function()
		local util = createSpyObject("delegated-equals", "equals")
		util.equals.will:returnValue(false)
		local matcher = matchers["toThrow"](util)
		local fn = function()
			error("5")
		end
		
		local result = matcher:compare(fn, "foo")
		
		expect(result.pass):toBe(false)
		expect(result.message):toEqual('Expected function to throw "foo", but it threw "5".')
	end)
	
	it("fails if what is thrown is not equivalent to nil", function()
		local util = createSpyObject("delegated-equals", "equals")
		util.equals.will:returnValue(false)
		local matcher = matchers["toThrow"](util)
		local fn = function()
			error("5")
		end
		
		local result = matcher:compare(fn, nil)
		
		expect(result.pass):toBe(false)
		expect(result.message):toEqual('Expected function to throw nil, but it threw "5".')
	end)
end)
