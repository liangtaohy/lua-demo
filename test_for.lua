local days = {1,2,3,4,5,6,7};
local map = {monday=1,sunday=7};
for i,d in ipairs(days) do
	print(d);
end

for k in pairs(map) do
	print(k);
end

for k,v in pairs(map) do
	print(k .. v);
end

days = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};
revDays = {}
for i,v in ipairs(days) do
	revDays[v] = i;
end

for k,v in pairs(revDays) do
	print(k .. v);
end