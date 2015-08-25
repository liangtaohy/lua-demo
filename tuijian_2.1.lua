-- tuijian_2.1.lua
-- #协同过滤推荐
-- ##基于用户的最近邻推荐
-- >输入为评分集合，活跃用户ID
-- >计算最近邻（sim(a,b)=Pearson相关系数，相似度计算）.Pearson从+1(强正相关)到-1(强负相关)
-- >计算用户a对物品p的预测值 pred(a,p) = avg(a) + 偏差

local uMatrix = { Alice, User1, User2, User3, User4 };
local pMatrix = { p1,p2,p3,p4,p5};
local rMatrix = {
	{5,3,4,4,nil},
	{3,1,2,3,3},
	{4,3,4,3,5},
	{3,3,1,5,4},
	{1,5,5,2,1}
};

local avgMatrix = {};

local n = #rMatrix;
local m = #pMatrix;

for i,v in ipairs(rMatrix) do
	local sum = 0;
	local count = 0;
	for j,vj in ipairs(v) do
		if vj then
			sum = sum + vj;
			count = count + 1;
		end
	end
	avgMatrix[i] = count ~= 0 and sum / count or 0;
end

for i,v in ipairs(avgMatrix) do
	print(i,v);
end

--[[
测试中发现第4行的结果是0，应该是数值运算有问题
--]]
local function matrix_multi(a, b, avgA, avgB)
	local lenA = #a or 0;
	local lenB = #b or 0;
	local sum = 0;
	local sum2 = 0;
	local sum3 = 0;
	for i=1, lenA do
		local t_a = a[i] - avgA;
		local t_b = b[i] - avgB;
		local t = t_a*t_b;
		sum = sum + t;
		sum2 = sum2 + t_a^2;
		sum3 = sum3 + t_b^2;
	end
	sum2 = math.sqrt(sum2);
	sum3 = math.sqrt(sum3);
	local x = sum2*sum3;
	return sum, x, sum/x;
end

avgA = avgMatrix[1];
for i=2,n do
	print(matrix_multi(rMatrix[1], rMatrix[i], avgA, avgMatrix[i]));
end

--[[
对数组arr从大到小进行排序，并返回前K个下标
--]]
function ArraySortK(arr, K)
	local sorted = {}

	local cur = 1
	for i,v in pairs(arr) do
		if cur > K then
			break
		end
		for j=cur-1,1,-1 do
			if v > arr[sorted[j]] then
				cur = j
			else
				break
			end
		end
		table.insert(keys, cur, i)
		cur = cur + 1
	end
	return sorted
end

--[[
topN推荐
@param UID user 当前用户u
@param Matrix train 训练集
@param Matrix w [u,v]相似度矩阵
@param Number K K个与用户u相似的用户
--]]
function RecommendTopN(user, train, w, K)
	local rank = {}
	local interacted_items = train[user]
	local wu = table.sort(w[u])
	local sortedKeys = ArraySortK(wu, K)
	for _, v in pairs(sortedKeys) do
		local wuv = wu[v]
		for i,rvi in pairs(train[v]) do
			if interacted_items[i] == nil then -- 用户user没有访问过该物品
				rank[i] = rank[i] and rank[i] + wuv*rvi or wuv*rvi
			end
		end
	end
	return rank
end