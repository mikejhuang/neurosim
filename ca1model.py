#!/usr/bin/python
import sys
import os
import time
import datetime
import subprocess
import random
from socket import *
from xml.dom import minidom
import neuron
from neuron import h
from neuron import gui

h("""cvode.active(1)""")
# a function that launch rhenoms with the correct number of processes
# launching the process in a new x-terminal might be functional on unix platforms only
def call_rhenoms(N_synapses, xmlFileName):
	time.sleep(0.1)
	# copy the freshly compiled version of the java project
	N_processes = N_synapses+2

	# for local sessions
	os.system('cp -rf /media/Data/RHENOVIA/WORK/SVN_JMB/EONS_SUITE/dist/ .')
	os.system('xterm -geometry 300x30 -sb -rightbar -hold -e \'java -jar $MPJ_HOME/lib/starter.jar -np '+str(N_processes)+' -jar ./dist/eonsv1.1_mat.jar false '+xmlFileName+' false | tee run_PFG.log\' &')

	# for cluster sessions on master node
	#os.system('scp -r arnaud@192.168.2.104:/media/Data/RHENOVIA/WORK/SVN_JMB/EONS_SUITE/dist/ .')

	#os.system('xterm -geometry 120x73 -sb -rightbar -hold -e \'java -jar $MPJ_HOME/lib/starter.jar -dev niodev -machinesfile ./machines -np '+str(N_processes)+' -jar ./dist/eonsv1.1_mat.jar false SimulationParameters.xml false | tee run_PFG.log\' &')

	print "RHENOMS invocated with : "+str(N_synapses)+' Synapses'

xmlfilename="masterconf_ca1model_30syn.xml"
xmldoc = minidom.parse(xmlfilename)

# Initialize the server programs 
host_i = 'localhost'
port_i=41012
buff_i = 1024
addr_i = (host_i,port_i)
# this loop to choose available ports
#erreur = True
#while erreur == True:
#	try:
#		port_i = random.randint(33000, 60000)
#		print "Try @port_i="+str(port_i)
#		sys.stdout.flush()
#		testsocket = socket(AF_INET, SOCK_STREAM)
#		testsocket.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1) # this one should guarantee that the adress is realeased pretty fast
#		addr_i = (host_i,port_i)
#		testsocket.bind(addr_i)
#		testsocket.listen(2)
#		erreur = False
#	except:
#		erreur = True

# client socket is affected with serversocket port +1
host_j = 'localhost'
port_j = 41010
buff_j = 1024
addr_j = (host_j,port_j)

print "server socket @port_i="+str(port_i)
print "client socket @port_j="+str(port_j)

testsocket = socket(AF_INET, SOCK_STREAM)
testsocket.bind(addr_i)
testsocket.listen(2)



# we shall write this to the xml file 
#xmldoc.getElementsByTagName('port_i')[0].childNodes[0].nodeValue = port_i
#xmldoc.getElementsByTagName('port_j')[0].childNodes[0].nodeValue = port_j

# This part is to setup the simulation results directory
now = datetime.datetime.now()
ResultsDirectory = str(os.getcwd())+"/Results_"+str(now.year)+"_"+str(now.month)+"_"+str(now.day)+"_"+str(now.hour)+":"+str(now.minute)+":"+str(now.second)

if not os.path.exists(ResultsDirectory):
	os.makedirs(ResultsDirectory)
else:
	print ResultsDirectory+" already exists, please try again" 
	sys.exit()

xmldoc.getElementsByTagName('ResultsDirectory')[0].childNodes[0].nodeValue = ResultsDirectory

file = open(xmlfilename,'w')
file.write(xmldoc.toxml()) 
file.close()

print "Configurationfile "+xmlfilename+" has been  updated"

# ======================================================
# Initialize parameters from the XML file
# ======================================================

simduration = float(xmldoc.getElementsByTagName('Duration')[0].firstChild.data)
stepsize = float(xmldoc.getElementsByTagName('StepSize')[0].firstChild.data)
comFactor = int(xmldoc.getElementsByTagName('ComFactor')[0].firstChild.data)

if xmldoc.getElementsByTagName('DebugMode')[0].firstChild.data == "false":
	DEBUG=False
else:
	DEBUG=True

print "DEBUGMODE = "+str(DEBUG)
print  "simduration = ", simduration
print  "stepsize = ", stepsize
print  "comFactor = ", comFactor

# portsend send data to synapses
def portSend(dend_data):
	tcpCliSock = socket(AF_INET, SOCK_STREAM)
	errno = 1
	while errno != 0:
		errno = tcpCliSock.connect_ex(addr_j)
		#print repr(errno)
	sendData = str(dend_data)
	tcpCliSock.send(sendData)
        #print "Outgoing Message : " + sendData
	tcpCliSock.shutdown(SHUT_RDWR)
	tcpCliSock.close()

# portListen waits and receive data from synapses
def portListen(testsocket):
	while 1:
		#print "Waiting for data from synapses"
		clientsock, clientaddr  = testsocket.accept()
		data = clientsock.recv(buff_i)
		#print "Incoming mesage : " +  data
                clientsock.shutdown(SHUT_RDWR)
		clientsock.close()
		mystring = str(data)
		break
	return mystring

now1 = datetime.datetime.now()
# ======================================================
# BEGIN POIRAZI
# ======================================================
# parametrizing the NRN model
h('load_proc("nrnmainmenu")')
h('xopen("../template/ExperimentControl.hoc")')
h('xopen("../template/EPSPTuning.hoc")')
h('xopen("../template/RangeRef.hoc")')
h('xopen("../template/BasalPath.hoc")')
h('xopen("../template/ObliquePath.hoc")')
#Load more required libraries
h('load_template("ObliquePath")')
h('load_template("BasalPath")')

h('cvode_active(0)')

h('objref econ')                          
h('show_errs=1')
h('debug_lev=1')
h('econ=new ExperimentControl(show_errs,debug_lev)')
h('econ.self_define(econ)')
h('econ.add_lib_dir("Terrence","../lib")')
h('econ.generic_dir    = "../experiment/"')
h('strdef tips_dir')
h('tips_dir = "../single-branch-potency/data/Apical_Tips"')
h('actual_resolution=75')
h('desired_resolution=1')
h('maximum_segment_length=actual_resolution')

h('objref cell,  stimes, sg, tst')
h('xopen("CA1Pyr.hoc")')
h('cell = new CA1Pyr(econ)')

h('load_file("Spine.hoc")')
#h('initchannels()')

# ======================================================
# END POIRAZI
# ======================================================

DEND_IDS = []
RHESYN_POSITIONS = []
N_RHESYN = 0

neuronNodes = xmldoc.getElementsByTagName('Neuron')
# ATTENTION, cette config, dans son ensemble, ne marche que pour un seul neuron
for neuron in neuronNodes:
	description = neuron.getAttribute('description')
	name = neuron.getAttribute('name')
	print name, description
	synapses = neuron.getElementsByTagName('Synapse')
	for synapse in synapses:
		positionNode = synapse.getElementsByTagName('Position')[0]
		section = positionNode.getAttribute('Section')
		position = positionNode.childNodes[0].data
		DEND_IDS.append(section)
		RHESYN_POSITIONS.append(position)
		N_RHESYN = N_RHESYN + 1

print DEND_IDS
print RHESYN_POSITIONS
print N_RHESYN


# creates the object references (synapses + current clamps)
h('objref RHESYN['+str(N_RHESYN)+']')
h('objref I_RHESYN['+str(N_RHESYN)+']')
# creates teh section lists related to activated dendrites and synapses
h('objref ActiveDendrites, RHESpines')
h('ActiveDendrites = new SectionList()')
h('RHESpines = new SectionList()')


for i_syn in range(N_RHESYN):
	print i_syn
	h(DEND_IDS[i_syn]+' ActiveDendrites.append()') # fill in the section list
	h('RHESYN['+str(i_syn)+'] = new Spine()') # instantiation of the Spine template
	h('RHESYN['+str(i_syn)+'].neck RHESpines.append()') # neck added to the section list
	h('RHESYN['+str(i_syn)+'].spine RHESpines.append()') # spine added to the section list
	h(DEND_IDS[i_syn]+' connect RHESYN['+str(i_syn)+'].neck(1), '+RHESYN_POSITIONS[i_syn]+' ') # connection to the dendrite
	h('RHESYN['+str(i_syn)+'].spine I_RHESYN['+str(i_syn)+'] = new IClamp(0)') # instatiation of the IClamp
	h('I_RHESYN['+str(i_syn)+'].del = 0') # always on
	h('I_RHESYN['+str(i_syn)+'].dur = 1e12') # never stops
          
#initialization of neuron
h.dt =stepsize*comFactor/250
h.steps_per_ms = 1/stepsize
h('Vrest = -70')
h.finitialize(h.Vrest)
h.fcurrent()

now=time.localtime(time.time())
filename="NRN"+time.strftime("%y%m%d%H%M",now) + ".dat"
file =open(filename,'w')

ct = 0

plotA = False
# plot branches
if (plotA):
	h('objref s')
	h('s = new Shape()')
	h('s = fast_flush_list.object(fast_flush_list.count()-1)')
#	h('fast_flush_list.append(s)')
	h('s.view(-50,-150,500,550,1680,0,840,1050) //view(mleft, mbottom, mwidth, mheight, sleft, stop,swidth, sheight)')
	h('s.exec_menu("Show Diam")')
	h('s.exec_menu("Zoom in/out")')
	h('s.exec_menu("View Axis")')
	h('forsec ActiveDendrites s.color(2)')
	h('forsec RHESpines s.color(3)')

# plot membrane potential along the simulation
plotB = False
if(plotB):
	h.newshapeplot()
	shapeWindow=h.fast_flush_list.object(h.fast_flush_list.count()-1)
#	shapeWindow.size(-5,15,-5,10)
	shapeWindow.variable('v')
	shapeWindow.view(0,250,70,50,1680+840,0,840,1050) #view(mleft, mbottom, mwidth, mheight, sleft, stop,swidth, sheight)
	shapeWindow.exec_menu('Shape Plot')
	shapeWindow.scale(-70.0,50.0)
	shapeWindow.exec_menu("Show Diam")
	shapeWindow.exec_menu("View Axis")

print "NEURON IS READY TO START"

#call_rhenoms(N_RHESYN, xmlfilename)

print "Initialization duration = "+str(datetime.datetime.now()-now1)
sys.stdout.flush()

now1 = datetime.datetime.now()

# Loop
timestamp = 0

nrn2Syn=comFactor
syn2Nrn=comFactor

while (h.t<simduration):
	try:
		if (timestamp < (int)(100*h.t / simduration)):
			timestamp = (int)(100*h.t / simduration)
			print str(timestamp)+" % simulated - t = "+repr(h.t)+" / "+str(simduration)+" ms"

		#if(plotB): 
		#	shapeWindow.flush()
		#	h('{s.flush()}')
		if(DEBUG):
			print "time = " + repr(h.t) 
		# Good time to receive data from EONS


	#	now2 = datetime.datetime.now()

		if ( syn2Nrn == comFactor ):
			# init this counter
			syn2Nrn = 0
			# retrieve data
			xstr = portListen(testsocket)
		#	if(DEBUG):
	       #        print "RECEIVING: time = " + repr(h.t)+" : " + xstr
			sys.stdout.flush()
			exec xstr

	
         #      print "Receiving  duration = "+str(datetime.datetime.now()-now2)
				

		for i in range(N_RHESYN) :
			h.I_RHESYN[i].amp = a[i]*0.001*-1*1 # a in pA, NRN uses
nA -> *0.001 / convention *-1 / N clustered synapses

		h('{fadvance()}')

               
                
#		if (h.t>=simduration):
#			break



	#	now3 = datetime.datetime.now()


		# GOOD TIME TO SEND DATA TO EONS
		if ( nrn2Syn == comFactor ):
			# increment the next comm time
			nrn2Syn = 0
			if(DEBUG):
				print "SENDING: time = " + repr(h.t)
			sys.stdout.flush()

			# prepare message
			send_msg = ""

			for i in range(N_RHESYN) :
				send_msg += str(h.RHESYN[i].spine(0.5).v)+'\t'
			# send data to java
			portSend(send_msg)
		
                 #if(DEBUG):
		#        print "data sent : " + send_msg
		#sys.stdout.flush()



         #       print "Sending  duration = "+str(datetime.datetime.now()-now3)

		        

		#now4 = datetime.datetime.now()

		# WRITING RESULTS
	                dataline=repr(h.t) + "\t"
		#for i in range(N_RHESYN):
			dataline+= str(h.RHESYN[1].spine(0.5).v)+'\t'
			dataline+= str(h.CA1Pyr[0].soma[1].v)+"\n" 

	        file.write(dataline)
	

          #      print "Writing duration = "+str(datetime.datetime.now()-now4)

  		# increment counters
		syn2Nrn = syn2Nrn + 1
		nrn2Syn = nrn2Syn + 1
		ct = ct+1

		# END OF SIMULATION LOOP
	except (KeyboardInterrupt, SystemExit):
		print "simulation interrupted by user ... will now halt"
		sys.stdout.flush()
		testsocket.close()
		h('quit()')
		file.close()
		sys.exit()

portSend(11111)

print "end of simulation loop @time = "+str(h.t)+" ms"
print "Simulation duration = "+str(datetime.datetime.now()-now1)

file.close()
sys.exit()
