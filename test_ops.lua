-- @file test_ops.lua
local v = 10 or 20;
print(v);	-- 10
print(0 or 10);		-- 0
print(nil or 10);	-- 10
--print(#v);		-- error: atempt to get length of a number value
local str = "hello,world!";
local str2 = "梁涛你好么？";
local str3 = "中";
local arr1 = {1,2,3,4,5};
local arr2 = {1,2,{x=1,y=2}};
local arr3 = {x=1,y=2};
local arr4 = {1,2,nil,4};
local arr5 = {10,20,nil,40};
local arr6 = {1,2,4,nil};
print(#str);	-- 12
print(#str2);	-- 18
print(#str2/#str3);		-- 6.0
print(#arr1);	-- 5
print(#arr2);	-- 3
print(#arr3);	-- 0，不是一个序列（正整数键值构成）
print('array4 length:')
print(#arr4);	-- 4
print(#arr6);	-- 3
print(#arr5);	-- 4

local tb = getmetatable(arr5);
for i,v in ipairs(tb or {}) do
	print(i,v);
end