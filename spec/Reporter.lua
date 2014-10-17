local Reporter = require "Roem.Reporter"

describe("Reporter", function()
	local out
	
	beforeEach(function()
		local output = ""
		
		out = {}
		
		function out:getWriter()
			return bind(self.write, self)
		end
		
		function out:write(s)
			output = output .. (s or "")
		end
		
		function out:getOutput()
			return output
		end
		
		function out:clear()
			output = ""
		end
	end)
	
	it("reports that the suite has started to the console", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		reporter:started()
		expect(out:getOutput()):toEqual("Started\n")
	end)
	
	it("reports a passing spec as a dot", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		reporter:specDone({ status = "passed" })
		expect(out:getOutput()):toEqual(".")
	end)
	
	it("reports a failing spec as an 'F'", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		reporter:specDone({ status = "failed" })
		expect(out:getOutput()):toEqual("F")
	end)
	
	it("reports a pending spec as a '*'", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		reporter:specDone({ status = "pending" })
		expect(out:getOutput()):toEqual("*")
	end)
	
	it("alerts user if there are no specs", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		reporter:started()
		out:clear()
		reporter:done()
		expect(out:getOutput()):toMatch("No specs found")
	end)
	
	it("reports a summary when done (singular spec)", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		
		reporter:started()
		reporter:specDone({ status = "passed" })
		
		out:clear()
		reporter:done()
		
		expect(out:getOutput()):toMatch("1 spec, 0 failures")
		expect(out:getOutput()):no():toMatch("0 pending specs")
		expect(out:getOutput()):toMatch("Finished")
	end)
	
	it("reports a summary when done (pluralized specs)", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		
		reporter:started()
		reporter:specDone({ status = "passed" })
		reporter:specDone({ status = "pending" })
		reporter:specDone
		{
			status = "failed", 
			description = "with a failing spec", 
			fullName = "A suite with a failing spec", 
			failedExpectations = 
			{
				{
					passed = false, 
					message = "Expected true to be false:", 
					expected = false, 
					actual = true, 
					stack = "foo\nbar\nbaz", 
				}
			}
		}
		
		out:clear()
		reporter:done()
		
		expect(out:getOutput()):toMatch("3 specs, 1 failure, 1 pending spec")
		expect(out:getOutput()):toMatch("Finished")
	end)
	
	it("reports a summary when done that includes stack traces for a failing suite", function()
		local reporter = Reporter:new({ output = out:getWriter() })
		
		reporter:started()
		reporter:specDone({ status = "passed" })
		reporter:specDone
		{
			status = "failed", 
			description = "with a failing spec", 
			fullName = "A suite with a failing spec", 
			failedExpectations = 
			{
				{
					passed = false, 
					message = "Expected true to be false:", 
					expected = false, 
					actual = true, 
					stack = "foo bar baz", 
				}
			}
		}
		
		out:clear()
		
		reporter:done()
		
		expect(out:getOutput()):toMatch("true to be false")
		expect(out:getOutput()):toMatch("foo bar baz")
	end)
	
	describe("onComplete callback", function()
		local onComplete
		local reporter
		
		beforeEach(function()
			onComplete = createSpy("onComplete")
			reporter = Reporter:new
			{
				output = out:getWriter(), 
				onComplete = onComplete, 
			}
			reporter:started()
		end)
		
		it("is called when the suite is done", function()
			reporter:done()
			expect(onComplete):toHaveBeenCalledWith(true)
		end)
		
		it("calls it with false if there are spec failures", function()
			reporter:specDone({ status = "failed", failedExpectations = {}, })
			reporter:done()
			expect(onComplete):toHaveBeenCalledWith(false)
		end)
		
		it("calls it with false if there are suite failures", function()
			reporter:specDone({ status = "passed" })
			reporter:suiteDone({ failedExpectations = { { message = "bananas" } } })
			reporter:done()
			expect(onComplete):toHaveBeenCalledWith(false)
		end)
	end)
end)
