local Strategy = require "Roem.Spy.Strategy"

describe("SpyStrategy", function()
	it("stubs an original function, if provided", function()
		local original = createSpy("original")
		local strategy = Strategy:new{ original = original }
		
		strategy:exec()
		
		expect(original):no():toHaveBeenCalled()
	end)
	
	it("allows an original function to be called, passed through the params and returns it's value", function()
		local original = createSpy("original").will:returnValue(42)
		local strategy = Strategy:new{ original = original }
		strategy:callThrough()
		
		local returnValue = strategy:exec("foo")
		
		expect(original):toHaveBeenCalled()
		expect(original.calls:mostRecent().args):toEqual({ "foo" })
		expect(returnValue):toEqual(42)
	end)
	
	it("can return a specified value when executed", function()
		local original = createSpy("original")
		local strategy = Strategy:new{ original = original }
		strategy:returnValue(17)
		
		local returnValue = strategy:exec()
		
		expect(original):no():toHaveBeenCalled()
		expect(returnValue):toEqual(17)
	end)
	
	it("can return specified values in order specified when executed", function()
		local original = createSpy("original")
		local strategy = Strategy:new{ original = original }
		
		strategy:returnValues({ "value1" }, { "value2" }, { "value3" })
		
		expect(strategy:exec()):toEqual("value1")
		expect(strategy:exec()):toEqual("value2")
		expect(strategy:exec()):toEqual("value3")
		expect(strategy:exec()):toBeNil()
		expect(original):no():toHaveBeenCalled()
	end)
	
	it("allows an exception to be thrown when executed", function()
		local original = createSpy("original")
		local strategy = Strategy:new{ original = original }
		
		strategy:throw("bar")
		
		expect(function()
			strategy:exec()
		end):toThrow("bar")
		expect(original):no():toHaveBeenCalled()
	end)
	
	it("allows a fake function to be called instead", function()
		local original = createSpy("original")
		local fakeFn = createSpy("fake").will:returnValue(67)
		local strategy = Strategy:new{ original = original }
		strategy:callFake(fakeFn)
		
		local returnValue = strategy:exec()
		
		expect(original):no():toHaveBeenCalled()
		expect(returnValue):toEqual(67)
	end)
	
	it("allows a return to plan stubbing after another strategy", function()
		local original = createSpy("original")
		local fakeFn = createSpy("fake").will:returnValue(67)
		local strategy = Strategy:new{ original = original }
		local returnValue = nil
		
		strategy:callFake(fakeFn)
		returnValue = strategy:exec()
		expect(original):no():toHaveBeenCalled()
		expect(returnValue):toEqual(67)
		
		strategy:stub()
		returnValue = strategy:exec()
		expect(returnValue):toBeNil()
	end)
	
	it("returns the spy after changing the strategy", function()
		local spy = {}
		local spyFn = createSpy("spyFn").will:returnValue(spy)
		local strategy = Strategy:new{ spy = spy }
		
		expect(strategy:callThrough()):toBe(spy)
		expect(strategy:returnValue()):toBe(spy)
		expect(strategy:throw()):toBe(spy)
		expect(strategy:callFake()):toBe(spy)
		expect(strategy:stub()):toBe(spy)
	end)
end)
