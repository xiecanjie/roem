local Context     = require "Roem.Context"
local Expectation = require "Roem.Expectation"
local Util        = require "Roem.Matchers.Util"

describe("Context integration", function()
	beforeEach(function()
		local failureMatcher = {}
		
		function failureMatcher:compare(actual, fullName, expectedFailures)
			local foundRunnable = false
			local expectations = true
			local foundFailures = {}
			
			for _, args in ipairs(actual.calls:allArgs()) do
				local args = args[1]
				if args.fullName == fullName then
					foundRunnable = true
					
					for _, failedExpectation in ipairs(args.failedExpectations) do
						table.insert(foundFailures, failedExpectation.message)
					end
					
					for i, expectedFailure in ipairs(expectedFailures) do
						local failure = foundFailures[i]
						
						local match = false
						if not match then
							match = (failure == expectedFailure)
						end
						if not match then
							match = (string.match(failure, expectedFailure) ~= nil)
						end
						
						expectations = expectations and match
					end
					
					break
				end
			end
			
			local message = 'The runnable "' .. fullName .. '" never finished'
			if foundRunnable then
				local fmt = 'Expected runnable "%s" to have failures %s but it had %s'
				message = string.format(fmt, fullName, 
											 Util:prettyPrint(expectedFailures), 
											 Util:prettyPrint(foundFailures))
			end
			
			local result = 
			{
				pass = foundRunnable and expectations,
				message = message, 
			}
			return result
		end
		
		Expectation:addCoreMatchers
		{
			toHaveFailedExpecationsForRunnable = function(util)
				return failureMatcher
			end, 
		}
	end)
		
	it("Suites execute as expected (no nesting)", function()
		local context = Context:new()
		local calls = {}
		local assertions = function()
			expect(calls):toEqual({ "with a spec", "and another spec", })
		end
		context:addReporter({ done = assertions })
		
		context:describe("A Suite", function()
			context:it("with a spec", function()
				table.insert(calls, "with a spec")
			end)
			context:it("and another spec", function()
				table.insert(calls, "and another spec")
			end)
		end)
		
		context:execute()
	end)
	
	it("Nested Suites execute as expected", function()
		local context = Context:new()
		local calls = {}
		local assertions = function()
			local expected = 
			{
				"an outer spec", 
				"an inner spec", 
				"another inner spec", 
			}
			expect(calls):toEqual(expected)
		end
		context:addReporter({ done = assertions })
		
		context:describe("Outer suite", function()
			context:it("an outer spec", function()
				table.insert(calls, "an outer spec")
			end)
			context:describe("Inner suite", function()
				context:it("an inner spec", function()
					table.insert(calls, "an inner spec")
				end)
				context:it("another inner spec", function()
					table.insert(calls, "another inner spec")
				end)
			end)
		end)
		
		context:execute()
	end)
	
	it("Multiple top-level Suites execute as expected", function()
		local context = Context:new()
		local calls = {}
		local assertions = function()
			local expected = 
			{
				"an outer spec",
				"an inner spec",
				"another inner spec",
				"a 2nd outer spec",
			}
			expect(calls):toEqual(expected)
		end
		context:addReporter({ done = assertions })
		
		context:describe("Outer suite", function()
			context:it("an outer spec", function()
				table.insert(calls, "an outer spec")
			end)
			context:describe("Inner suite", function()
				context:it("an inner spec", function()
					table.insert(calls, "an inner spec")
				end)
				context:it("another inner spec", function()
					table.insert(calls, "another inner spec")
				end)
			end)
		end)
		
		context:describe("Another outer suite", function()
			context:it("a 2nd outer spec", function()
				table.insert(calls, "a 2nd outer spec")
			end)
		end)
		
		context:execute()
	end)
	
	it("explicitly fails a spec", function(done)
		local context = Context:new()
		local reporter = createSpyObject("reporter", "specDone")
		context:addReporter(reporter)
		
		context:describe("failing", function()
			context:it("has a default message", function()
				context:fail()
			end)
			
			context:it("specifies a message", function()
				context:fail("messy message")
			end)
		end)
		
		context:execute()
		
		local expected = objectContaining
		{
			description = "has a default message",
			failedExpectations = { objectContaining{ message = "Failed" } }, 
		}
		expect(reporter.specDone):toHaveBeenCalledWith(expected)
		
		local expected = objectContaining
		{
			description = "specifies a message",
			failedExpectations = { objectContaining({ message = "Failed: messy message" }) }, 
		}
		expect(reporter.specDone):toHaveBeenCalledWith(expected)
	end)
	
	it("calls associated beforeAlls/afterAlls only once per suite", function()
		local context = Context:new()
		local before = createSpy("beforeAll")
		local after = createSpy("afterAll")
		
		context:describe("with beforeAll and afterAll", function()
			context:it("spec", function()
				expect(before):toHaveBeenCalled()
				expect(after):no():toHaveBeenCalled()
			end)
			
			context:it("another spec", function()
				expect(before):toHaveBeenCalled()
				expect(after):no():toHaveBeenCalled()
			end)
			
			context:beforeAll(before)
			context:afterAll(after)
		end)
		
		context:execute()
		
		expect(after):toHaveBeenCalled()
		expect(after.calls:count()):toBe(1)
		expect(before.calls:count()):toBe(1)
	end)
	
	it("fails all underlying specs when the beforeAll fails", function()
		local context = Context:new()
		local reporter = createSpyObject("fakeReporter", "specDone", "done")
		
		reporter.done.will:callFake(function()
			expect(reporter.specDone.calls:count()):toEqual(2)
			
			local args = reporter.specDone.calls:argsFor(1)
			expect(args[1]):toEqual(objectContaining({ status = "failed" }))
			expect(args[1].failedExpectations[1].message):toEqual("Expected 1 to be 2.")
			
			local args = reporter.specDone.calls:argsFor(2)
			expect(args[1]):toEqual(objectContaining({ status = "failed" }))
			expect(args[1].failedExpectations[1].message):toEqual("Expected 1 to be 2.")
		end)
		
		context:addReporter(reporter)
		
		context:describe("A suite", function()
			context:beforeAll(function()
				context:expect(1):toBe(2)
			end)
			
			context:it("spec that will be failed", function()
			end)
			
			context:describe("nesting", function()
				context:it("another spec to fail", function()
				end)
			end)
		end)
		
		context:execute()
	end)
	
	describe("suiteDone reporting", function()
		it("reports when an afterAll fails an expectation", function()
			local context = Context:new()
			local reporter = createSpyObject("fakeReport", "done", "suiteDone")
			
			reporter.done.will:callFake(function()
				local exceptions = 
				{
					"Expected 1 to equal 2.", 
					"Expected 2 to equal 3.", 
				}
				expect(reporter.suiteDone):toHaveFailedExpecationsForRunnable("my suite", exceptions)
			end)
			
			context:addReporter(reporter)
			
			context:describe("my suite", function()
				context:it("my spec", function()
				end)
				
				context:afterAll(function()
					context:expect(1):toEqual(2)
					context:expect(2):toEqual(3)
				end)
			end)
			
			context:execute()
		end)
		
		it("if there are no specs, it still reports correctly", function()
			local context = Context:new()
			local reporter = createSpyObject("fakeReport", "done", "suiteDone")
			
			reporter.done.will:callFake(function()
				local exceptions = 
				{
					"Expected 1 to equal 2.", 
					"Expected 2 to equal 3.", 
				}
				expect(reporter.suiteDone):toHaveFailedExpecationsForRunnable("outer suite", exceptions)
			end)
			
			context:addReporter(reporter)
			
			context:describe("outer suite", function()
				context:describe("inner suite", function()
					context:it("spec", function()
					end)
				end)
				
				context:afterAll(function()
					context:expect(1):toEqual(2)
					context:expect(2):toEqual(3)
				end)
				
				context:execute()
			end)
		end)
		
		it("reports when afterAll throws an exception", function()
			local context = Context:new()
			local exception = "After All Exception"
			local reporter = createSpyObject("fakeReport", "done", "suiteDone")
			
			reporter.done.will:callFake(function()
				local exceptions = 
				{
					"After All Exception", 
				}
				expect(reporter.suiteDone):toHaveFailedExpecationsForRunnable("my suite", exceptions)
			end)
			
			context:addReporter(reporter)
			
			context:describe("my suite", function()
				context:it("my spec", function()
				end)
				
				context:afterAll(function()
					error("After All Exception")
				end)
			end)
			
			context:execute()
		end)
	
		it("reports when an async afterAll fails an expectation", function()
			local context = Context:new()
			local reporter = createSpyObject("fakeReport", "done", "suiteDone")
			
			reporter.done.will:callFake(function()
				local exceptions = 
				{
					"Expected 1 to equal 2.", 
				}
				expect(reporter.suiteDone):toHaveFailedExpecationsForRunnable("my suite", exceptions)
			end)
			
			context:addReporter(reporter)
			
			context:describe("my suite", function()
				context:it("my spec", function()
				end)
				
				context:afterAll(function(afterAllDone)
					context:expect(1):toEqual(2)
					afterAllDone()
				end)
			end)
			
			context:execute()
		end)
			
		it("reports when an async afterAll throws an exception", function()
			local context = Context:new()
			local reporter = createSpyObject("fakeReport", "done", "suiteDone")
			
			reporter.done.will:callFake(function()
				local exceptions = 
				{
					"After All Exception", 
				}
				expect(reporter.suiteDone):toHaveFailedExpecationsForRunnable("my suite", exceptions)
			end)
			
			context:addReporter(reporter)
			
			context:describe("my suite", function()
				context:it("my spec", function()
				end)
				
				context:afterAll(function(afterAllDone)
					error("After All Exception")
				end)
			end)
			
			context:execute()
		end)
	end)
	
	it("Functions can be spied on and have their calls tracked", function ()
		local context = Context:new()
		
		local originalFunctionWasCalled = false
		local subject = 
		{
			spiedFunc = function(self)
				originalFunctionWasCalled = true
				return "original result"
			end, 
		}
		
		context:it("works with spies", function()
			local spy = context:spyOn(subject, "spiedFunc").will:returnValue("stubbed result")
			
			expect(subject.spiedFunc):toEqual(spy)
			expect(subject.spiedFunc.calls:any()):toEqual(false)
			expect(subject.spiedFunc.calls:count()):toEqual(0)
			
			subject:spiedFunc("foo")
			
			expect(subject.spiedFunc.calls:any()):toEqual(true)
			expect(subject.spiedFunc.calls:count()):toEqual(1)
			expect(subject.spiedFunc.calls:mostRecent().args):toEqual({ "foo" })
			expect(subject.spiedFunc.calls:mostRecent().returnValue):toEqual({ "stubbed result" })
			expect(originalFunctionWasCalled):toEqual(false)
			
			subject.spiedFunc.will:callThrough()
			subject:spiedFunc("bar")
			expect(subject.spiedFunc.calls:count()):toEqual(2)
			expect(subject.spiedFunc.calls:mostRecent().args):toEqual({ "bar" })
			expect(subject.spiedFunc.calls:mostRecent().returnValue):toEqual({ "original result" })
			expect(originalFunctionWasCalled):toEqual(true)
		end)
		
		context:execute()
	end)
	
	it("removes all spies added in a spec after the spec is complete", function()
		local context = Context:new()
		local originalFoo = function(self)
		end
		local testObj = { foo = originalFoo }
		local firstSpec = createSpy("firstSpec").will:callFake(function()
			context:spyOn(testObj, "foo")
		end)
		local secondSpec = createSpy("secondSpec").will:callFake(function()
			expect(testObj.foo):toBe(originalFoo)
		end)
		
		context:describe("test suite", function()
			context:it("spec 0", firstSpec)
			context:it("spec 1", secondSpec)
		end)
		
		local assertions = function()
			expect(firstSpec):toHaveBeenCalled()
			expect(secondSpec):toHaveBeenCalled()
		end
		context:addReporter({ done = assertions })
		
		context:execute()
	end)
	
	it("removes all spies added in a suite after the suite is complete", function()
		local context = Context:new()
		local originalFoo = function(self)
		end
		local testObj = { foo = originalFoo }
		
		context:describe("test suite", function()
			context:beforeAll(function()
				context:spyOn(testObj, "foo")
			end)
			
			context:it("spec 0", function()
				expect(isSpy(testObj.foo)):toBe(true)
			end)
			
			context:it("spec 1", function()
				expect(isSpy(testObj.foo)):toBe(true)
			end)
		end)
		
		context:describe("another suite", function()
			context:it("spec 2", function()
				expect(isSpy(testObj.foo)):toBe(false)
			end)
		end)
		
		context:addReporter({ done = done })
		
		context:execute()
	end)
	
	it("should report as expected", function()
		local context = Context:new()
		local reporter = createSpyObject("fakeReporter", 
										 "started", 
										 "done", 
										 "suiteStarted", 
										 "suiteDone", 
										 "specStarted", 
										 "specDone")
		
		reporter.done.will:callFake(function()
			expect(reporter.started):toHaveBeenCalledWith({ totalSpecsDefined = 2 })
			local suiteResult = reporter.suiteStarted.calls:argsFor(2)[1]
			expect(suiteResult.description):toEqual("A Suite")
		end)
		
		context:addReporter(reporter)
		
		context:describe("A Suite", function()
			context:it("with a top level spec", function()
				context:expect(true):toBe(true)
			end)
			context:describe("with a nested suite", function()
				context:it("with a spec", function()
					context:expect(true):toBe(false)
				end)
			end)
		end)
		
		context:execute()
	end)
	
	it("should be possible to get full name from a spec", function()
		local context = Context:new()
		local topLevelSpec = nil
		local nestedSpec = nil
		local doublyNestedSpec = nil
		
		context:describe("my tests", function()
			topLevelSpec = context:it("are sometimes top level", function()
			end)
			context:describe("are sometimes", function()
				nestedSpec = context:it("singly nested", function()
			end)
			context:describe("even", function()
				doublyNestedSpec = context:it("doubly nested", function()
					end)
				end)
			end)
		end)
		
		expect(topLevelSpec:getFullName()):toBe("my tests are sometimes top level")
		expect(nestedSpec:getFullName()):toBe("my tests are sometimes singly nested")
		expect(doublyNestedSpec:getFullName()):toBe("my tests are sometimes even doubly nested")
	end)
	
	it("throws an exception if you try to create a spy outside of a runnable", function()
		local context = Context:new()
		local obj = 
		{
			fn = function(self)
			end, 
		}
		local exception
		
		context:describe("a suite", function()
			local succ, err = pcall(function()
				context:spyOn(obj, "fn")
			end)
			if not succ then
				exception = err
			end
		end)
		
		local assertions = function()
			expect(exception):toMatch("Spies must be created in a before function or a spec")
		end
		
		context:addReporter({ done = assertions })
		
		context:execute()
	end)
end)
