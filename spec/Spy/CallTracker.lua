local CallTracker = require "Roem.Spy.CallTracker"

describe("CallTracker", function()
	it("tracks that it was called when executed", function()
		local callTracker = CallTracker:new()
		expect(callTracker:any()):toBe(false)
		
		callTracker:track({})
		expect(callTracker:any()):toBe(true)
	end)
	
	it("tracks that number of times that it is executed", function()
		local callTracker = CallTracker:new()
		expect(callTracker:count()):toEqual(0)
		
		callTracker:track({})
		expect(callTracker:count()):toEqual(1)
	end)
	
	it("tracks the params from each execution", function()
		local callTracker = CallTracker:new()
		
		callTracker:track({ args = {} })
		callTracker:track({ args = { 0, "foo", } })
		
		expect(callTracker:argsFor(1)):toEqual({})
		expect(callTracker:argsFor(2)):toEqual({ 0 , "foo", })
	end)
	
	it("returns any empty array when there was no call", function()
		local callTracker = CallTracker:new()
		expect(callTracker:argsFor(1)):toEqual({})
	end)
	
	it("allows access for the arguments for all calls", function()
		local callTracker = CallTracker:new()
		
		callTracker:track({ args = {} })
		callTracker:track({ args = { 0, "foo", } })
		
		expect(callTracker:allArgs()):toEqual({ {}, { 0, "foo", }, })
	end)
	
	it("tracks the context and arguments for each call", function()
		local callTracker = CallTracker:new()
		
		callTracker:track({ object = {}, args = {}, })
		callTracker:track({ object = {}, args = { 0, "foo", }, })
		
		expect(callTracker:all()[1]):toEqual({ object = {}, args = {}, })
		expect(callTracker:all()[2]):toEqual({ object = {}, args = { 0, "foo", }, })
	end)
	
	it("simplifies access to the arguments for the last (most recent) call", function()
		local callTracker = CallTracker:new()
		
		callTracker:track({})
		callTracker:track({ object = {}, args = { 0, "foo", }, })
		
		expect(callTracker:mostRecent()):toEqual({ object = {}, args = { 0, "foo", }, })
	end)
	
	it("returns a useful falsy value when there isn't a last (most recent) call", function()
		local callTracker = CallTracker:new()
		expect(callTracker:mostRecent()):toBeFalsy()
	end)
	
	it("simplifies access to the arguments for the first (oldest) call", function()
		local callTracker = CallTracker:new()
		
		callTracker:track({ object = {}, args = { 0, "foo", }, })
		
		expect(callTracker:first()):toEqual({ object = {}, args = { 0, "foo", }, })
	end)
	
	it("returns a useful falsy value when there isn't a first (oldest) call", function()
		local callTracker = CallTracker:new()
		expect(callTracker:first()):toBeFalsy()
	end)
	
	it("allows the tracking to be reset", function()
		local callTracker = CallTracker:new()
		
		callTracker:track({})
		callTracker:track({ object = {}, args = { 0, "foo", }, })
		callTracker:reset()
		
		expect(callTracker:any()):toBe(false)
		expect(callTracker:count()):toEqual(0)
		expect(callTracker:argsFor(0)):toEqual({})
		expect(callTracker:all()):toEqual({})
		expect(callTracker:mostRecent()):toBeFalsy()
	end)
end)
