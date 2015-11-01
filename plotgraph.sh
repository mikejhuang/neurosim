#!/bin/bash
filenameMem=`sed -n '1'p queue`
echo `sed -n '1'p queue`
sed -i '1'd queue 

#Importing parameters from neurosim.sh
line=2 #start line of parameters
paramload=true
while [ $paramload != done ]; do
eval `sed -n "$line"p parameters.txt`
(( line++ ))
done
line=2 #start line of parameters
paramload=true
while [ $paramload != done ]; do
eval `sed -n "$line"p $NEURON_HOME/$filenameMem.log`
(( line++ ))
done
matlabfilename=SimResultPlotGenerator.m
sed -i "s/plotduration/$duration/g" $matlabfilename
sed -i "s%NeuronHome%$NEURON_HOME%g" $matlabfilename
sed -i "s/simresults/$filenameMem/g" $matlabfilename
matlab -nodesktop -nosplash -nodisplay -r "run ./$matlabfilename ; quit;" 

#Revert changes
sed -i "s/$duration/plotduration/g" $matlabfilename
sed -i "s/$filenameMem/simresults/g" $matlabfilename
sed -i "s%$NEURON_HOME%NeuronHome%g" $matlabfilename
