ren .git .git.sav
if not exist git_version.h perl make_patchnum.pl
if not exist lib\Config_git.pl perl make_patchnum.pl
ren cpan\Pod-Parser\scripts\*.PL *.*.sav
ren cpan\podlators\scripts\*.PL *.*.sav
if not exist perldelta.pod copy pod\perldelta.pod perldelta.pod
if not exist lib\re.pm copy ext\re\re.pm lib\re.pm
gmake %1 %2 %3 %4 %5 %6 %7 %8 %9
ren cpan\Pod-parser\scripts\*.sav *.*.
ren cpan\podlators\scripts\*.sav *.*.
ren .git.sav .git
