local string           = require "std.string"
local table            = require "std.table"
local list             = require "std.list"
local Object           = require "Roem.Object"
local Any              = require "Roem.Any"
local ObjectContaining = require "Roem.ObjectContaining"

local prototype = Object{}

function prototype:initialize()
end

function prototype:equals(a, b)
	return self:eq(a, b)
end

function prototype:contains(haystack, needle)
	for _, value in ipairs(haystack) do
		if self:eq(value, needle) then
			return true
		end
	end
	return (haystack[needle] ~= nil)
end

function prototype:buildFailureMessage(matcherName, isNot, actual, ...)
	local englishyPredicate = string.gsub(matcherName, "%u", function(l)
		return " " .. string.lower(l)
	end)
	
	local message = string.format("Expected %s%s%s", 
								  self:prettyPrint(actual), 
								  (isNot and " not " or " "), 
								  englishyPredicate)
	
	local expected = { ... }
	if not table.empty(expected) then
		message = message .. " " .. table.concat(list.map(function(value)
			return self:prettyPrint(value)
		end, expected), ", ")
	end
	
	return message .. "."
end

function prototype:eq(a, b)
	if a == b then
		return true
	end
	
	if self:checkType(a, Any) then
		if a:matches(b) then
			return true
		end
	end
	
	if self:checkType(b, Any) then
		if b:matches(a) then
			return true
		end
	end
	
	if self:checkType(a, ObjectContaining) then
		if a:matches(b) then
			return true
		end
	end
	
	if self:checkType(b, ObjectContaining) then
		if b:matches(a) then
			return true
		end
	end
	
	if type(a) == "table" and type(b) == "table" then
		for k, v in pairs(a) do
			if not self:eq(v, b[k]) then
				return false
			end
		end
		for k, v in pairs(b) do
			if not self:eq(v, a[k]) then
				return false
			end
		end
		return true
	end
	
	return false
end

function prototype:prettyPrint(expected)
	if expected == "<nil>" then
		return "nil"
	end
	
	if type(expected) == "function" then
		return "function"
	end
	
	if type(expected) == "string" then
		return '"' .. expected .. '"'
	end
	
	return string.tostring(expected)
end

function prototype:checkType(a, prototype)
	if type(a) ~= "table" then
		return false
	end
	return (a.initialize == prototype.initialize)
end

return prototype
