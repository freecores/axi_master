
echo off

..\..\..\robust.exe ../src/base/axi_master.v -od out -I ../src/gen -list filelist.txt -listpath -header

echo Completed RobustVerilog axi master run - results in run/out/
