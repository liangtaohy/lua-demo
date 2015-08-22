-- test_string.lua

local buff = "hello,world:"
print(buff)
for i=1,100 do
	buff = buff .. i
	print(buff)
end