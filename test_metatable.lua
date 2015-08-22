-- test_metatable.lua

local Set = {}
Set.mt = {}

function Set.new(L)
	local set = {}
	setmetatable(set, Set.mt)
	if L then
		for _,v in ipairs(L) do set[v] = true end
	end
	return set
end

function Set.union(a,b)
	if getmetatable(a) ~= Set.mt or
		getmetatable(b) ~= Set.mt then
		error("attempt to 'add' a set with a non-set value")
	end
	local res = Set.new()
	for k,v in pairs(a) do res[k] = true end
	for k,v in pairs(b) do res[k] = true end
	return res
end

function Set.intersection(a,b)
	local res = Set.new()
	for k,v in pairs(a) do
		a[k] = b[k]
	end
	return res
end

function Set.tostring(a)
	io.write('{\n')
	for k,v in pairs(a) do
		io.write(" " .. k .. " = ")
		io.write(v and 'true' or 'false')
		io.write(",\n")
	end
	io.write('}\n')
end

Set.mt.__add = Set.union

s1 = Set.new({10,20,30,40,50,60})
s2 = Set.new({10,30,70})
Set.tostring(s1)
Set.tostring(s2)

Set.tostring(s1+s2)
s = s1+8