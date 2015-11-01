
NeuroSim Launcher v0.98

       _---~~(~~-_.
     _{        )   )
   ,   ) -~~- ( ,-' )_
  (  `-,_..`., )-- '_,)
 ( ` _)  (  -~( -_ `,  }
 (_-  _  ~_-~~~~`,  ,' )
   `~ -^(    __;-,((()))
         ~~~~ {_ -_(())
                `\  }
                  { }

NeuroSim Launcher is a script designed to streamline the simulation launching and data collection process to a few quick and simple actions. It automatically launches a NEURON/EONS simulation on the USC HPC Cluster, 

Basic Startup:
	1. Untar contents to a folder that you would like to launch the script from.
	2. Place your Neuron Python file into the folder in step #1.
	3. Open neurosim.sh with your favorite text/vi editor and set up the corresponding file locations and parameters.
	4. Set up an SSH password by following the instructions here: http://www.linuxproblem.org/art_9.html
	5. Run by typing the following command in the terminal: sh neurosim.sh
	6. Select option 4 for first time installation.
	7. Set your shell to csh by tying the command exec/bin/csh
	8. Results are stored in your neuron home folder. 

Adding Additional Parameters:
	1. Add desired parameter in neurosim.sh. Ex: nbAMPA=80
	2. Set up paramsync.sh to find and replace the parameter with the sed command. Use [0-9]\+ as wildcards for a number of any digit, and [0-9]\+.[0-9]\+ for a decimal number of any number of digits and places.
		sed -i "/search/replace/g" $FILEPATH  
		Ex: sed -i "s/[0-9]\+<\/nbAMPA/$nbAMPA<\/nbAMPA/g" $SYNAPSECONF
	3. Print line to confirm the search and replace is working correctly.
		sed -n '$linenumber'p $FILEPATH
		Ex: sed -n '334'p $SYNAPSECONF 

Known Limitations:
	- For launching multiple simulations, the present qsub must be done launching before you can launch another.


Version History
	- v0.8 First versioned release, allows for simulation launch and automatically syncs a list of desired parameters for quick modification to all of the parameter files. 
	
	- v0.9 Results are saved under a filename that includes date, time, and select parameters used.
		-Plots of resutls are automatically generated after a simulation.
		-Initial installation of NeuroSim is automated into a new option in the menu
		-When setting new parameters between launches, they now automatically syncs when selecting option 1 instead of needing to relaunch neurosim.
		-Fixed bug where uploading multiple files will sometimes fail.
		-Search and Replace of AMPA/NMDA parameters now searches for decimals. 

	- v0.95 The password is now saved in a securely with ssh-keygen.
		- Multiple simulation launches. 
	
	- v0.96 Option to run additional simulation while another qsub is starting
		- parameter files changed so that you can change one of the parameter files and sed will automatically fix the paths in the other parameter files  

	- v0.97 Parameters now placed on parameters.txt instead of in neurosim.sh
	- Fixed potential plotgraph bug where it would try to use the duration from the most recent parameters used rather than the parameters used for that run. 

	- v0.98 Fixed a bug where the automatic plotgraph would fail
	- Added parameters for the Poirazi CA1 model
	   

Bugs/Comments/Questions? Contact Mike Huang mikehuan@usc.edu


