-- self参数测试
local a={x=10};
function a:fun(y)
	print(self.x,y);
end

function a.c(self, y)
	print(self.x, y);
end

a:fun(20);	-- 10	20
a:c(20);	-- 10	20
a.c(a, 20);	-- 10	20