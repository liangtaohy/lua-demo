-- test_array.lua

local X_1 = 4;
local X_2 = 2;
local X_3 = 3;

t = {
	2,
	[X_1] = 'x-1',
	[X_2] = 'x-2',
	[X_3] = 'x-3',
	[1]	  = 'ab',
	X_1   = 'new-x-1',
};
local key = 1
print(t[1]); 	-- nil
print(t[X_1]);	-- x-1
print(t[4]);	-- x-1
print(t.X_1);	-- new-x-1
print(t[key]);