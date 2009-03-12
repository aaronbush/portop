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

Manager.open(:Host => host) do |manager|
	response = manager.get_bulk(0, MAX_ROWS, ["ifDescr", "ifAdminStatus", "ifOperStatus", "ifSpeed", "ifLastChange", "ifInOctets", "ifOutOctets"])
	
	list = response.varbind_list
	portInfo[host] = {}
	portInfo[host]["vb_list"] = list
	portInfo[host]["prev_vb_list"] = list if first_run
	portInfo[host]["vb_list"] = list

	puts portInfo[host]["vb_list"].length
	#puts portInfo[host]["vb_list"][1]
	#puts portInfo[host]["vb_list"][1].name
	#puts portInfo[host]["vb_list"][1].value

	until list.empty?
		ifDescr = list.shift
		ifAdminStatus = list.shift
		ifOperStatus = list.shift
		ifSpeed = list.shift
		ifLastChange = list.shift
		ifInOctets = list.shift
		ifOutOctets = list.shift
		#puts "#{ifDescr.value}    #{ifAdminStatus.value}/#{ifOperStatus.value}	#{ifSpeed.value}	#{ifLastChange.value} AGO"

		ifInRate = ifInOctets.value.to_i - previfInOctets

		puts "#{ifDescr.value}: In[#{ifInOctets.value} - #{previfInOctets}]:#{ifInRate}"
		previfInOctets = ifInOctets.value
		previfOutOctets = ifOutOctets.value

		first_run = FALSE
	end
end
