-- test_table_index.lua

function setDefault(t, d)
	local mt = {}
	mt.__index = function () return d end
	setmetatable(t, mt)
end

local t1 = {0,1}
local t2 = {3,3}

setDefault(t2, 0)
print(t1[3])
print(t2[3])