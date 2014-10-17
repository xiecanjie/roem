local Spec = require "Roem.Spec"

describe("Spec", function()
	it("#isPendingSpecException returns true for a pending spec exception", function()
		local e = { message = Spec.pendingSpecExceptionMessage }
		expect(Spec:isPendingSpecException(e)):toBe(true)
	end)
	
	it("#isPendingSpecException returns true for a pending spec exception", function()
		local e = { message = "foo" }
		expect(Spec:isPendingSpecException(e)):toBe(false)
	end)
	
	it("delegates execution to a QueueRunner", function()
		local fakeQueueRunner = createSpy("fakeQueueRunner")
		local spec = Spec:new
		{
			description = "test", 
			queueableFn = function()
			end, 
			queueRunnerFactory = fakeQueueRunner, 
		}
		
		spec:execute()
		
		expect(fakeQueueRunner):toHaveBeenCalled()
	end)
	
	it("should call the start callback on execution", function()
		local startCallback = createSpy("startCallback")
		local spec = Spec:new
		{
			description = "test", 
			queueableFn = function()
			end, 
			onStart = startCallback, 
		}
		
		spec:execute()
		
		expect(startCallback):toHaveBeenCalledWith(spec)
	end)
	
	it("should call the start callback on execution but before any befores are called", function()
		local beforesWereCalled = false
		local startCallback = createSpy("start-callback").will:callFake(function()
			expect(beforesWereCalled):toBe(false)
		end)
		local spec = Spec:new
		{
			queueableFn = function()
			end, 
			beforeFns = function()
				local func = function()
					beforesWereCalled = true
				end
				return { func }
			end, 
			onStart = startCallback, 
		}
		
		spec:execute()
		
		expect(startCallback):toHaveBeenCalled()
	end)
	
	it("provides all before fns and after fns to be run", function()
		local fakeQueueRunner = createSpy("fakeQueueRunner")
		local before = createSpy("before")
		local after = createSpy("after")
		local queueableFn = createSpy("test body").will:callFake(function()
			expect(before):toHaveBeenCalled()
			expect(after):no():toHaveBeenCalled()
		end)
		local spec = Spec:new
		{
			queueableFn = queueableFn, 
			beforeAndAfterFns = function()
				return { befores = { before }, afters = { after }, }
			end, 
			queueRunnerFactory = fakeQueueRunner, 
		}
		
		spec:execute()
		
		local allSpecFns = fakeQueueRunner.calls:mostRecent().args[1].queueableFns
		expect(allSpecFns):toEqual({ before, queueableFn, after, })
	end)
	
	it("is marked pending if created without a function body", function()
		local spec = Spec:new
		{
			queueableFn = nil, 
		}
		
		expect(spec:status()):toBe("pending")
	end)
	
	it("can be marked pending, but still calls callbacks when executed", function()
		local fakeQueueRunner = createSpy("fakeQueueRunner")
		local startCallback = createSpy("startCallback")
		local resultCallback = createSpy("resultCallback")
		local spec = Spec:new
		{
			onStart = startCallback, 
			resultCallback = resultCallback, 
			description = "with a spec", 
			getSpecName = function()
				return "a suite with a spec"
			end, 
			queueRunnerFactory = fakeQueueRunner, 
			queueableFn = nil, 
		}
		
		spec:pend()
		
		expect(spec:status()):toBe("pending")
		
		spec:execute()
		
		expect(fakeQueueRunner):no():toHaveBeenCalled()
		
		expect(startCallback):toHaveBeenCalled()
		expect(resultCallback):toHaveBeenCalledWith
		{
			status = "pending", 
			description = "with a spec", 
			fullName = "a suite with a spec", 
			failedExpectations = {}, 
			passedExpectations = {}, 
		}
	end)
	
	it("should call the done callback on execution complete", function()
		local done = createSpy("done callback")
		local spec = Spec:new
		{
			queueableFn = function()
			end, 
			queueRunnerFactory = function(attrs)
				attrs:onComplete()
			end, 
		}
		
		spec:execute(done)
		
		expect(done):toHaveBeenCalled()
	end)
	
	it("#status returns passing by default", function()
		local spec = Spec:new
		{
			queueableFn = createSpy("spec body"), 
		}
		expect(spec:status()):toBe("passed")
	end)
	
	it("#status returns passed if all expectations in the spec have passed", function()
		local spec = Spec:new
		{
			queueableFn = createSpy("spec body"), 
		}
		spec:addExpectationResult(true)
		expect(spec:status()):toBe("passed")
	end)
	
	it("#status returns failed if any expectations in the spec have failed", function()
		local spec = Spec:new
		{
			queueableFn = createSpy("spec body"), 
		}
		spec:addExpectationResult(true)
		spec:addExpectationResult(false)
		expect(spec:status()):toBe("failed")
	end)
	
	it("keeps track of passed and failed expectations", function()
		local resultCallback = createSpy("resultCallback")
		local spec = Spec:new
		{
			queueableFn = createSpy("spec body"), 
			expectationResultFactory = function(data)
				return data
			end, 
			queueRunnerFactory = function(attrs)
				attrs:onComplete()
			end, 
			resultCallback = resultCallback, 
		}
		spec:addExpectationResult(true, "expectation1")
		spec:addExpectationResult(false, "expectation2")
		
		spec:execute()
		
		local args = resultCallback.calls:first().args[1]
		expect(args.passedExpectations):toEqual({ "expectation1" })
		expect(args.failedExpectations):toEqual({ "expectation2" })
	end)
	
	it("can return its full name", function()
		local specNameSpy = createSpy("specNameSpy").will:returnValue("expected val")
		local spec = Spec:new
		{
			getSpecName = specNameSpy, 
		}
		
		expect(spec:getFullName()):toBe("expected val")
		expect(specNameSpy.calls:mostRecent().args[1]):toEqual(spec)
	end)
	
	describe("when a spec is marked pending during execution", function()
		it("should mark the spec as pending", function()
			local spec = Spec:new
			{
				description = "my test", 
				queueableFn = function()
				end, 
				queueRunnerFactory = function(opts)
					opts.onException({ message = Spec.pendingSpecExceptionMessage })
				end, 
			}
			
			spec:execute()
			
			expect(spec:status()):toEqual("pending")
		end)
	end)
end)
