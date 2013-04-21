#! /bin/sh
# hints/os2.sh
# This file reflects the tireless work of
# Ilya Zakharevich <ilya@math.ohio-state.edu>
#
# Trimmed and comments added by 
#     Andy Dougherty  <doughera@lafayette.edu>
#     Exactly what is required beyond a standard OS/2 installation?
#     (see in README.os2)

# Note that symbol extraction code gives wrong answers (sometimes?) on
# gethostent and setsid.

path_sep=\;

if test -f $sh.exe; then sh=$sh.exe; fi

startsh="#!$sh"
cc='gcc'

# Make denser object files and DLL
case "X$optimize" in
  X)
	optimize="-O2 -fomit-frame-pointer -falign-loops=2 -falign-jumps=2 -falign-functions=2 -s"
	ld_dll_optimize="-s"
	;;
esac

# Get some standard things (indented to avoid putting in config.sh):
 oifs="$IFS"
 IFS=" ;"
 set $MANPATH
 tryman="$@"
 set $PATH
 trypath="$@"
 set `gcc -print-search-dirs | grep libraries | sed -e "s/^libraries: *=//" `
 libemx="$@"
 set $C_INCLUDE_PATH
 usrinc="$@"
 IFS="$oifs"
 tryman="`./UU/loc . /man $tryman`"
 tryman="`echo $tryman | tr '\\\' '/'`"
 
 # indented to avoid having it *two* times at start
 libemx="`./UU/loc libc_alias.a $libemx`"

usrinc="`./UU/loc stdlib.h  $usrinc`"
usrinc="`dirname $usrinc | tr '\\\' '/'`"
libemx="`dirname $libemx | tr '\\\' '/'`"

if test -d $tryman/man1; then
  sysman="$tryman/man1"
else
  sysman="`./UU/loc . /man/man1 $UNIXROOT/usr/share/man/man1 $UNIXROOT/usr/man/man1 c:/man/man1 c:/usr/man/man1 d:/man/man1 d:/usr/man/man1 e:/man/man1 e:/usr/man/man1 f:/man/man1 f:/usr/man/man1 g:/man/man1 g:/usr/man/man1 /usr/man/man1`"
fi

#emxpath="`dirname $libemx`"
#if test ! -d "$emxpath"; then
#  emxpath="`./UU/loc . /emx c:/emx d:/emx e:/emx f:/emx g:/emx h:/emx /emx`"
#fi
#emxpath="`which gcc.exe`"
emxpath="`./UU/loc gcc.exe /@unixroot/usr/bin $trypath`"
emxpath="`dirname $emxpath`"
emxpath="`dirname $emxpath`"
if test ! -d "$emxpath"; then 
  emxpath="$UNIXROOT/usr"
fi

if test ! -d "$libemx"; then 
  libemx="$emxpath/lib"
fi
if test ! -d "$libemx"; then 
  if test -d "$LIBRARY_PATH"; then
    libemx="$LIBRARY_PATH"
  else
    libemx="`./UU/loc . X $UNIXROOT/usr/lib $UNIXROOT/lib $UNIXROOT/usr/local/lib`"
  fi
fi

if test ! -d "$usrinc"; then 
  if test -d "$emxpath/include"; then 
    usrinc="$emxpath/include"
  else
    if test -d "$C_INCLUDE_PATH"; then
      usrinc="$C_INCLUDE_PATH"
    else
      usrinc="`./UU/loc . X $UNIXROOT/usr/include $UNIXROOT/usr/local/include`"
    fi
  fi
fi

#rsx="`./UU/loc rsx.exe undef $pth`"

if test "$libemx" = "X"; then echo "Cannot find C library!" >&2; fi

# Acute backslashitis:
libpth="`echo \"$LIBRARY_PATH\" | tr ';\\\' ' /'`"
libpth="$libpth $libemx"

so='dll'

# Additional definitions:

firstmakefile='GNUmakefile'
exe_ext='.exe'

# We provide it
i_dlfcn='define'

# The default one uses exponential notation between 0.0001 and 0.1
d_Gconvert='gcvt_os2((x),(n),(b))'

cat > UU/uselongdouble.cbu <<'EOCBU'
# This script UU/uselongdouble.cbu will get 'called-back' by Configure
# after it has prompted the user for whether to use long doubles.
# If we will use them, let Configure choose us a Gconvert.
case "$uselongdouble:$d_longdbl:$d_sqrtl:$d_modfl" in
"$define:$define:$define:$define") d_Gconvert='' ;;
esac
EOCBU

# -Zomf build has a problem with _exit() *flushing*, so the test
# gets confused:
fflushNULL="define"

# Not listed in dynamic_ext, but needed for static_ext nevertheless
extra_static_ext="OS2::DLL"

d_shrplib='define'
useshrplib='true'
obj_ext='.o'
lib_ext='.a'
ar='ar'
plibext='.a'
d_fork='define'
lddlflags="-Zdll -Zomf "
# Recursive regmatch may eat 2.5M of stack alone.
ldflags='-Zomf -Zhigh-mem -Zstack 32000 '
ccflags="-DDOSISH -DOS2=2 -DEMBED -I."
use_clib='libc_dll'
usedl='define'


# indented to miss config.sh
  _ar="$ar"

# To get into config.sh (should start at the beginning of line)
# or you can put it into config.over.
plibext="$plibext"
# plibext is not needed anymore.  Just directly set $libperl.
libperl="libperl${plibext}"


libc="$libemx/$use_clib$lib_ext"

if test -r "$libemx/libc_alias$lib_ext"; then
    libnames="$libemx/libc_alias$lib_ext"
fi
# otherwise puts -lc ???

# [Maybe we should just remove c from $libswanted ?]

# Test would pick up wrong rand, so we hardwire the value for random()
libs='-lsocket'
randbits=31
archobjs="os2$obj_ext dl_os2$obj_ext"

# Run files without extension with sh:
EXECSHELL=sh

cccdlflags='-Zdll'
dlsrc='dl_dlopen.xs'
ld='gcc'

#cppflags='-DDOSISH -DOS2=2 -DEMBED -I.'

# for speedup: (some patches to ungetc are also needed):
# Note that without this guy tests 8 and 10 of io/tell.t fail, with it 11 fails

stdstdunder=`echo "#include <stdio.h>" | cpp | egrep -c "char +\* +_ptr"`
d_stdstdio='define'
d_stdiobase='define'
d_stdio_ptr_lval='define'
d_stdio_cnt_lval='define'

if test "$stdstdunder" = 0; then
  stdio_ptr='((fp)->ptr)'
  stdio_cnt='((fp)->rcount)'
  stdio_base='((fp)->buffer)'
  stdio_bufsiz='((fp)->rcount + (fp)->ptr - (fp)->buffer)'
  ccflags="$ccflags -DMYTTYNAME"
  myttyname='define'
else
  stdio_ptr='((fp)->_ptr)'
  stdio_cnt='((fp)->_rcount)'
  stdio_base='((fp)->_buffer)'
  stdio_bufsiz='((fp)->_rcount + (fp)->_ptr - (fp)->_buffer)'
fi

# to put into config.sh
myttyname="$myttyname"

# To have manpages installed
nroff='nroff.cmd'
# above will be overwritten otherwise, indented to avoid config.sh
  _nroff='nroff.cmd'

# should be handled automatically by Configure now.
ln='cp'
# Will be rewritten otherwise, indented to not put in config.sh
  _ln='cp'
lns='cp'

nm_opt='-pa'

####### We define these functions ourselves

d_strtoll='define'
d_strtoull='define'
d_getprior='define'
d_setprior='define'
d_usleep='define'
d_usleepproto='define'

d_link='undef'
dont_use_nlink='define'
# no posix (aka hard) links for us!

# The next two are commented. pdksh handles #!, extproc gives no path part.
# sharpbang='extproc '
# shsharp='false'

# Commented:
#startsh='extproc ksh\\n#! sh'

# Find patch:
gnupatch='patch'
if (gnupatch -v || gnupatch --version)   2>&1 >/dev/null; then
    gnupatch=gnupatch
else
    if (gpatch -v || gpatch --version)   2>&1 >/dev/null; then
	gnupatch=gpatch
    else
	# They may have a special PATH during configuring
	if (patch -v || patch --version) 2>&1 >/dev/null; then
	    gnupatch="`./UU/loc patch.exe undef $pth`"
	fi
    fi
fi

for f in less.exe less.sh less.ksh less.cmd more.exe more.sh more.ksh more.cmd ; do
  if test -z "$pager"; then
    pager="`./UU/loc $f '' $pth`"
  fi
done
if test -z "$pager"; then
  pager='cmd /c more'
fi

# Apply patches if needed
case "$0$running_c_cmd" in
  *[/\\]Configure|*[/\\]Configure.|Configure|Configure.) # Skip Configure.cmd
    if test "Xyes" = "X$configure_cmd_loop"; then
	cat <<EOC >&2
!!!
!!! PANIC: Loop of self-invocations detected, aborting!
!!!
EOC
	exit 20
    fi
    configure_cmd_loop=yes
    export configure_cmd_loop

    configure_needs_patch=''
    if test -s ./os2/diff.configure; then
	if ! grep "^#OS2-PATCH-APPLIED" ./Configure > /dev/null; then
	    configure_needs_patch=yes	    
	fi
    fi
    if test -n "$configure_needs_patch"; then
	# Not patched!
	# Restore the initial command line arguments
	if test -f ./Configure.cmd ; then
	    cat <<EOC >&2
!!!
!!! I see that what is running is ./Configure.
!!! ./Configure is not patched, but ./Configure.cmd exists.
!!!
!!! You are supposed to run Configure.cmd, not Configure
!!!  after an automagic patching.
!!!
!!! If you insist on running Configure, you may
!!!  patch it manually from ./os2/diff.configure.
!!!
!!! However, I went through incredible hoolahoops, and I expect I can
!!!  auto-restart Configure.cmd myself.  I will start it with arguments:
!!!
!!!    Configure.cmd $args_exp
!!!
EOC
	    rp='Do you want to auto-restart Configure.cmd?'
	    dflt='y'
	    . UU/myread
	    case "$ans" in
		[yY]) echo >&4 "Okay, continuing." ;;
		*) echo >&4 "Okay, bye."
		   exit 2
		   ;;
	    esac
	    eval "set X $args_exp";
	    shift;
	    # Restore the output
	    exec Configure.cmd "$@" 1>&2
	    exit 2
	fi
	cat <<EOC >&2
!!!
!!! You did not patch ./Configure!
!!! I can create Configure.cmd and patch it from ./os2/diff.configure with the command
!!!
!!!   $gnupatch -b -p1 --output=Configure.cmd <./os2/diff.configure 2>&1 | tee 00_auto_patch
EOC
	rp='Do you want to auto-patch Configure to Configure.cmd?'
	dflt='y'
	. UU/myread
	case "$ans" in
		[yY]) echo >&4 "Okay, continuing." ;;
		*) echo >&4 "Okay, bye."
		   exit 2
		   ;;
	esac
	($gnupatch -b -p1 --output=Configure.cmd <./os2/diff.configure 2>&1 | tee 00_auto_patch) >&2
	cat <<EOC >&2
!!!
!!! The report of patching is copied to 00_auto_patch.
!!! Now we need to restart Configure.cmd with all the options.
!!!
EOC
	echo "extproc sh" > Configure.ctm
	( cat Configure.cmd >> Configure.ctm && mv -f Configure.ctm Configure.cmd ) || (echo "!!! Failure to add extproc-line to Configure.cmd." >&2 ; exit 21)
	cat <<EOC >&2
!!! I went through incredible hoolahoops, and I expect I can
!!!  auto-restart Configure.cmd myself.  I will start it with arguments:
!!!
!!!    Configure.cmd $args_exp
!!!
EOC
	rp='Do you want to auto-restart Configure.cmd?'
	dflt='y'
	. UU/myread
	case "$ans" in
		[yY]) echo >&4 "Okay, continuing." ;;
		*) echo >&4 "Okay, bye."
		   exit 2
		   ;;
	esac
	eval "set X $args_exp";
	shift;
	exec Configure.cmd "$@" 1>&2
	exit 2
    else
	if test -s ./os2/diff.configure; then
	    echo "!!! Apparently we are running a patched Configure." >&2
	else
	    echo "!!! Apparently there is no need to patch Configure." >&2
	fi
    fi 
    ;;
  *) echo "!!! Apparently we are running a renamed Configure: '$0'." >&2
esac

# This script UU/usethreads.cbu will get 'called-back' by Configure 
# after it has prompted the user for whether to use threads.
cat > UU/usethreads.cbu <<'EOCBU'
case "$usethreads" in
$define|true|[yY]*)
	ccflags="$ccflags -DUSE_THREADS"
        cppflags="$cppflags -DUSE_THREADS"  # Do we really need to set this?
	;;
esac
EOCBU

if test -z "$cryptlib"; then
	cryptlib=`UU/loc crypt$lib_ext "" $libpth`
	if $test -n "$cryptlib"; then
		cryptlib=-lcrypt
	else
		cryptlib=`UU/loc ufc$lib_ext "" $libpth`
		if $test -n "$cryptlib"; then
			cryptlib=-lufc
		fi
	fi
fi
if test -n "$cryptlib"; then
	libs="$libs $cryptlib"
	# d_crypt=define
fi

# Now install the external modules. We are in the ./hints directory.

cd ./os2/OS2

cp -rfu * ../../ext/

# Install tests:

cp -uf ../*.t ../../t/lib
for xxx in * ; do
	if $test -d $xxx/t; then
		cp -uf $xxx/t/*.t ../../t/lib
	else
		if $test -d $xxx; then
			cd $xxx
			for yyy in * ; do
				if $test -d $yyy/t; then
				    cp -uf $yyy/t/*.t ../../t/lib
				fi
			done
			cd ..
		fi
	fi
done

case "$ldlibpthname" in
'') ldlibpthname=none ;;
esac

# Now go back
cd ../..
cp os2/*.t t/lib
