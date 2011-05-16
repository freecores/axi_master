#!/bin/bash

../../../robust ../src/base/axi_master.v -od out -I ../src/gen -list list.txt -listpath -header -gui ${@}
