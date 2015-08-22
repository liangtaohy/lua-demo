-- test_matrix_alg.lua
local matrix = require('test_matrix')

local E1 = matrix:new(4,"I",16)
matrix:dump(E1)
local E2 = matrix:new(4,4,2)
matrix:dump(E2)
local ee = matrix.mul(E1,E2)
matrix:dump(ee)