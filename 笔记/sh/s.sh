#!/bin/bash
#**********************************************************************
# Description       : check mem > 80
# version           : 0.1
#**********************************************************************
#-------------------VAR------------------------------------------------
#-------------------FUN------------------------------------------------
main(){
       MEM=`free -m | sed -n '2p' | awk '{print $3/$2*100}'|awk -F. '{print$1}'`
       if [ $MEM -gt 80 ]
       then
               echo "cmd"
       fi
}
#-------------------PROGRAM--------------------------------------------
main

