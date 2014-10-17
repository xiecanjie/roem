local ReportDispatcher = require "Roem.ReportDispatcher"

describe("ReportDispatcher", function()
	it("builds an interface of requested methods", function()
		local dispatcher = ReportDispatcher:new({ "foo", "bar", "baz", })
		expect(dispatcher.foo):toBeDefined()
		expect(dispatcher.bar):toBeDefined()
		expect(dispatcher.baz):toBeDefined()
	end)
	
	it("dispatches requested methods to added reporters", function()
		local dispatcher = ReportDispatcher:new({ "foo", "bar", })
		local reporter = createSpyObject("reporter", "foo", "bar")
		local anotherReporter = createSpyObject("reporter", "foo", "bar")
		dispatcher:add(reporter)
		dispatcher:add(anotherReporter)
		
		dispatcher:foo(123, 456)
		expect(reporter.foo):toHaveBeenCalledWith(123, 456)
		expect(anotherReporter.foo):toHaveBeenCalledWith(123, 456)
		
		dispatcher:bar("a", "b")
		expect(reporter.bar):toHaveBeenCalledWith("a", "b")
		expect(anotherReporter.bar):toHaveBeenCalledWith("a", "b")
	end)
	
	it("does not dispatch to a reporter if the reporter doesn't accept the method", function()
		local dispatcher = ReportDispatcher:new({ "foo" })
		local reporter = createSpyObject("reporter", "baz")
		dispatcher:add(reporter)
		
		expect(function()
			dispatcher:foo(123, 456)
		end):no():toThrow()
	end)
end)
