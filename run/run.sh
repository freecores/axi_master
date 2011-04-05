#!/bin/bash

echo Starting RobustVerilog axi master run
rm -rf out
mkdir out

../../../robust ../src/base/axi_master.v -od out -I ../src/gen -list filelist.txt -listpath -header

echo Completed RobustVerilog axi fabric run - results in run/out/
