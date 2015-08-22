-- 测试变量或值的类型
print(type("hello,world!")); -- string
print(type(10.4*3)); -- number
print(type(print)); -- function
print(type(true)); -- boolean
print(type(nil)); -- nil

-- 变量的类型是动态可变的
print(type(a)); -- nil
a = 10;
print(type(a)); -- number
a = "string";
print(type(a)); -- string
a = true;
print(type(a)); -- boolean