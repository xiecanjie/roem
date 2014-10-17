local Matchers = require "Roem.Matchers"

describe("toHaveBeenCalled", function()
	local matchers = Matchers:getCoreMatchers()
	
	it("passes when the actual was called, with a custom .not fail message", function()
		local matcher = matchers["toHaveBeenCalled"]()
		local calledSpy = createSpy("called-spy")
		
		calledSpy()
		
		local result = matcher:compare(calledSpy)
		expect(result.pass):toBe(true)
		expect(result.message):toEqual("Expected spy called-spy not to have been called.")
	end)
	
	it("fails when the actual was not called", function()
		local matcher = matchers["toHaveBeenCalled"]()
		local uncalledSpy = createSpy("uncalled spy")
		local result = matcher:compare(uncalledSpy)
		expect(result.pass):toBe(false)
	end)
	
	it("throws an exception when the actual is not a spy", function()
		local matcher = matchers["toHaveBeenCalled"]()
		local fn = function()
		end
		expect(function()
			matcher:compare(fn)
		end):toThrow("Expected a spy, but got function.")
	end)
	
	it("throws an exception when invoked with any arguments", function()
		local matcher = matchers["toHaveBeenCalled"]()
		local spy = createSpy("sample spy")
		expect(function()
			matcher:compare(spy, "foo")
		end):toThrow("toHaveBeenCalled does not take arguments, use toHaveBeenCalledWith")
	end)
	
	it("has a custom message on failure", function()
		local matcher = matchers:toHaveBeenCalled()
		local spy = createSpy("sample-spy")
		local result = matcher:compare(spy)
		expect(result.message):toEqual("Expected spy sample-spy to have been called.")
	end)
end)
