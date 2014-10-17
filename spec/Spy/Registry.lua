local Registry = require "Roem.Spy.Registry"

describe("SpyRegistry", function()
	describe("#spyOn", function()
		it("checks for the existence of the object", function()
			local registry = Registry:new()
			
			expect(function()
				registry:spyOn(nil, "pants")
			end):toThrow("spyOn could not find an object to spy upon for pants()")
		end)
		
		it("checks for the existence of the method", function()
			local registry = Registry:new()
			local subject = {}
			
			expect(function()
				registry:spyOn(subject, "pants")
			end):toThrow("pants() method does not exist")
		end)
		
		it("checks if it has already been spied upon", function()
			local registry = Registry:new()
			local subject = {}
			subject.spiedFunc = function(self)
			end
			
			registry:spyOn(subject, "spiedFunc")
			
			expect(function()
				registry:spyOn(subject, "spiedFunc")
			end):toThrow("spiedFunc has already been spied upon")
		end)
		
		it("overrides the method on the object and returns the spy", function()
			local originalFunctionWasCalled = false
			local registry = Registry:new()
			local subject = {}
			subject.spiedFunc = function(self)
				originalFunctionWasCalled = true
			end
			
			local spy = registry:spyOn(subject, "spiedFunc")
			
			expect(subject.spiedFunc):toEqual(spy)
		end)
	end)
	
	describe("#clearSpies", function()
		it("restores the original functions on the spied-upon objects", function()
			local spies = {}
			local registry = Registry:new
			{
				currentSpies = function()
					return spies
				end, 
			}
			local originalFunction = function()
			end
			local subject = { spiedFunc = originalFunction }
			
			registry:spyOn(subject, "spiedFunc")
			registry:clearSpies()
			
			expect(subject.spiedFunc):toBe(originalFunction)
		end)
	end)
end)
