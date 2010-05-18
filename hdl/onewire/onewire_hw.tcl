# TCL File Generated by Component Editor 9.1sp2
# Tue May 18 08:15:26 CEST 2010
# DO NOT MODIFY


# +-----------------------------------
# | 
# | onewire "onewire" v1.1
# | Iztok Jeras 2010.05.18.08:15:26
# | 1-wire master
# | 
# | /home/izi/Workplace/fpga-hdl/hdl/onewire/onewire.v
# | 
# |    ./onewire.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module onewire
# | 
set_module_property DESCRIPTION "1-wire master"
set_module_property NAME onewire
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property GROUP "Interface Protocols/Serial"
set_module_property AUTHOR "Iztok Jeras"
set_module_property DISPLAY_NAME onewire
set_module_property TOP_LEVEL_HDL_FILE onewire.v
set_module_property TOP_LEVEL_HDL_MODULE onewire
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file onewire.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter CDR INTEGER 10
set_parameter_property CDR DEFAULT_VALUE 10
set_parameter_property CDR DISPLAY_NAME CDR
set_parameter_property CDR UNITS None
set_parameter_property CDR DISPLAY_HINT ""
set_parameter_property CDR AFFECTS_GENERATION false
set_parameter_property CDR HDL_PARAMETER true
add_parameter ADW INTEGER 32
set_parameter_property ADW DEFAULT_VALUE 32
set_parameter_property ADW DISPLAY_NAME ADW
set_parameter_property ADW ENABLED false
set_parameter_property ADW UNITS None
set_parameter_property ADW DISPLAY_HINT ""
set_parameter_property ADW AFFECTS_GENERATION false
set_parameter_property ADW HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_reset
# | 
add_interface clock_reset clock end

set_interface_property clock_reset ENABLED true

add_interface_port clock_reset clk clk Input 1
add_interface_port clock_reset rst reset Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave
# | 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressAlignment DYNAMIC
set_interface_property avalon_slave associatedClock clock_reset
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave isMemoryDevice false
set_interface_property avalon_slave isNonVolatileStorage false
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave printableDevice false
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitStates 0
set_interface_property avalon_slave readWaitTime 0
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0

set_interface_property avalon_slave ASSOCIATED_CLOCK clock_reset
set_interface_property avalon_slave ENABLED true

add_interface_port avalon_slave avalon_read read Input 1
add_interface_port avalon_slave avalon_write write Input 1
add_interface_port avalon_slave avalon_writedata writedata Input ADW
add_interface_port avalon_slave avalon_readdata readdata Output ADW
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point interrupt_sender
# | 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint avalon_slave

set_interface_property interrupt_sender ASSOCIATED_CLOCK clock_reset
set_interface_property interrupt_sender ENABLED true

add_interface_port interrupt_sender avalon_interrupt irq Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit
# | 
add_interface conduit conduit end

set_interface_property conduit ASSOCIATED_CLOCK clock_reset
set_interface_property conduit ENABLED true

add_interface_port conduit owr_oe export Output 1
add_interface_port conduit owr_i export Input 1
# | 
# +-----------------------------------
