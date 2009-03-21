#!/usr/bin/ruby

require 'rubygems'
require 'snmp'
require 'erb'

include SNMP

MAX_ROWS = 4
HDR = "Description    InRate    OutRate    AdminState/OperState    Speed        Last Change"
SEP = "===================================================================================="

template_hdr == ERB.new <<-EOF
	<%= HDR %>
	<%= SEP %>
EOF

template_body = ERB.new <<-EOF
% port.each do |p|
p.ifDescr
% end
EOF

ports = Array.new
PortInfo = Struct.new(:hostname, :ifDescr, :ifAdminStatus, :ifOperStatus, :ifSpeed, :ifLastChange, :ifInOctets, :ifInOctetsDelta, :ifOutOctets, :ifOutOctetsDelta)

host = "coswm01"
delay = 2

# ----------------------
# show the current stats
# ----------------------
puts HDR
puts SEP

while true do
	Manager.open(:Host => host) do |manager|
		response = manager.get_bulk(0, MAX_ROWS, ["ifDescr", "ifAdminStatus", "ifOperStatus", "ifSpeed", "ifLastChange", "ifInOctets", "ifOutOctets"])
	
		list = response.varbind_list
	
		until list.empty?
			ifDescr = list.shift.value.to_s
			ifAdminStatus = list.shift.value.to_i
			ifOperStatus = list.shift.value.to_i
			ifSpeed = list.shift.value.to_f
			ifLastChange = list.shift
			ifInOctets = list.shift.value.to_f
			ifOutOctets = list.shift.value.to_f

			# are we updating an existing element?
			if pe = ports.find { |port| port.hostname == host && port.ifDescr == ifDescr }
				p pe
				pe.ifInOctetsDelta = (ifInOctets - pe.ifInOctets)
				pe.ifInOctets = ifInOctets 
				pe.ifOutOctetsDelta = (ifOutOctets - pe.ifOutOctets)
				pe.ifOutOctets = ifOutOctets 
			else
				ports.push(
					PortInfo.new(
						host,
						ifDescr,
						ifAdminStatus,
						ifOperStatus,
						ifSpeed,
						ifLastChange,
						ifInOctets,
						0, # ifInOctetsDelta
						ifOutOctets,
						0 # ifOutOctetsDelta
					)
				)
				#p ports
			end

		end # until done with result set

	end # Manager.open

	sleep delay
end # while to keep it going
