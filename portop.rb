#!/usr/bin/ruby

require 'rubygems'
require 'snmp'
include SNMP

MAX_ROWS = 4
previfInOctets = 0
previfOutOctets = 0

portInfo = {}
host = "coswm01"
first_run = TRUE

while true do
Manager.open(:Host => host) do |manager|
	response = manager.get_bulk(0, MAX_ROWS, ["ifDescr", "ifAdminStatus", "ifOperStatus", "ifSpeed", "ifLastChange", "ifInOctets", "ifOutOctets"])
	
	list = response.varbind_list
	portInfo[host] = {}
	portInfo[host]["vb_list"] = list
	portInfo[host]["prev_vb_list"] = list if first_run
	portInfo[host]["vb_list"] = list

	#puts portInfo[host]["vb_list"].length
	#puts portInfo[host]["vb_list"][1]
	#puts portInfo[host]["vb_list"][1].name
	#puts portInfo[host]["vb_list"][1].value

	# ----------------------
	# show the current stats
	# ----------------------

	puts "Description    InRate    OutRate    AdminState/OperState    Speed        Last Change"
	puts "===================================================================================="

	until list.empty?
		ifDescr = list.shift
		ifAdminStatus = list.shift
		ifOperStatus = list.shift
		ifSpeed = list.shift
		ifLastChange = list.shift
		if first_run
			ifInOctets = "?"
			ifOutOctets = "?"
			ifInRate = "N/A"
			ifOutRate = "N/A"
			list.shift
			list.shift
		else
			ifInOctets = list.shift
			ifOutOctets = list.shift
			ifInRate = ifInOctets.value.to_i - previfInOctets
			ifOutRate = ifOutOctets.value.to_i - previfOutOctets
		end
		#puts "#{ifDescr.value}    #{ifAdminStatus.value}/#{ifOperStatus.value}	#{ifSpeed.value}	#{ifLastChange.value} AGO"


		puts "#{ifDescr.value}   #{ifInRate}    #{ifOutRate}    #{ifAdminStatus.value}/#{ifOperStatus.value} #{ifSpeed.value}  #{ifLastChange.value}"

		first_run = FALSE
	end
end

end # keep it going
