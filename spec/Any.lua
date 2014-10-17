local Any = require "Roem.Any"

describe("Any", function()
	it("matches a boolean", function()
		local any = Any:new("boolean")
		expect(any:matches(true)):toBe(true)
	end)
	
	it("matches a number", function()
		local any = Any:new("number")
		expect(any:matches(1)):toBe(true)
	end)
	
	it("matches a string", function()
		local any = Any:new("string")
		expect(any:matches("foo")):toBe(true)
	end)
	
	it("matches a function", function()
		local any = Any:new("function")
		expect(any:matches(function()
		end)):toBe(true)
	end)
	
	it("matches an table", function()
		local any = Any:new("table")
		expect(any:matches({})):toBe(true)
	end)
	
	it("matches a object", function()
		local any = Any:new({ "foo", "bar", })
		expect(any:matches({ foo = 1, bar = 2, })):toBe(true)
	end)
end)
