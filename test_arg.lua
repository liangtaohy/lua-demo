printResult = "";

function t(...)
	local arg = {...};
	for i,v in ipairs(arg) do
		printResult = printResult .. tostring(v) .. "\t";
		print(tostring(v));
	end
	printResult = printResult .. "\n";
end
t(1, 2, 3, 4);
print(printResult);

local _, x = string.find("hello, lua", "lua");
print(x);