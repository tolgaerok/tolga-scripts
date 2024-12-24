# Makepkg Tweaks 
Find out how many cores your cpu has by:
    nproc

keep the number it tells you in mind we will need that for later now we can edit the makepkg file by running

    sudo nano /etc/makepkg.conf

or make it a user only setting by running

    sudo cp /etc/makepkg.conf ~/.makepkg.conf
    sudo nano ~/.makepkg.conf

Once inside the makepkg.conf file scroll down till you come across “Compiler and Linker Flags” in this section we are looking for the CF Flags option make sure its uncommented (remove # infront if there is one) and and change -march and -mtune to native so it looks like this

    -march=native -mtune=native

Adding this will just add architecture-specific optimizations to compiling.Now we can go down a bit more to RUSTFLAGS and after opt-level=2 add “-C target-cpu=native” after it within the same quotations and uncomment the line (remove the # in front of RUSTFLAGS) so it looks like this

    RUSTFLAGS="-C opt-level=2 -C target-cpu=native"

Again same thing as the last line for RUST compiles. Now lets go down a bit more and until you will see MAKEFLAGS uncomment this line and change it to -j and then the number of threads on you have on your system plus 1 so on my 5950X it looks like this

    MAKEFLAGS="-j33"

This will allow your system to use all the threads on the CPU to build packages. Next scroll all the way down to the next section “BUILD ENVIRONMENT” and and the last line before the next section uncomment BUILDDIR and make sure it goes to /tmp/makepkg like so

    BUILDDIR=/tmp/makepkg

now scroll all the way down to “COMPRESSION DEFAULTS” and we need to change a few things starting with the first line COMPRESSGZ replace gzip with the word pigz like this

    COMPRESSGZ=(pigz -c -f -n)

pigz works the same as gzip but sohuld use all the cores on your system when compressing to .gz

Now lets move down to the next line COMPRESSBZ2 this is another simple change all we need to do is add a p in front of bzip2 so it reads pbzip2 like this

    COMPRESSBZ2=(pbzip2 -c -f)

just like the last change for .gz this will also enable all cores for .bz2 Now we can go the next line COMPRESSXZ and after -z but before the final – you want to add --threads=0 like so

    COMPRESSXZ=(xz -c -z --threads=0 -)

Threads being set to 0 will use all threads on the system for .xz or you can manually input the number of threads you got earlier from nproc.

For the last Compression method COMPRESSZST we are going to also add --threads=0 after -q and before the final – like so

    COMPRESSZST=(zstd -c -z -q --threads=0 -)

Now this next option is option but we can scroll down to the next section called EXTENSION DEFAULTS and remove .gz from the end of PKGEXT this will speed up install and packaging your items but will cause you to have slightly larger file sizes. It should look like this

    PKGEXT='.pkg.tar'

### My copy of Makepkg Tweaks 
    system: HP G4 800 SFF i7 8th gen

```bash
#!/hint/bash
#
# /etc/makepkg.conf
#

#########################################################################
# SOURCE ACQUISITION
#########################################################################
#
#-- The download utilities that makepkg should use to acquire sources
#  Format: 'protocol::agent'
DLAGENTS=('file::/usr/bin/curl -gqC - -o %o %u'
          'ftp::/usr/bin/curl -gqfC - --ftp-pasv --retry 3 --retry-delay 3 -o %o %u'
          'http::/usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o %o %u'
          'https::/usr/bin/curl -gqb "" -fLC - --retry 3 --retry-delay 3 -o %o %u'
          'rsync::/usr/bin/rsync --no-motd -z %u %o'
          'scp::/usr/bin/scp -C %u %o')

# Other common tools:
# /usr/bin/snarf
# /usr/bin/lftpget -c
# /usr/bin/wget

#-- The package required by makepkg to download VCS sources
#  Format: 'protocol::package'
VCSCLIENTS=('bzr::bzr'
            'git::git'
            'hg::mercurial'
            'svn::subversion')

#########################################################################
# ARCHITECTURE, COMPILE FLAGS
#########################################################################
#
CARCH="x86_64"
CHOST="x86_64-pc-linux-gnu"

#-- Compiler and Linker Flags
#CPPFLAGS=""
#CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt -fexceptions \
#        -Wp,-D_FORTIFY_SOURCE=2,-D_GLIBCXX_ASSERTIONS \
#        -Wformat -Werror=format-security \
#        -fstack-clash-protection -fcf-protection"
CFLAGS="-march=native -mtune=native -O2 -pipe -fno-plt -fexceptions \
        -Wp,-D_FORTIFY_SOURCE=2,-D_GLIBCXX_ASSERTIONS \
        -Wformat -Werror=format-security \
        -fstack-clash-protection -fcf-protection"
CXXFLAGS="$CFLAGS"
LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"
#RUSTFLAGS="-C opt-level=2"
RUSTFLAGS="-C opt-level=2 -C target-cpu=native"
#-- Make Flags: change this for DistCC/SMP systems
#MAKEFLAGS="-j$(($(nproc)+1))"
MAKEFLAGS="-j33"
#-- Debugging flags
DEBUG_CFLAGS="-g -fvar-tracking-assignments"
DEBUG_CXXFLAGS="-g -fvar-tracking-assignments"
#DEBUG_RUSTFLAGS="-C debuginfo=2"

#########################################################################
# BUILD ENVIRONMENT
#########################################################################
#
# Defaults: BUILDENV=(!distcc !color !ccache check !sign)
#  A negated environment option will do the opposite of the comments below.
#
#-- distcc:   Use the Distributed C/C++/ObjC compiler
#-- color:    Colorize output messages
#-- ccache:   Use ccache to cache compilation
#-- check:    Run the check() function if present in the PKGBUILD
#-- sign:     Generate PGP signature file
#
BUILDENV=(!distcc color !ccache check !sign)
#
#-- If using DistCC, your MAKEFLAGS will also need modification. In addition,
#-- specify a space-delimited list of hosts running in the DistCC cluster.
#DISTCC_HOSTS=""
#
#-- Specify a directory for package building.
#BUILDDIR=/tmp/makepkg

#########################################################################
# GLOBAL PACKAGE OPTIONS
#   These are default values for the options=() settings
#########################################################################
#
# Default: OPTIONS=(!strip docs libtool staticlibs emptydirs !zipman !purge !debug)
#  A negated option will do the opposite of the comments below.
#
#-- strip:      Strip symbols from binaries/libraries
#-- docs:       Save doc directories specified by DOC_DIRS
#-- libtool:    Leave libtool (.la) files in packages
#-- staticlibs: Leave static library (.a) files in packages
#-- emptydirs:  Leave empty directories in packages
#-- zipman:     Compress manual (man and info) pages in MAN_DIRS with gzip
#-- purge:      Remove files specified by PURGE_TARGETS
#-- debug:      Add debugging flags as specified in DEBUG_* variables
#
OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug)

#-- File integrity checks to use. Valid: md5, sha1, sha224, sha256, sha384, sha512, b2
INTEGRITY_CHECK=(md5)
#-- Options to be used when stripping binaries. See `man strip' for details.
STRIP_BINARIES="--strip-all"
#-- Options to be used when stripping shared libraries. See `man strip' for details.
STRIP_SHARED="--strip-unneeded"
#-- Options to be used when stripping static libraries. See `man strip' for details.
STRIP_STATIC="--strip-debug"
#-- Manual (man and info) directories to compress (if zipman is specified)
MAN_DIRS=({usr{,/local}{,/share},opt/*}/{man,info})
#-- Doc directories to remove (if !docs is specified)
DOC_DIRS=(usr/{,local/}{,share/}{doc,gtk-doc} opt/*/{doc,gtk-doc})
#-- Files to be removed from all packages (if purge is specified)
PURGE_TARGETS=(usr/{,share}/info/dir .packlist *.pod)
#-- Directory to store source code in for debug packages
DBGSRCDIR="/usr/src/debug"

#########################################################################
# PACKAGE OUTPUT
#########################################################################
#
# Default: put built package and cached source in build directory
#
#-- Destination: specify a fixed directory where all packages will be placed
#PKGDEST=/home/packages
#-- Source cache: specify a fixed directory where source files will be cached
#SRCDEST=/home/sources
#-- Source packages: specify a fixed directory where all src packages will be placed
#SRCPKGDEST=/home/srcpackages
#-- Log files: specify a fixed directory where all log files will be placed
#LOGDEST=/home/makepkglogs
#-- Packager: name/email of the person or organization building packages
#PACKAGER="John Doe <john@doe.com>"
#-- Specify a key to use for package signing
#GPGKEY=""

#########################################################################
# COMPRESSION DEFAULTS
#########################################################################
#
#COMPRESSGZ=(gzip -c -f -n)
COMPRESSGZ=(pigz -c -f -n)
#COMPRESSBZ2=(bzip2 -c -f)
COMPRESSBZ2=(pbzip2 -c -f)
#COMPRESSXZ=(xz -c -z -)
COMPRESSXZ=(xz -c -z --threads=0 -)
#COMPRESSZST=(zstd -c -z -q -)
COMPRESSZST=(zstd -c -z -q --threads=0 -)
COMPRESSLRZ=(lrzip -q)
COMPRESSLZO=(lzop -q)
COMPRESSZ=(compress -c -f)
COMPRESSLZ4=(lz4 -q)
COMPRESSLZ=(lzip -c -f)

#########################################################################
# EXTENSION DEFAULTS
#########################################################################
#
PKGEXT='.pkg.tar'
SRCEXT='.src.tar'
```