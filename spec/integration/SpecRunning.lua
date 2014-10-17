local Context = require "Roem.Context"

describe("Spec running", function ()
	local context
	local fakeTimer
	
	beforeEach(function()
		context = Context:new()
	end)
	
	it("nested suites", function()
		local foo, bar, baz, quux = 0, 0, 0, 0
		local nested = context:describe("suite", function()
			context:describe("nested", function()
				context:it("should run nested suites", function()
					foo = foo + 1
				end)
				
				context:it("should run nested suites", function()
					bar = bar + 1
				end)
			end)
			
			context:describe("nested 2", function()
				context:it("should run suites following nested suites", function()
					baz = baz + 1
				end)
			end)
			
			context:it("should run tests following nested suites", function()
				quux = quux + 1
			end)
		end)
		
		expect(foo):toEqual(0)
		expect(bar):toEqual(0)
		expect(baz):toEqual(0)
		expect(quux):toEqual(0)
		
		nested:execute(function()
			expect(foo):toEqual(1)
			expect(bar):toEqual(1)
			expect(baz):toEqual(1)
			expect(quux):toEqual(1)
		end)
	end)
	
	it("should permit nested describes", function(done)
		local actions = {}
		
		context:beforeEach(function()
			table.insert(actions, "topSuite beforeEach")
		end)
		
		context:afterEach(function()
			table.insert(actions, "topSuite afterEach")
		end)
		
		context:describe("Something", function()
			context:beforeEach(function()
				table.insert(actions, "outer beforeEach")
			end)
			
			context:afterEach(function()
				table.insert(actions, "outer afterEach")
			end)
			
			context:it("does it 1", function()
				table.insert(actions, "outer it 1")
			end)
			
			context:describe("Inner 1", function()
				context:beforeEach(function()
					table.insert(actions, "inner 1 beforeEach")
				end)
				
				context:afterEach(function()
					table.insert(actions, "inner 1 afterEach")
				end)
				
				context:it("does it 2", function()
					table.insert(actions, "inner 1 it")
				end)
			end)
				
			context:it("does it 3", function()
				table.insert(actions, "outer it 2")
			end)
			
			context:describe("Inner 2", function()
				context:beforeEach(function()
					table.insert(actions, "inner 2 beforeEach")
				end)
				
				context:afterEach(function()
					table.insert(actions, "inner 2 afterEach")
				end)
				
				context:it("does it 2", function()
					table.insert(actions, "inner 2 it")
				end)
			end)
		end)
		
		local assertions = function()
			local expected = 
			{
				"topSuite beforeEach",
				"outer beforeEach",
				"outer it 1",
				"outer afterEach",
				"topSuite afterEach",
				
				"topSuite beforeEach",
				"outer beforeEach",
				"inner 1 beforeEach",
				"inner 1 it",
				"inner 1 afterEach",
				"outer afterEach",
				"topSuite afterEach",
				
				"topSuite beforeEach",
				"outer beforeEach",
				"outer it 2",
				"outer afterEach",
				"topSuite afterEach",
				
				"topSuite beforeEach",
				"outer beforeEach",
				"inner 2 beforeEach",
				"inner 2 it",
				"inner 2 afterEach",
				"outer afterEach",
				"topSuite afterEach", 
			}
			expect(actions):toEqual(expected)
		end
		
		context:addReporter({ done = assertions })
		
		context:execute()
	end)
	
	it("should run multiple befores and afters in the order they are declared", function()
		local actions = {}
		
		context:beforeEach(function()
			table.insert(actions, "runner beforeEach1")
		end)
		
		context:afterEach(function()
			table.insert(actions, "runner afterEach1")
		end)
		
		context:beforeEach(function()
			table.insert(actions, "runner beforeEach2")
		end)
		
		context:afterEach(function()
			table.insert(actions, "runner afterEach2")
		end)
		
		context:describe("Something", function()
			context:beforeEach(function()
				table.insert(actions, "beforeEach1")
			end)
			
			context:afterEach(function()
				table.insert(actions, "afterEach1")
			end)
			
			context:beforeEach(function()
				table.insert(actions, "beforeEach2")
			end)
			
			context:afterEach(function()
				table.insert(actions, "afterEach2")
			end)
			
			context:it("does it 1", function()
				table.insert(actions, "outer it 1")
			end)
		end)
		
		local assertions = function()
			local expected = 
			{
				"runner beforeEach1",
				"runner beforeEach2",
				"beforeEach1",
				"beforeEach2",
				"outer it 1",
				"afterEach2",
				"afterEach1",
				"runner afterEach2",
				"runner afterEach1",
			}
			expect(actions):toEqual(expected)
		end
		
		context:addReporter({ done = assertions })
		
		context:execute()
	end)
	
	it("should run beforeAlls before beforeEachs and afterAlls after afterEachs", function()
		local actions = {}
		
		context:beforeAll(function()
			table.insert(actions, "runner beforeAll")
		end)
		
		context:afterAll(function()
			table.insert(actions, "runner afterAll")
		end)
		
		context:beforeEach(function()
			table.insert(actions, "runner beforeEach")
		end)
		
		context:afterEach(function()
			table.insert(actions, "runner afterEach")
		end)
		
		context:describe("Something", function()
			context:beforeEach(function()
				table.insert(actions, "inner beforeEach")
			end)
			
			context:afterEach(function()
				table.insert(actions, "inner afterEach")
			end)
			
			context:beforeAll(function()
				table.insert(actions, "inner beforeAll")
			end)
			
			context:afterAll(function()
				table.insert(actions, "inner afterAll")
			end)
			
			context:it("does something or other", function()
				table.insert(actions, "it")
			end)
		end)
		
		local assertions = function()
			local expected = 
			{
				"runner beforeAll",
				"inner beforeAll",
				"runner beforeEach",
				"inner beforeEach",
				"it",
				"inner afterEach",
				"runner afterEach",
				"inner afterAll",
				"runner afterAll",
			}
			expect(actions):toEqual(expected)
		end
		
		context:addReporter({ done = assertionsend })
		context:execute()
	end)
	
	it("should set all pending specs to pending when a suite is run", function()
		local pendingSpec
		local suite = context:describe("default current suite", function()
			pendingSpec = context:it("I am a pending spec")
		end)
		
		suite:execute(function()
			expect(pendingSpec:status()):toBe("pending")
		end)
	end)
end)
