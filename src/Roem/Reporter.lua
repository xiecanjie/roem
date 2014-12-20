local string = require "std.string"
local table  = require "std.table"
local list   = require "std.list"
local Object = require "Roem.Object"

local prototype = Object{}

function prototype:initialize(options)
	self.output = options.output
	self.onComplete = options.onComplete or function()
	end
	self.specCount = 0
	self.failureCount = 0
	self.failedSpecs = {}
	self.pendingCount = 0
	self.failedSuites = {}
end

function prototype:started()
	self.startClock = os.clock()
	self.specCount = 0
	self.failureCount = 0
	self.pendingCount = 0
	self:write("Started")
	self:writeNewline()
end

function prototype:done()
	self:writeNewline()
	
	for _, failedSpec in ipairs(self.failedSpecs) do
		self:specFailureDetails(failedSpec)
	end
	
	if self.specCount > 0 then
		self:writeNewline()
		
		local describe = function(str, count)
			return count .. " " .. self:plural(str, count)
		end
		local data = {}
		table.insert(data, describe("spec", self.specCount))
		table.insert(data, describe("failure", self.failureCount))
		if self.pendingCount > 0 then
			table.insert(data, describe("pending spec", self.pendingCount))
		end
		self:write(table.concat(data, ", "))
	else
		self:write("No specs found")
	end
	
	self:writeNewline()
	local seconds = (os.clock() - self.startClock)
	self:write(string.format("Finished in %.3f seconds", seconds))
	self:writeNewline()
	
	for _, failedSuite in ipairs(self.failedSuites) do
		self:suiteFailureDetails(failedSuite)
	end
	
	self.onComplete(self.failureCount == 0)
end

function prototype:specDone(result)
	self.specCount = self.specCount + 1
	
	if result.status == "pending" then
		self.pendingCount = self.pendingCount + 1
		self:write("*")
		return
	end
	
	if result.status == "passed" then
		self:write(".")
		return
	end
	
	if result.status == "failed" then
		self.failureCount = self.failureCount + 1
		table.insert(self.failedSpecs, result)
		self:write("F")
	end
end

function prototype:suiteDone(result)
	if not table.empty(result.failedExpectations) then
		self.failureCount = self.failureCount + 1
		table.insert(self.failedSuites, result)
	end
end

--------------------------------------------------------------------------------
-- private

function prototype:write(s)
	self.output(s)
end

function prototype:writeNewline()
	self:write("\n")
end

function prototype:plural(str, count)
	return (count == 1 and str or str .. "s")
end

function prototype:indent(str, spaces)
	local lines = string.split(str or "", "\n")
	return table.concat(list.map(function(line)
		return string.rep(" ", spaces) .. line
	end, lines), "\n")
end

function prototype:specFailureDetails(result)
	self:writeNewline()
	self:write(result.fullName)
	
	for _, failedExpectation in ipairs(result.failedExpectations) do
		self:writeNewline()
		self:write(self:indent(failedExpectation.message, 4))
		
		if failedExpectation.stack ~= "" then
			self:writeNewline()
			self:write(self:indent(failedExpectation.stack, 4))
		end
	end
	
	self:writeNewline()
end

function prototype:suiteFailureDetails(result)
	for _, failedExpectation in ipairs(result.failedExpectations) do
		self:writeNewline()
		self:write("An error was thrown in an afterAll")
		self:writeNewline()
		self:write("AfterAll " .. failedExpectation.message)
	end
	self:writeNewline()
end

return prototype
