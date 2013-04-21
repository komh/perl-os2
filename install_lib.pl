#!perl

# Initialisation code and subroutines shared between installperl and installman
# Probably installhtml needs to join the club.

use strict;
use vars qw($Is_VMS $Is_W32 $Is_OS2 $Is_Cygwin $Is_Darwin $Is_NetWare
	    %opts $packlist);
use subs qw(unlink link chmod);

use Config;
BEGIN {
    if ($Config{userelocatableinc}) {
	# This might be a considered a hack. Need to get information about the
	# configuration from Config.pm *before* Config.pm expands any .../
	# prefixes.
	#
	# So we set $^X to pretend that we're the already installed perl, so
	# Config.pm doesits ... expansion off that location.

	my $location = $Config{initialinstalllocation};
	die <<'OS' unless defined $location;
$Config{initialinstalllocation} is not defined - can't install a relocatable
perl without this.
OS
	$^X = "$location/perl";
	# And then remove all trace of ever having loaded Config.pm, so that
	# it will reload with the revised $^X
	undef %Config::;
	delete $INC{"Config.pm"};
	delete $INC{"Config_heavy.pl"};
	delete $INC{"Config_git.pl"};
	# You never saw us. We weren't here.

	require Config;
	Config->import;
    }
}

if ($Config{d_umask}) {
    umask(022); # umasks like 077 aren't that useful for installations
}

$Is_VMS = $^O eq 'VMS';
$Is_W32 = $^O eq 'MSWin32';
$Is_OS2 = $^O eq 'os2';
$Is_Cygwin = $^O eq 'cygwin';
$Is_Darwin = $^O eq 'darwin';
$Is_NetWare = $Config{osname} eq 'NetWare';

sub unlink {
    my(@names) = @_;
    my($cnt) = 0;

    return scalar(@names) if $Is_VMS;

    foreach my $name (@names) {
	next unless -e $name;
	chmod 0777, $name if ($Is_OS2 || $Is_W32 || $Is_Cygwin || $Is_NetWare);
	print "  unlink $name\n" if $opts{verbose};
	( CORE::unlink($name) and ++$cnt
	  or warn "Couldn't unlink $name: $!\n" ) unless $opts{notify};
    }
    return $cnt;
}

sub link {
    my($from,$to) = @_;
    my($success) = 0;

    my $xfrom = $from;
    $xfrom =~ s/^\Q$opts{destdir}\E// if $opts{destdir};
    my $xto = $to;
    $xto =~ s/^\Q$opts{destdir}\E// if $opts{destdir};
    print $opts{verbose} ? "  ln $xfrom $xto\n" : "  $xto\n"
	unless $opts{silent};
    eval {
	CORE::link($from, $to)
	    ? $success++
	    : ($from =~ m#^/afs/# || $to =~ m#^/afs/#)
	      ? die "AFS"  # okay inside eval {}
	      : die "Couldn't link $from to $to: $!\n"
	  unless $opts{notify};
	$packlist->{$xto} = { from => $xfrom, type => 'link' };
    };
    if ($@) {
	warn "Replacing link() with File::Copy::copy(): $@";
	print $opts{verbose} ? "  cp $from $xto\n" : "  $xto\n"
	    unless $opts{silent};
	print "  creating new version of $xto\n"
		 if $Is_VMS and -e $to and !$opts{silent};
	unless ($opts{notify} or File::Copy::copy($from, $to) and ++$success) {
	    # Might have been that F::C::c can't overwrite the target
	    warn "Couldn't copy $from to $to: $!\n"
		unless -f $to and (chmod(0666, $to), unlink $to)
			and File::Copy::copy($from, $to) and ++$success;
	}
	$packlist->{$xto} = { type => 'file' };
    }
    $success;
}

sub chmod {
    my($mode,$name) = @_;

    return if ($^O eq 'dos' || $^O eq 'os2');
    printf "  chmod %o %s\n", $mode, $name if $opts{verbose};
    CORE::chmod($mode,$name)
	|| warn sprintf("Couldn't chmod %o %s: $!\n", $mode, $name)
      unless $opts{notify};
}


sub samepath {
    my($p1, $p2) = @_;

    return (lc($p1) eq lc($p2)) if ($Is_W32 || $Is_NetWare);

    if ($p1 ne $p2) {
	my($dev1, $ino1, $dev2, $ino2);
	($dev1, $ino1) = stat($p1);
	($dev2, $ino2) = stat($p2);
	($dev1 ~~ $dev2 && $ino1 ~~ $ino2);
    }
    else {
	1;
    }
}

1;
