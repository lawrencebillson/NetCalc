#!/usr/bin/perl
#
# Rough and ready network calculator, Lawrence Billson
#

if (!$ARGV[0]) {
	die "Usage: ./netcalc <network size> [IP address]\nExample: ./netcalc 26 192.168.1.240\n";
	}

sub l2q {
	return  join('.',unpack('C4', pack('N',shift)));
	}

sub q2l {
	return unpack('N', (pack 'C4', split(/\./,shift)));
	}


$block = $ARGV[0];

if ($block < 0) {
	print "Usage: ./netcalc <netblock> <IP address (optional)>\n";
	exit(1);
	}

$block =~ s/\///;

#
# How many host bits in our netblock
$hostbits = 32 - $block;
#
# How many hosts
$hosts = 2 ** $hostbits;
$useable = $hosts - 2;

# Netmask
# Formula for a netmask = 2^32 - hosts, represented in dotted quad 
$mask = (2 ** 32) - $hosts;
#
# Convert it to a dotted quad
$netmask = l2q($mask);

# Hostmask 
$hmask = 2 ** 32 - $mask;
$hmask--;
$qhmask = l2q($hmask);

print "Hosts: \t\t\t$hosts\nUsable:\t\t\t$useable\nNetmask: \t\t$netmask (Cisco Hostmask $qhmask)\n";
# How many Cs?
$ncclass = $hosts / 256;
print "Relative size (/24):\t$ncclass\n";

# Neat trick - boundary scan
if (!$ARGV[1]) {
	exit(0);
	}
else {
	# Convert the IP address into decimal
	$decimal = q2l($ARGV[1]);
	# Which network is it in?
	$div = int($decimal / $hosts);


	# Let's turn this into human readable dotted quad
	$dsubnet = $div * $hosts;
	$qsubnet = l2q($dsubnet);
	print "\nThis host is part of $qsubnet/$block\n";

	# First host
	$dfirst = $dsubnet + 1;
	$first = l2q($dfirst);
	
	# Broadcast
	$dbroadcast = $dsubnet + $hosts - 1;
	$broadcast = l2q($dbroadcast);

	# Last host
	$dlast = $dbroadcast - 1;
	$last = l2q($dlast);

	print "First host:\t$first\nLast host:\t$last\nBroadcast:\t$broadcast\n";

	exit(0);		
}
