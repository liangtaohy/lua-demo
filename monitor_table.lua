-- monitor_table.lua

t = {} -- original tables

local _t = t
t = {}
local mt = {
	__index = function (t, k)
		print("*access to element: " .. tostring(k))
		return _t[k] -- access original table
	end,
	__newindex = function (t, k, v)
		print("*update element tostring " .. tostring(k) .. " to " .. tostring(v))
		_t[k] = v
	end
}

setmetatable(t, mt)

t[2] = 3
print(t[1])

-- 私有索引
local index = {}

local mt = {
	__index = function (t,k)
		print("*access to element " .. tostring(k))
		return t[index][k]
	end,
	__newindex = function (t, k, v)
		print("*update element " .. tostring(k) .. " to " .. tostring(v))
		t[index][k] = v
	end
}

function track(t)
	local proxy = {}
	proxy[index] = t
	setmetatable(proxy, mt)
	return proxy
end

x = {1,2,3,name=4}
x = track(x)
print(x[1])
print(x.name)