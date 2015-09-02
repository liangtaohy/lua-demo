--[[
@file UserCF.lua
基于用户的协同过滤算法
--]]
-- system lib
local math = require('math')
local os = require("os")
local io = require("io")
-- user lib
local matrix = require('test_matrix')
local Helper = require("serialize")

local VERSION = "0.0.1"

local print		= print
local string	= string
local sqrt		= math.sqrt
local pairs		= pairs
local assert	= assert
local type		= type
local table 	= table
local tonumber	= tonumber
local error		= error

local base = _ENV
local modename = {}
local _ENV = modename

-- 数据集：ratings.data (MovieLens的投票数据，中等，约100万行，6000多用户，近4000部电影)
-- config
-- 应该移到配置文件中
local RAW_DATA_FILE = "/Users/baidu/Downloads/ml-1m/ratings.dat"
local OUTPUT_FILE = "/Users/baidu/Downloads/ml-1m/wuv.dat"
local ROW = {from=1,to=6040}
local COL = {from=1,to=3952}
local uPrefix = ""

function version()
	print(VERSION)
end
--[[
从文件中加载数据，输出为M*4的矩阵，元素为{UserID,MovieID,Rating,Timestamp}
逐行读取数据，数据格式为: data::data::data[::...]
目前，仅支持读取数字类型的数据

--]]
local function LoadData(filename)
	print("Loading data begin ...")

	local t1 = os.time()

	local handle = io.open(filename, "r")
	if handle == nil then
		error("failed to open file: [" .. filename .. "] in r mode")
	end
	local re = {}
	for line in handle:lines() do
		local data = {}
		for item in string.gmatch(line, "(%d+)") do
			table.insert(data, tonumber(item))
		end
		table.insert(re, data)
	end
	handle:close()

	local t2 = os.time()

	print("Loading data end ...")
	print("data colums: " .. #re .. ", time used: " .. os.difftime(t2, t1) .. "s")
	return re
end

--[[
保存doc到文件filename中。如果文件已存在，会覆盖原文件的内容。
@param string filename 文件路径
@param string doc 待保存的文档
--]]
local function SaveToFile(filename, doc)
	local handle = io.open(filename, "w")
	if handle == nil then
		error("failed to open file: [" .. filename .. "] in w mode")
	end
	handle:write(doc)
	handle:flush()
	handle:close()
end

--[[
加载初始数据，生成uid,mid(s)矩阵 {<u,items>}
@description
 矩阵结构如下:
 Matrix 		:= {user=items,[...]}
 user 		:= string -- user id ('u' .. uid),uid通常为整数id
 items 		:= {[item-id]=value,[...]}, item-id为物品的id, value为整数类型，此处固定为1
@note 仅支持隐式反馈的数据集
@param table data - 原始数据矩阵
 |user id|item id|value1|value2[|...]
--]]
local function LoadIntoUserMatrix(data)
	print("Load raw data into uid-mid matrix begin ...")

	local t1 = os.time()

	local re = {}
	local size = 0
	for _,v in pairs(data) do
		local key = uPrefix .. v[1] -- key = "u" .. UID
		if re[key] then -- set matrix[uid][mid] to 1
			re[key][v[2]] = 1
		else
			re[key] = {}
			re[key][v[2]] = 1
			size = size + 1
		end
	end

	local t2 = os.time()

	print("Load raw data into uid-mid matrix end ...")
	print("uid-mid matrix colums: " .. size .. ", time used: " .. os.difftime(t2, t1) .. "s")
	return re
end

--[[
构建物品-用户倒排表 {<item,users>}
 结构定义：
 Matrix 		:= {[item]=users,[...]}
 item 		:= integer -- 物品id
 users 		:= {user,[...]}
 user 		:= mix -- 可以是用户id或者用户的信息数据，一般为id
@param table data data为{<u,items>}集合
@return {<item,users>}
--]]
local function BuildItemUsersInverseTable(data)
	print("Load raw data into item-users matrix begin ...")

	local t1 = os.time()

	local re = {}

	for _,v in pairs(data) do
		local item = v[2]
		if re[item] == nil then
			re[item] = {}
		end
		table.insert(re[item], v[1]) -- insert user into users queue
	end

	local t2 = os.time()
	print("Load raw data into item-users matrix end ...")
	print("item-users matrix time used: " .. os.difftime(t2, t1) .. "s")
	return re
end

--[[
构建物品-用户倒排表 {<item,users>}
 结构定义：
 Matrix 		:= {[item]=users,[...]}
 item 		:= integer -- 物品id
 users 		:= {user,[...]}
 user 		:= mix -- 可以是用户id或者用户的信息数据，一般为id
@param table data data为{<u,items>}集合 (训练样本)
@return {<item,users>}
--]]
local function BuildItemInverseTableByTrain(train)
	print("Build item_users inverse table by train dataset")
	local t1 = os.time()

	local re = {}

	for u,items in pairs(train) do
		for item, _ in pairs(items) do
			if re[item] == nil then
				re[item] = {}
			end
			table.insert(re[item], u)
		end
	end

	local t2 = os.time()
	print("Build item_users inverse table by train dataset: " .. os.difftime(t2, t1) .. "s")

	return re
end

--[[
用户相似度计算
算法为余弦相似度公式
未考虑物品评分信息，只考虑用户对物品是否有过行为
-----
输出矩阵W_{uv}: {<u,v,similarity>}
Matrix 		:= {user=users}
user 		:= integer -- user id
users 		:= {user=similarity}
similarity 	:= float -- 浮点型数据,相似度值,如果为<u,u>,则其值为0
-----
@param table train 训练样本
@return table W 相似度矩阵，结构为 W={w_uv | u,v 属于 users集合}
--]]
local function UserSimilarity_sin(train)
	print("UserSimilarity_sin begin ...")

	local t1 = os.time()

	local N = {} -- N[u]为用户u有过行为的物品数量
	local C = {} -- C[u][v]为用户[u,v]有过行为的物品数量

	for item, users in pairs(train) do
		for _,u in pairs(users) do
			N[u] = N[u] and N[u] + 1 or 1
			C[u] = C[u] or {}
			for _,v in pairs(users) do
				if u ~= v then
					C[u][v] = C[u][v] and C[u][v] + 1 or 1
				end
			end
		end
	end

	local W = {} -- W[u][v]为[u,v]相似度
	for u, related_users in pairs(C) do
		W[u] = {}
		for v, cuv in pairs(related_users) do
			W[u][v] = cuv / math.sqrt(N[u]*N[v])
		end
	end

	local t2 = os.time()
	print("UserSimilarity_sin time used: " .. os.difftime(t2, t1) .. "s")

	return W
end

--[[
测试数据矩阵的正确性，汗！！
--]]
local function dataTest(mtx)
	local data = mtx

	if type(data) ~= 'table' then
		error("param must be a table")
	end

	local function _test(uid, mid)
		if data[uPrefix .. uid][mid] then
			-- 调试：序列化输出table Helper.serialize(data[uPrefix .. uid])
			print("success")
		else
			local errstr = string.format('data[%s:%s] not existed!! Please check your Matrix!!', uPrefix .. uid, ' ' .. mid)
			error(errstr)
		end
	end

	_test(6028, 3000)
	_test(5990, 2051)
	_test(1, 3408)
	_test(1, 2355)
	_test(1, 1197)
	_test(20, 1912)
	_test(20, 2571)
	_test(6040, 3735)
	_test(6040, 2791)
	_test(6040, 2794)

end

--[[
给定数据集data,将它随机分成M份,取出其中的第k份,返回第k份,M-1份
@param table data 	-- 待拆分的数据矩阵
@param number M 	-- 要拆分的份数
@param number k 	-- 第k份作为测试集
@param number seed 	-- 随机数种子,通常为当前时间戳
@return train, test -- 训练集, 测试集
--]]
local function SplitData(data, M, k, seed)
	print("SplitData matrix begin ...")

	local t1 = os.time()

	local test = {}
	local train = {}
	math.randomseed(seed)
	for uid,v in pairs(data) do
		if math.random(0,M) == k then
			test[uid] = v
		else
			train[uid] = v
		end
	end

	local t2 = os.time()
	print("SplitData matrix time used: " .. os.difftime(t2, t1) .. "s")

	return train, test
end

--[[
[u,v]用户相似度
算法为Jaccard公式
未考虑评分信息，只考虑是否有过行为
--]]
local function W_U_V_Jaccard(data)
	print("W_U_V_Jaccard matrix begin ...")

	local t1 = os.time()

	local re = {}
	for u,j in pairs(data) do
		re[u] = {}
		for v,k in pairs(data) do
			if re[v][u] then
				re[u][v] = re[v][u]
			elseif u == v then
				re[u][v] = 0
			else
				re[u][v] = matrix.norm(matrix.kintersecation(j,k))/matrix.norm(matrix.union(j,k))
			end
		end
	end

	local t2 = os.time()
	print("W_U_V_Jaccard matrix time used: " .. os.difftime(t2, t1) .. "s")

	return re
end

local function len(t)
	local length = 0
	if type(t) ~= 'table' then -- 如果不是table，则返回0即可
		return 0
	end
	for i,_ in pairs(t) do
		length = length + 1
	end
	return length
end

--[[
召回率计算
@param table train 训练集
@param table test  测试集
@param number N    推荐数目
@return v 召回率
--]]
function Recall(train, test, N)
	local hit = 0
	local all = 0

	assert(type(train) == 'table', "Precision param @train must be table,table,number")
	assert(type(test) ==  'table', "Precision param @test must be table,table,number")

	for user,_ in pairs(train) do
		local tu = test[user]
		local rank = GetRecommendation(user, N)
		for item, pui in pairs(rank) do
			if tu[item] then
				hit = hit + 1
			end
		end
		all = all + len(tu)
	end
	return hit / all
end

--[[
准确率计算
@param table train 训练集
@param table test  测试集
@param number N    推荐数
@return v 准确率
--]]
function Precision(train, test, N)
	local hit = 0
	local all = 0

	assert(type(train) == 'table', "Precision param @train must be table,table,number")
	assert(type(test) ==  'table', "Precision param @test must be table,table,number")

	for user, _ in pairs(train) do
		local tu = test[user]
		local rank = GetRecommendation(user, N)
		for item, pui in pairs(rank) do
			if tu[item] then
				hit = hit + 1
			end
		end
		all = all + N
	end
	return hit / all
end

--[[
召回率和准确率计算
@param table train 训练集
@param table test  测试集
@param number N    推荐数
@return v1,v2 v1为召回率,v2为准确率
--]]
function RecallPrecision(train, test, N)
	local hit = 0
	local all = 0
	local p = 0

	assert(type(train) == 'table', "Precision param @train must be table,table,number")
	assert(type(test) ==  'table', "Precision param @test must be table,table,number")

	for user,_ in pairs(train) do
		local tu = test[user]
		local rank = GetRecommendation(user, N)
		for item, pui in pairs(rank) do
			if tu[item] then
				hit = hit + 1
			end
		end
		all = all + len(tu)
		p = p + N
	end
	return hit / all, hit / p
end

--[[
构建推荐模型
--]]
function buildModel()
	local raw = LoadData(RAW_DATA_FILE)
	local umMtx = LoadIntoUserMatrix(raw)
	dataTest(umMtx)
	local train, test = SplitData(umMtx, 8, 2, os.clock())
	local tTrain = BuildItemInverseTableByTrain(train)
	local W = UserSimilarity_sin(tTrain)
	local w_str = Helper.serialize(W)
	SaveToFile(OUTPUT_FILE, w_str)
end

return modename