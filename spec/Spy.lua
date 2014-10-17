local Strategy    = require "Roem.Spy.Strategy"
local CallTracker = require "Roem.Spy.CallTracker"

describe("Spies", function ()
	describe("createSpy", function()
		it("adds a spyStrategy and callTracker to the spy", function()
			local spy = createSpy("someFunction")
			expect(spy.will):toEqual(any(Strategy))
			expect(spy.calls):toEqual(any(CallTracker))
		end)
		
		it("tracks the argument of calls", function()
			local spy = createSpy("someFunction")
			local trackSpy = spyOn(spy.calls, "track")
			
			spy("arg")
			
			expect(trackSpy.calls:mostRecent().args[1].args):toEqual({ "arg" })
		end)
		
		it("tracks the return value of calls", function()
			local spy = createSpy("someFunction")
			local trackSpy = spyOn(spy.calls, "track")
			
			spy.will:returnValue("return value")
			spy()
			
			expect(trackSpy.calls:mostRecent().args[1].returnValue):toEqual({ "return value" })
		end)
	end)
end)
