#!/usr/bin/perl -w
use strict;
use lib 'lib';
use Test::More tests => 19;
use_ok('CPAN::WWW::Testers::Generator::Article');

my $pass = q|
Newsgroups: perl.cpan.testers
Path: nntp.perl.org
Return-Path: <Jost.Krieger+perl@rub.de>
Mailing-List: contact cpan-testers-help@perl.org; run by ezmlm
Delivered-To: mailing list cpan-testers@perl.org
Received: (qmail 67805 invoked by uid 76); 8 Mar 2004 09:25:53 -0000
Received: from qmailr@one.develooper.com (HELO ran-out.mx.develooper.com) (64.81.84.115)
  by onion.perl.org (qpsmtpd/0.27-dev) with SMTP; Mon, 08 Mar 2004 01:25:53 -0800
Received: (qmail 15837 invoked by uid 225); 8 Mar 2004 09:25:51 -0000
Delivered-To: cpan-testers@perl.org
Received: (qmail 15832 invoked by uid 507); 8 Mar 2004 09:25:51 -0000
X-Spam-Status: No, hits=-1.6 required=7.0
        tests=CARRIAGE_RETURNS,NO_REAL_NAME,PERLBUG_CONF,SPAM_PHRASE_00_01
X-Spam-Check-By: one.develooper.com
Received: from sunu991.rz.ruhr-uni-bochum.de (HELO mi.ruhr-uni-bochum.de) (134.147.128.177)
  by one.develooper.com (qpsmtpd/0.27.0) with ESMTP; Mon, 08 Mar 2004 01:25:20 -0800
Date: Mon,  8 Mar 2004 10:25:20 +0100
Subject: PASS AI-Perceptron-1.0 sun4-solaris-thread-multi 2.8
To: cpan-testers@perl.org
X-Reported-Via: Test::Reporter 1.20, via CPANPLUS 0.049
Approved: news@nntp.perl.org
From: Jost.Krieger+perl@rub.de (Jost Krieger+Perl)
Message-ID: <perl.cpan.testers-126015@nntp.perl.org>

This distribution has been tested as part of the cpan-testers
effort to test as many new uploads to CPAN as possible.  See
http://testers.cpan.org/

Please cc any replies to cpan-testers@perl.org to keep other
test volunteers informed and to prevent any duplicate effort.


--

Summary of my perl5 (revision 5.0 version 8 subversion 3) configuration:
  Platform:
    osname=solaris, osvers=2.8, archname=sun4-solaris-thread-multi
    uname='sunos sunu991 5.8 generic_108528-14 sun4u sparc sunw,ultra-5_10 solaris '
    config_args=''
    hint=recommended, useposix=true, d_sigaction=define
    usethreads=define use5005threads=undef useithreads=define usemultiplicity=define
    useperlio=define d_sfio=undef uselargefiles=define usesocks=undef
    use64bitint=undef use64bitall=undef uselongdouble=undef
    usemymalloc=n, bincompat5005=undef
  Compiler:
    cc='gcc', ccflags ='-D_REENTRANT -fno-strict-aliasing -I/usr/local/test/include -I/usr/local/include -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64',
    optimize='-O',
    cppflags='-D_REENTRANT -fno-strict-aliasing -I/usr/local/test/include -I/usr/local/include'
    ccversion='', gccversion='3.3.2', gccosandvers='solaris2.8'
    intsize=4, longsize=4, ptrsize=4, doublesize=8, byteorder=4321
    d_longlong=define, longlongsize=8, d_longdbl=define, longdblsize=16
    ivtype='long', ivsize=4, nvtype='double', nvsize=8, Off_t='off_t', lseeksize=8
    alignbytes=8, prototype=define
  Linker and Libraries:
    ld='gcc', ldflags ='-L/usr/local/test/lib -L/usr/local/lib '
    libpth=/usr/local/test/lib /usr/local/lib /usr/lib /usr/ccs/lib
    libs=-lsocket -lnsl -lgdbm -ldb -ldl -lm -lpthread -lc
    perllibs=-lsocket -lnsl -ldl -lm -lpthread -lc
    libc=/lib/libc.so, so=so, useshrplib=false, libperl=libperl.a
    gnulibc_version=''
  Dynamic Linking:
    dlsrc=dl_dlopen.xs, dlext=so, d_dlsymun=undef, ccdlflags=' '
    cccdlflags='-fPIC', lddlflags='-G -L/usr/local/test/lib -L/usr/local/lib'

|;

my $a = CPAN::WWW::Testers::Generator::Article->new(\$pass);
#is($a->from, 'Jost.Krieger+perl@rub.de (Jost Krieger+Perl)');
#is($a->date->datetime, "2004-03-08T10:25:20");
is($a->status, "PASS");
ok($a->passed);
ok(!$a->failed);
is($a->distribution, "AI-Perceptron");
is($a->version, "1.0");
is($a->perl, "5.8.3");
is($a->osname, "solaris");
is($a->osvers, "2.8");
is($a->archname, "sun4-solaris-thread-multi");

my $fail = q|Newsgroups: perl.cpan.testers
Path: nntp.perl.org
Xref: nntp.perl.org perl.cpan.testers:125106
Return-Path: <root@red13.alternation.net>
    Mailing-List: contact cpan-testers-help@perl.org; run by ezmlm
Delivered-To: mailing list cpan-testers@perl.org
Received: (qmail 27157 invoked by uid 76); 3 Mar 2004 10:08:20 -0000
Received: from x1.develooper.com (HELO x1.develooper.com) (63.251.223.170) by onion.perl.org (qpsmtpd/0.26) with SMTP; Wed, 03 Mar 2004 02:08:20 -0800
Received: (qmail 1721 invoked by uid 225); 3 Mar 2004 10:08:15 -0000
Delivered-To: cpan-testers@perl.org
Received: (qmail 1621 invoked by alias); 3 Mar 2004 10:07:53 -0000
Received: from [24.230.212.16] (HELO red13.alternation.net) (24.230.212.16)  by la.mx.develooper.com (qpsmtpd/0.27-dev) with ESMTP; Wed, 03 Mar 2004 02:07:53 -0800
Received: by red13.alternation.net (Postfix, from userid 0)     id BE6DC4026D; Wed,  3 Mar 2004 06:07:54 -0400 (AST)
Cc: DHUDES@cpan.org
Subject: FAIL Net-IP-Route-Reject-0.5_1 i586-linux 2.4.22-4tr
To: cpan-testers@perl.org
X-Reported-Via: Test::Reporter 1.20, via CPANPLUS 0.048
Message-ID: <20040303100754.BE6DC4026D@red13.alternation.net>
Date: Wed,  3 Mar 2004 06:07:54 -0400 (AST)
X-Spam-Checker-Version: SpamAssassin 2.63 (2004-01-11) on x1.develooper.com
X-Spam-Status: No, hits=-8.7 required=8.0 tests=BAYES_00,NO_REAL_NAME,  PERLBUG_CONF autolearn=ham version=2.63
X-SMTPD: qpsmtpd/0.26, http://develooper.com/code/qpsmtpd/
Approved: news@nntp.perl.org
From: cpansmoke@alternation.net

This distribution has been tested as part of the cpan-testers
effort to test as many new uploads to CPAN as possible.  See
http://testers.cpan.org/

Please cc any replies to cpan-testers@perl.org to keep other
test volunteers informed and to prevent any duplicate effort.

--
This is an error report generated automatically by CPANPLUS,
version 0.048.

Below is the error stack during 'make test':

t/001_load....#     Failed test (t/001_load.t at line 7)
#     Tried to use 'Net::IP::Route::Reject'.
#     Error:  Can't locate Module/Load.pm in @INC (@INC contains: /root/.cpanplus/5.8.0/build/Net-IP-Route-Reject-0.5/blib/lib /root/.cpanplus/5.8.0/build/Net-IP-Route-Reject-0.5/blib/arch /usr/lib/perl5/5.8.0/i586-linux /usr/lib/perl5/5.8.0/i586-linux /usr/lib/perl5/5.8.0 /usr/lib/perl5/site_perl/5.8.0/i586-linux /usr/lib/perl5/site_perl/5.8.0/i586-linux /usr/lib/perl5/site_perl/5.8.0 /usr/lib/perl5/site_perl/5.8.0/i586-linux /usr/lib/perl5/site_perl/5.8.0 /usr/lib/perl5/site_perl /usr/lib/perl5/vendor_perl/5.8.0/i586-linux /usr/lib/perl5/vendor_perl/5.8.0 /usr/lib/perl5/vendor_perl /root/.cpanplus/5.8.0/build/Net-IP-Route-Reject-0.5 /usr/lib/perl5/5.8.0/i586-linux /usr/lib/perl5/5.8.0 /usr/lib/perl5/site_perl/5.8.0/i586-linux /usr/lib/perl5/site_perl/5.8.0 /usr/lib/perl5/site_perl /usr/lib/perl5/vendor_perl/5.8.0/i586-linux /usr/lib/perl5/vendor_perl/5.8.0 /usr/lib/perl5/vendor_perl .) at /usr/lib/perl5/site_perl/5.8.0/Module/Load/Conditional.pm line 5.
# BEGIN failed--compilation aborted at /usr/lib/perl5/site_perl/5.8.0/Module/Load/Conditional.pm line 5.
# Compilation failed in require at /usr/lib/perl5/site_perl/5.8.0/IPC/Cmd.pm line 4.
# BEGIN failed--compilation aborted at /usr/lib/perl5/site_perl/5.8.0/IPC/Cmd.pm line 4.
# Compilation failed in require at /root/.cpanplus/5.8.0/build/Net-IP-Route-Reject-0.5/blib/lib/Net/IP/Route/Reject.pm line 4.
# BEGIN failed--compilation aborted at /root/.cpanplus/5.8.0/build/Net-IP-Route-Reject-0.5/blib/lib/Net/IP/Route/Reject.pm line 4.
# Compilation failed in require at (eval 1) line 2.
Can't locate object method "add" via package "Net::IP::Route::Reject" at t/001_load.t line 9.
# Looks like you planned 2 tests but only ran 1.
# Looks like your test died just after 1.
dubious
        Test returned status 255 (wstat 65280, 0xff00)
DIED. FAILED tests 1-2
        Failed 2/2 tests, 0.00% okay
Failed 1/1 test scripts, 0.00% okay. 2/2 subtests failed, 0.00% okay.
Failed Test  Stat Wstat Total Fail  Failed  List of Failed
-------------------------------------------------------------------------------
t/001_load.t  255 65280     2    3 150.00%  1-2


Additional comments:

Hello, Dana Hudes! Thanks for uploading your works to CPAN.

I noticed that the test suite seem to fail without these modules:

Module::Load

As such, adding the prerequisite module(s) to 'PREREQ_PM' in your
Makefile.PL should solve this problem.  For example:

WriteMakefile(
    AUTHOR      => 'Dana Hudes (dhudes@hudes.org)',
    ... # other information
    PREREQ_PM   => {
        'Module::Load'  => '0', # or a minimum workable version
    }
);

If you are interested in making a more flexible Makefile.PL that can
probe for missing dependencies and install them, ExtUtils::AutoInstall
at <http://search.cpan.org/dist/ExtUtils-AutoInstall/> may be
worth a look.

Thanks! :-)

******************************** NOTE ********************************
The comments above are created mechanically, possibly without manual
checking by the sender.  Also, because many people perform automatic
tests on CPAN, chances are that you will receive identical messages
about the same problem.

If you believe that the message is mistaken, please reply to the first
one with correction and/or additional information, and do not take
it personally.  We appreciate your patience. :)
**********************************************************************

--

Summary of my perl5 (revision 5.0 version 8 subversion 0) configuration:
  Platform:
    osname=linux, osvers=2.4.22-4tr, archname=i586-linux
    uname='linux borgen.trustix.net 2.4.22-4tr #1 wed oct 29 17:17:31 cet 2003 i686 unknown unknown gnulinux '
    config_args='-des -Doptimize=-O3 -fomit-frame-pointer -fno-exceptions -pipe -s -mpentium -mcpu=pentium -march=pentium -ffast-math -fexpensive-optimizations -Dcc=gcc -Dprefix=/usr -Dvendorprefix=/usr -Dsiteprefix=/usr -Dcf_by=Trustix -Dmyhostname=localhost -Dperladmin=root@localhost -Darchname=i586-linux -Dd_dosuid -Duselargefiles=n -Dd_semctl_semun -Ui_db -Di_gdbm -Dman3dir=/usr/share/man/man3 -Dman1dir=/usr/share/man/man1'
    hint=recommended, useposix=true, d_sigaction=define
    usethreads=undef use5005threads=undef useithreads=undef usemultiplicity=undef
    useperlio=define d_sfio=undef uselargefiles=undef usesocks=undef
    use64bitint=undef use64bitall=undef uselongdouble=undef
    usemymalloc=n, bincompat5005=undef
  Compiler:
    cc='gcc', ccflags ='-fno-strict-aliasing -I/usr/include/gdbm',
    optimize='-O3 -fomit-frame-pointer -fno-exceptions -pipe -s -mpentium -mcpu=pentium -march=pentium -ffast-math -fexpensive-optimizations',
    cppflags='-fno-strict-aliasing -I/usr/include/gdbm'
    ccversion='', gccversion='3.3', gccosandvers=''
    intsize=4, longsize=4, ptrsize=4, doublesize=8, byteorder=1234
    d_longlong=define, longlongsize=8, d_longdbl=define, longdblsize=12
    ivtype='long', ivsize=4, nvtype='double', nvsize=8, Off_t='off_t', lseeksize=4
    alignbytes=4, prototype=define
  Linker and Libraries:
    ld='gcc', ldflags =' -L/usr/local/lib'
    libpth=/usr/local/lib /lib /usr/lib
    libs=-lnsl -lgdbm -ldb -ldl -lm -lc -lcrypt -lutil
    perllibs=-lnsl -ldl -lm -lc -lcrypt -lutil
    libc=/lib/libc-2.3.2.so, so=so, useshrplib=false, libperl=libperl.a
    gnulibc_version='2.3.2'
  Dynamic Linking:
    dlsrc=dl_dlopen.xs, dlext=so, d_dlsymun=undef, ccdlflags='-rdynamic'
    cccdlflags='-fpic', lddlflags='-shared -L/usr/local/lib'

|;

$a = CPAN::WWW::Testers::Generator::Article->new(\$fail);
#is($a->from, 'cpansmoke@alternation.net');
#is($a->date->datetime, "2004-03-03T06:07:54");
is($a->status, "FAIL");
ok(!$a->passed);
ok($a->failed);
is($a->distribution, "Net-IP-Route-Reject");
is($a->version, "0.5_1");
is($a->perl, "5.8.0");
is($a->osname, "linux");
is($a->osvers, "2.4.22-4tr");
is($a->archname, "i586-linux");
