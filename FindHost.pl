#Program Name: FindHost.pl
#Description: Finds the hosts connected on the requested network.
#Author: Pavan Narendra
#Date: 10/18/2013

use strict;
use Net::Ping;
use Sys::Hostname;
use Getopt::Long;
use Pod::Usage;
#use List::MoreUtils 'any';
use Socket;

#Variable declarations
my ($net_addr,$mask_addr);
my @exclude_addrs;
my $help;

#Function declarations
sub startPing($);

#Get Options from the command line
GetOptions ("net_addr=s"      => \$net_addr,
            "exclude_list=s@" => \@exclude_addrs,
			"help|h|usage|?"  => \$help) or die("Error in command line arguments\n");

#Check if help is specified
pod2usage(-exitval => 0, -verbose => 2) if $help;

#Options processing
if ($net_addr) {
   print "Net Address = ".$net_addr."\n";
   $net_addr = inet_aton($net_addr) or die ("The passed address not in the required format. Example format is: 192.168.0\n");
   #$net_addr = inet_pton($net_addr) or die ("The passed address not in the required format. Example format is: 192.168.0\n");
   $mask_addr = $net_addr & inet_aton('255.255.255.0');
}
else {
#Assign by default current IP Octet
  my $host = hostname();
  print "Local Host = $host\n";

  my $ip_addr = scalar gethostbyname( $host );

  #If unable to resolve hostname to ipaddress
  unless ($ip_addr) {
    $ip_addr = scalar gethostbyname( 'localhost' );
  }
  
  if ( ! defined $ip_addr ) {
     print "Error: Unable to resolve hostname: $! \n";
     exit(-1); 
  }
  my $net_addr = inet_ntoa( $ip_addr );
  print "Using current network address:".$net_addr."\n";
  $mask_addr = inet_aton($net_addr) & inet_aton('255.255.255.0');

  push ( @exclude_addrs, $net_addr );
}

print "Masked address is:". inet_ntoa ($mask_addr)."\n";

#Now Validate Exclude addresses
foreach my $ex_addr (@exclude_addrs) {
   die ("Invalid Exclude Address passed: $ex_addr\n") unless ( inet_aton ($ex_addr) );
}

print "Size of exclude_addrs:".@exclude_addrs."\n";

#Now start the ping finally!
for (my $c = 0; $c < 51; $c++) {
   my $pid = fork();
   die "fork() failed: $!\n" unless defined $pid;
   if ($pid) {
       #parent
       wait if ($c != 0 && $c % 5 == 0);
   }
   else {
      startPing (5*$c);
	  exit (0);
   }
}

#User Input
<>;

exit 0;

sub startPing($) {
   my $start = shift;
   
   #Initialize ping!
   my $p = Net::Ping->new();
   for (my $c = 0; $c < 5; $c++) {
      my $octet = $start + $c;
	  my $a_value = inet_ntoa($mask_addr | inet_aton("0.0.0.$octet") );
	  #next if (any { /^$a_value$/ } @exclude_addrs);
	  my @temp = grep { /^$a_value$/ } @exclude_addrs;
	  next if ($#temp >= 0);
	  print "$a_value is active.\n" if $p->ping($a_value);
   }
   $p->close();
}

__END__

=head1 FindHost.pl

Finds the hosts connected on the requested network.

Example Usage - 
FindHost.pl
FindHost.pl -net_addr 192.168.0
FindHost.pl -net_addr 192.168.0 -exclude_list 192.168.0.1 -exclude_list 192.168.0.32

=head1 SYNOPSIS

FindHost.pl [-net_addr <Incomplete Network Address to be searched - 3 Octets only>]
            [-exclude_list <The address that need to excluded from the search>]
            [-help]

Options:

-net_addr		Incomplete Network Address to be searched - 3 Octets only. Default Current network octet.
-exclude_list	Current IP Address.
-help			Show this screen.

=head1 DESCRIPTION
Finds the hosts connected on the requested network.
=cut
