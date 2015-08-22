--[[
function foo ()
	return;				-- Error: 'end' expected (to close 'function' at line 1) near 'i
	i = 10;
end
--]]
function foo ()
	do return end;		-- OK
	i = 10;
end