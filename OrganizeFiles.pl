#Program Name: OrganizeFiles.pl
#Description: Organizes the files according to modify time.
#Author: Pavan Narendra
#Warning:Use for Windows Only!
#Date: 08/10/2013

use strict;
use POSIX qw(strftime);;
use File::Copy;
use Pod::Usage;
use Getopt::Long;

#Variable declarations
my ($dir, $help);

#Get Options from the command line
GetOptions ("dir=s"      => \$dir,
			"help|h|usage|?"  => \$help) or die("Error in command line arguments\n");

#Check if help is specified
pod2usage(-exitval => 0, -verbose => 2) if $help;

unless(defined $dir) {
	print STDERR "ERROR: -dir is a required parameter.";
	pod2usage(-exitval => 0, -verbose => 2);
}

#Check if the directory passed exists
unless (-e $dir) {
	die ("ERROR: The directory: $dir does not exist.");
}

#Check if the passed parameter is a directory in the first place!
unless (-d $dir) {
	die ("ERROR: $dir is not a directory!");
}

#Find all the files in the directory
opendir (my $dir_hd,$dir) or die ("ERROR: Unable to open directory $dir for reading.$!\n");

#Get the list of all the files.
#my @files = grep { /^\./ && -f "$dir\\$_" } readdir($dir_hd);
my @files = grep {-f "$dir\\$_" } readdir($dir_hd);

#Close the directory handle
closedir $dir_hd;

#Now stat all the files in the directory
#using the array provided above.
foreach my $file (@files) {
	my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$dir\\$file");
	my $file_create = strftime("%Y-%m-%d",localtime($mtime));
	unless (-e "$dir\\$file_create") {
		mkdir "$dir\\$file_create" or die "ERROR: Unable to create folder:"."$dir\\$file_create";
	}
	move "$dir\\$file" , "$dir\\$file_create\\$file" or die "ERROR:Unable to move file:"."$dir\\$file"." To:"."$dir\\$file_create\\$file\n";
}

exit 0;


__END__

=head1 OrganizeFiles.pl

Given a directory, finds all the files in the directory and organizes them according to their modify time.

Example Usage - 
OrganizeFiles.pl
OrganizeFiles.pl -dir "C:\MyPics"

=head1 SYNOPSIS

OrganizeFiles.pl [-dir <Directory Name>]
            [-help]

Options:

-dir		    Required. Directory Path.
-help			Show this screen.

=head1 DESCRIPTION
Given a directory, finds all the files in the directory and organizes them according to their modify time.
=cut