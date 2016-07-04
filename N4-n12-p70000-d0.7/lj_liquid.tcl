#############################################################           
#                                                           #
#  Lennard Jones Liquid                                     #
#                                                           #
#############################################################
#
# Copyright (C) 2010,2012,2013,2014,2015,2016 The ESPResSo project
# Copyright (C) 2002,2003,2004,2005,2006,2007,2008,2009,2010 
#   Max-Planck-Institute for Polymer Research, Theory Group
#  
# This file is part of ESPResSo.
#  
# ESPResSo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  
# ESPResSo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>. 
#  

puts " "
puts "======================================================="
puts "=       lj_timer.tcl                                  ="
puts "======================================================="
puts " "

puts "Program Information: \n[code_info]\n"

#############################################################
#  autogenerated:                                           #
#############################################################
# add in options later?
# backup_frequency : back it up every n runs
set max_time              7200
set backup_timer          100
set density               0.7
set n_part                70000
set int_n_times           10
set int_steps             1000
set sim_type              "Exclusive"
set sim_nodes             4
set sim_procs             12
set espresso_version      "ESPResSo-3.2.0-3463-gf503972-git"
set boost_version         "1.60.0"
set mpi_version           "1.10.1"
set simulation_date       2016-06-26-18-33
set modules_loaded        "fftw/3.3.4/gcc,cuda/7.5,hdf5/1.8.15/gcc,openmpi/1.10.1,binutils/2.25,gcc/4.9.3,boost/1.60.0,python/2.7"
set simulation_name       "look at dirname"
set custom_compileflags   "none"
set measure_sdterr        "yes"
set number_of_timers      10
set output_file           [open "simulation.output" "w"]
set backup_file           [open "simulation.backup" "w"]

#############################################################
#  Write information to files                                #
#############################################################


puts $output_file "\{"
puts $output_file "\"Nodes\":\"$sim_nodes\","
puts $output_file "\"Processes\":\"$sim_procs\","
puts $output_file "\"Timelimit\":\"$max_time\","
puts $output_file "\"Backuprate\":\"$backup_timer\","
puts $output_file "\"Density\":\"$density\","
puts $output_file "\"Particles\":\"$n_part\","
puts $output_file "\"Runs\":\"$int_n_times\","
puts $output_file "\"IntPerRun\":\"$int_steps\","
puts $output_file "\"SimulationType\":\"$sim_type\","
puts $output_file "\"ESPResSoVersion\":\"$espresso_version\","
puts $output_file "\"BoostVersion\":\"$boost_version\","
puts $output_file "\"MPIVersion\":\"$mpi_version\","
puts $output_file "\"Date\":\"$simulation_date\","
puts $output_file "\"ModulesLoaded\":\"$modules_loaded\","
puts $output_file "\"Simulation\":\"$simulation_name\","
puts $output_file "\"CompileFlags\":\"$custom_compileflags\","
puts $output_file "\"MeasureStdErr\":\"$measure_sdterr\""
flush $output_file


puts $backup_file "\{"
puts $backup_file "\"Nodes\":\"$sim_nodes\","
puts $backup_file "\"Processes\":\"$sim_procs\","
puts $backup_file "\"Timelimit\":\"$max_time\","
puts $backup_file "\"Backuprate\":\"$backup_timer\","
puts $backup_file "\"Density\":\"$density\","
puts $backup_file "\"Particles\":\"$n_part\","
puts $backup_file "\"Runs\":\"$int_n_times\","
puts $backup_file "\"IntPerRun\":\"$int_steps\","
puts $backup_file "\"SimulationType\":\"$sim_type\","
puts $backup_file "\"ESPResSoVersion\":\"$espresso_version\","
puts $backup_file "\"BoostVersion\":\"$boost_version\","
puts $backup_file "\"MPIVersion\":\"$mpi_version\","
puts $backup_file "\"Date\":\"$simulation_date\","
puts $backup_file "\"ModulesLoaded\":\"$modules_loaded\","
puts $backup_file "\"Simulation\":\"$simulation_name\","
puts $backup_file "\"CompileFlags\":\"$custom_compileflags\","
puts $backup_file "\"MeasureStdErr\":\"$measure_sdterr\""
flush $backup_file






#############################################################
#  Parameters                                               #
#############################################################

# System identification: 
set name  "lj_liquid"
set ident "_s1"


# Interaction parameters (repulsive Lennard Jones)
#############################################################

set lj1_eps     1.0
set lj1_sig     1.0
set lj1_cut     1.12246

# Integration parameters
#############################################################

setmd time_step 0.01
setmd skin      0.4
thermostat langevin 1.0 1.0

# warmup integration (with capped LJ potential)
set warm_steps   100
set warm_n_times 30
# do the warmup until the particles have at least the distance min__dist
set min_dist     0.9

# Other parameters
#############################################################
set tcl_precision 6

#############################################################
#  Setup System                                             #
#############################################################


# Interaction setup
#############################################################
set box_l [expr ($n_part/$density)**(1./3.)] 
puts $box_l
setmd box_l $box_l $box_l $box_l
inter 0 0 lennard-jones $lj1_eps $lj1_sig $lj1_cut auto


# Particle setup
#############################################################
set volume [expr $box_l*$box_l*$box_l]
#set n_part [expr floor($volume*$density)]
for {set i 0} { $i < $n_part } {incr i} {
    set posx [expr $box_l*[t_random]]
    set posy [expr $box_l*[t_random]]
   set posz [expr $box_l*[t_random]]
    part $i pos $posx $posy $posz type 0
}
puts "Simulate $n_part particles in a cubic simulation box "
puts "[setmd box_l] at density $density"
puts "Interactions:\n[inter]"
set act_min_dist [analyze mindist]
puts "[part 0]"
puts "[part 1]"
puts "Start with minimal distance $act_min_dist"
setmd max_num_cells 2744


#############################################################
#  Warmup Integration                                       #
#############################################################
puts "\nStart warmup integration:"
puts "At maximum $warm_n_times times $warm_steps steps"
puts "Stop if minimal distance is larger than $min_dist"
# set LJ cap
set cap 20
inter forcecap $cap
# Warmup Integration Loop
set i 0
while { $i < $warm_n_times && $act_min_dist < $min_dist } {
    integrate $warm_steps
    # Warmup criterion
    set act_min_dist [analyze mindist]
    puts -nonewline "run $i at time=[setmd time] (LJ cap=$cap) min dist = $act_min_dist\r\n"
    flush stdout
    #   Increase LJ cap
    set cap [expr $cap+10]
    inter forcecap $cap
    incr i
}


# Just to see what else we may get from the c code
puts "\nro variables:"
puts "cell_grid     [setmd cell_grid]" 
puts "cell_size     [setmd cell_size]" 
puts "local_box_l   [setmd local_box_l]" 
puts "max_cut       [setmd max_cut]" 
puts "max_part      [setmd max_part]" 
puts "max_range     [setmd max_range]" 
puts "max_skin      [setmd max_skin]" 
puts "n_nodes       [setmd n_nodes]" 
puts "n_part        [setmd n_part]" 
puts "n_part_types  [setmd n_part_types]" 
puts "periodicity   [setmd periodicity]" 
puts "transfer_rate [setmd transfer_rate]" 
puts "verlet_reuse  [setmd verlet_reuse]" 


#############################################################
#      Integration                                          #
#############################################################
puts "\nStart integration: run $int_n_times times $int_steps steps"
inter forcecap 0
puts [analyze energy]

set i 0
while {$i < $int_n_times} {
    puts -nonewline "run $i at time=[setmd time] \n"
    integrate $int_steps
    #   write observables
    set energies [analyze energy]
    
    if {$i%$backup_timer==0} {
	puts $backup_file "\"$i\": \["
	set n 1
	foreach t [timer] {
	    puts $backup_file "  \["
	    puts $backup_file "    \"[lindex $t 0]\","
	    puts $backup_file "    \"[lindex $t 1]\","
	    puts $backup_file "    \"[lindex $t 2]\","
	    puts $backup_file "    \"[lindex $t 3]\","
	    puts $backup_file "    \"[lindex $t 4]\","
	    puts $backup_file "    \"[lindex $t 5]\","
	    puts $backup_file "    \"[lindex $t 6]\","
	    puts $backup_file "    \"[lindex $t 7]\""
	    if {$n%[expr {$number_of_timers * $sim_procs}]} {
		puts $backup_file "  \],"
	    } else {
		puts $backup_file "  \]"
	    }
	    incr n
	}
	puts $backup_file "  \],"
        flush $backup_file
    }

    if { $i%10==0 } {
	#puts "RUN $i OF $int_n_times"
	set flip 0
		foreach t [timer] {
	    set  boundary [expr { 0.01 * [lindex $t 2] }]
	    set  stderr [expr { [lindex $t 3] / sqrt([lindex $t 7 ]) }]
	    if {$boundary<=$stderr} {
	#	puts "CONTINUE \t MEAN: [lindex $t 2] \t BOUNDARY: $boundary STDERR: $stderr \t [lindex $t 1]"
		if {$measure_sdterr=="yes"} {
		    incr flip
		}
		
		break
	    }
	}
	if {$flip>0} {
	    set remaining_runs [expr {$int_n_times - $i}]
	    if {$remaining_runs < 20} {
		incr int_n_times 11
	    }
	}
    }

    
    incr i
}


# terminate program
puts "\n\nFinished"



puts "MPIPID   MEAN            SIG             VARIANCE        MIN             MAX                  SAMPLES    TIMER"
foreach t [timer] {
    puts "[lindex $t 0] \t [lindex $t 2] \t [lindex $t 3] \t [lindex $t 4]  \t [lindex $t 5] \t [lindex $t 6]  \t [format %10d [lindex $t 7]] \t [lindex $t 1]"
#    puts "$t"
}



puts $output_file "\"Data\": \["
set n 1
foreach t [timer] {
    puts $output_file "  \["
    puts $output_file "    \"[lindex $t 0]\","
    puts $output_file "    \"[lindex $t 1]\","
    puts $output_file "    \"[lindex $t 2]\","
    puts $output_file "    \"[lindex $t 3]\","
    puts $output_file "    \"[lindex $t 4]\","
    puts $output_file "    \"[lindex $t 5]\","
    puts $output_file "    \"[lindex $t 6]\","
    puts $output_file "    \"[lindex $t 7]\""
    if {$n%[expr {$number_of_timers * $sim_procs}]} {
	puts $output_file "  \],"
    } else {
	puts $output_file "  \]"
    }
    incr n
}
puts $output_file "\],"


puts $output_file "\"RunsTaken\":\"$i\","
puts $output_file "\"State\":\"SUCCESS\""
puts $output_file "\}"
flush $output_file

puts $backup_file "\}"
flush $backup_file

exit
