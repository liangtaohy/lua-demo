#!/bin/bash
rm -rf output
mkdir -pv output/lua-demo
cp *.lua output/lua-demo
cp README.md output/lua-demo
cp *.txt output/lua-demo
cd output
tar -zcvf lua-demo.tgz lua-demo