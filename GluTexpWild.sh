#!/bin/bash
#----Loading Parameters-------------------------------------------------
line=1
paramload=true
while [ $paramload != done ]; do
eval `sed -n "$line"p ~/parameters.txt`
(( line++ ))
done
#-----------------------------------------------------------------------
rm mpjmachines.txt

cp $PBS_NODEFILE mpjmachines.txt

./mpjboot mpjmachines.txt

./mpjrun.sh -machinesfile mpjmachines.txt -cp $NEURON_HOME:$MPJ_HOME/lib/mpj.jar -dport 20000 -mpjport 21000 -np 20 -Xss4096k -Xmx512m -jar $MPJ_HOME/bin/eons_v1_COMPLETE_JAR.jar false MASTERCONF

