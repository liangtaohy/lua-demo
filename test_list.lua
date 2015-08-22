--
-- @file test_list.lua
--

list = nil;
for line in io.lines() do
	list = {value = line, next = list};
	if line == 'q' then
		break;
	end
end
l = list;
while l do
	print(l.value);
	l = l.next;
end