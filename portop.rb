#!/usr/bin/ruby

require 'rubygems'
require 'snmp'
require 'erb'

include SNMP

class Numeric
	def logA(x, b)
		return (Math.log(x)/Math.log(b))
	end

	# function to print pretty unit names
	def to_U
		return "0 B" unless self > 0

		unitNames = [ "B", "KB", "MB", "GB", "TB" ]
		#puts self
		i = logA(self, 1024).floor
		return "#{(self/1024**i).round} #{unitNames[i]}"
	end

end


MAX_ROWS = 4
HDR = "Description          InRate    OutRate   Admin/Oper    Speed        Last Change"
SEP = "==============================================================================="

puts "\e[H\e[2J"
template_hdr = ERB.new <<-EOF
<%= HDR %>
<%= SEP %>
EOF

template_body = ERB.new <<-EOF
<%= "%-18.18s|%10.10s|%10.10s|%5.5s/%-5.5s|%10.10s|%s|" % [p.ifDescr, p.ifInOctetsDelta.to_U, p.ifOutOctetsDelta.to_U, p.ifAdminStatus.to_U, p.ifOperStatus, p.ifSpeed.to_U, "N/A"] %>
EOF

ports = Array.new
PortInfo = Struct.new(:hostname, :ifDescr, :ifAdminStatus, :ifOperStatus, :ifSpeed, :ifLastChange, :ifInOctets, :ifInOctetsDelta, :ifOutOctets, :ifOutOctetsDelta)

class PortInfo
	def fp(x)
		logA(x, 1024)
	end
end

host = "coswm01"
delay = 1

# ----------------------
# show the current stats
# ----------------------
#puts HDR
#puts SEP


while true do
	Manager.open(:Host => host) do |manager|
		response = manager.get_bulk(0, MAX_ROWS, ["ifDescr", "ifAdminStatus", "ifOperStatus", "ifSpeed", "ifLastChange", "ifInOctets", "ifOutOctets"])
	
		puts template_hdr.result
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
				#p pe
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

		ports.each { |p| puts template_body.result(binding) }

	end # Manager.open: connected to host
	sleep delay
	puts "\e[H\e[2J" 
end # while to keep it going
