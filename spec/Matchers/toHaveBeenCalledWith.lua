local Matchers = require "Roem.Matchers"

describe("toHaveBeenCalledWith", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes when the actual was called with matching parameters", function()
		local util = createSpyObject("delegated-contains", "contains")
		util.contains.will:returnValue(true)
		local matcher = matchers["toHaveBeenCalledWith"](util)
		local calledSpy = createSpy("called-spy")
		
		calledSpy("a", "b")
		local result = matcher:compare(calledSpy, "a", "b")
		
		expect(result.pass):toBe(true)
		expect(result.message):toEqual("Expected spy called-spy not to have been called with {1=a,2=b} but it was.")
	end)
	
	it("fails when the actual was not called", function()
		local util = createSpyObject("delegated-contains", "contains")
		util.contains.will:returnValue(false)
		local matcher = matchers["toHaveBeenCalledWith"](util)
		local uncalledSpy = createSpy("uncalled spy")
		
		local result = matcher:compare(uncalledSpy)
		expect(result.pass):toBe(false)
		expect(result.message):toEqual("Expected spy uncalled spy to have been called with {} but it was never called.")
	end)
	
	it("fails when the actual was called with different parameters", function()
		local util = createSpyObject("delegated-contains", "contains")
		util.contains.will:returnValue(false)
		local matcher = matchers["toHaveBeenCalledWith"](util)
		local calledSpy = createSpy("called spy")
		
		calledSpy("a")
		calledSpy("c", "d")
		local result = matcher:compare(calledSpy, "a", "b")
		
		expect(result.pass):toBe(false)
		expect(result.message):toEqual("Expected spy called spy to have been called with {1=a,2=b} but actual calls were {1={1=a},2={1=c,2=d}}.")
	end)
	
	it("throws an exception when the actual is not a spy", function()
		local matcher = matchers["toHaveBeenCalledWith"]()
		local fn = function()
		end
		expect(function()
			matcher:compare(fn)
		end):toThrow("Expected a spy, but got function.")
	end)
end)
