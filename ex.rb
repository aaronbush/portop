#!/usr/bin/env ruby

ports = Array.new
#PortInfo = Struct.new(:hostname, :ifDescr, :ifInOctets, :ifOutOctets)

ports << {
	:hostname => 'coswm01',
	:portID => 'fe0/0',
	:inBits => 20,
	:outBits => 200,
}
ports << {
	:hostname => 'coswm01',
	:portID => 'fe0/1',
	:inBits => 40,
	:outBits => 500,
}
ports << {
	:hostname => 'coswm01',
	:portID => 'fe0/2',
	:inBits => 2,
	:outBits => 0,
}

#ports.each {|p| print p.class}
p ports.sort_by {|p| p[:inBits] }

p ports.find {|p| p[:portID] == "fe0/1" }
