#!/bin/bash

#----Loading Parameters--------------------------------------------------------
line=1
paramload=true
while [ $paramload != done ]; do
eval `sed -n "$line"p parameters.txt`
echo `sed -n "$line"p parameters.txt`
line=`expr $line + 1`
done
#-----------------------------------------------------------------------

#------Menu-------------------------------------------------------------
loop=1
while [ "$loop" -eq 1 ]
	do
		echo "1. Run simulation"
		echo "2. Run additional simulation while a qsub is presently starting (Use up to once per qsub wait)"
		echo "3. Resync Files to Cluster - Choose this if you modified any of the script(not parameters) or if the simulation launch fails"
		echo "4. First time installation"
		echo "5. Exit"
		read in                                               
#-----------------------------------------------------------------------


#------Launch Simulation------------------------------------------------
if [ "$in" -eq 1 ];	then
line=1
paramload=true
while [ $paramload != done ]; do
eval `sed -n "$line"p parameters.txt`
line=`expr $line + 1`
done
gnome-terminal --tab --command="expect launchneuron.exp" --tab --command="expect launchmpj.exp"
	#bash -c "expect launchmpj.exp" &	
	#bash -c "expect launchneuron.exp" & 
	#wait
	echo "Simulation Complete"
	echo "Plotting Results"
fi
#-----------------------------------------------------------------------

#------Launch Additional Simulation-------------------------------------
line=1
paramload=true
while [ $paramload != done ]; do
eval `sed -n "$line"p parameters.txt`
echo `sed -n "$line"p parameters.txt`
line=`expr $line + 1`
done
if [ "$in" -eq 2 ];	then
	#bash -c "expect launchneurondiff.exp" & 
	#bash -c "expect launchmpjdiff.exp" &	
	#wait
gnome-terminal --tab --command="expect launchneurondiff.exp" --tab --command="expect launchmpjdiff.exp"
	echo "Simulation Complete"
	echo "Plotting Results"
fi
#-----------------------------------------------------------------------


#------Resync files to Cluster------------------------------------------
if [ "$in" -eq 3 ];	then
	expect -c "
		spawn scp parameters.txt $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp paramsync.sh $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp qsubwait.sh $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp plotgraph.sh $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp $MPJLAUNCHFI $username@hpc-login2.usc.edu:$MPJ_HOME/bin
		expect \"$ \"
		spawn scp $MASTERCONFI $username@hpc-login2.usc.edu:$NEURON_HOME
		expect \"$ \"
		spawn scp $SYNAPSECONFI $username@hpc-login2.usc.edu:$MPJ_HOME/bin
		expect \"$ \"
		spawn scp SimResultPlotGenerator.m $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp $NEURONPYFI $username@hpc-login2.usc.edu:$NEURON_HOME
		expect \"$ \"
		spawn ssh $username@hpc-login2.usc.edu
		expect \"$ \"
		send \"rm queue\r\"
		expect \"$ \"
		send \"rm nodequeue\r\"	
		expect \"$ \"
		send \"rm nodequeue2\r\"	
		expect \"$ \"
		send \"rm qsubwaitqueue\r\"	
		expect \"$ \"
		send \"exit\r\"
	"
fi
#-----------------------------------------------------------------------

#-----First Time Installation-------------------------------------------
if [ "$in" -eq 4 ];	then
	echo "Installing gnome-terminal"
	sudo apt-get install gnome-terminal
	echo "Installing expect script"
	sudo apt-get install expect
	expect -c "
		spawn scp parameters.txt $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp paramsync.sh $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp qsubwait.sh $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp plotgraph.sh $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp $MPJLAUNCHFI $username@hpc-login2.usc.edu:$MPJ_HOME/bin
		expect \"$ \"
		spawn scp $MASTERCONFI $username@hpc-login2.usc.edu:$NEURON_HOME
		expect \"$ \"
		spawn scp $SYNAPSECONFI $username@hpc-login2.usc.edu:$MPJ_HOME/bin
		expect \"$ \"
		spawn scp SimResultPlotGenerator.m $username@hpc-login2.usc.edu:~/
		expect \"$ \"
		spawn scp $NEURONPYFI $username@hpc-login2.usc.edu:$NEURON_HOME
		expect \"$ \"
	"
fi
#-----------------------------------------------------------------------

#-----EXIT--------------------------------------------------------------
if [ "$in" -eq 5 ];	then
	loop=2
fi
#-----------------------------------------------------------------------
done
exit 1

