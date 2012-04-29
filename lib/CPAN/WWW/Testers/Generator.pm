package CPAN::WWW::Testers::Generator;

use warnings;
use strict;
use vars qw($VERSION);

$VERSION = '0.31';

q(Become a CPAN Tester - http://wiki.cpantesters.org/wiki/GettingStarted);

__END__

=head1 NAME

CPAN::WWW::Testers::Generator - The pre-2009 CPAN Testers data manager codebase

=head1 DESCRIPTION

This distribution used to generate the CPAN Testers database before 2009.

=head1 CPAN TESTERS

The CPAN Testers project was conceived back in May 1998 by Graham Barr and 
Chris Nandor as a way to provide multi-platform testing for modules uploaded
to CPAN. Today there are over 20 million test reports and more than 100 
testers regularly submitting reports each month, giving valuable feedback 
for users and authors alike.
  
The objective of the group is to test as many of the distributions 
available on CPAN as possible, on as many platforms as possible, with a 
variety of perl interpreters. The ultimate goal is to improve the 
portability of the distributions on CPAN, and provide good feedback to the 
authors.

This distribution was originally written by Leon Brocard to download and
summarize CPAN Testers data. However, since 2008, the codebase has been
redesigned by Barbie, firstly to use the cpanstats database, and secondly
to retrieve data from the Metabase API.

Following the complete redesign of the tools in 2009, this distribution 
and the tools used were no longer required.

For the current set of releases for the CPAN Testers family of websites,
please see:

  * CPAN-Testers-WWW-Reports
  * CPAN-Testers-WWW-Statistics
  * CPAN-Testers-WWW-Wiki
  * CPAN-Testers-WWW-Blog

ADVANCED WARNING - ADVANCED WARNING - ADVANCED WARNING - ADVANCED WARNING

This distribution will soon be deleted from CPAN. It is no longer
applicable for the building of the CPAN Testers websites, and no longer
maintained.

=head1 SEE ALSO

=over

=item * L<CPAN-Testers-WWW-Reports>     - F<http://www.cpantesters.org>

=item * L<CPAN-Testers-WWW-Statistics>  - F<http://stats.cpantesters.org>

=item * L<CPAN-Testers-WWW-Wiki>        - F<http://wiki.cpantesters.org>

=item * L<CPAN-Testers-WWW-Blog>        - F<http://blog.cpantesters.org>

=back

=head1 BECOME A TESTER

The objective of the CPAN Testers is to test as many of the distributions 
on CPAN as possible, on as many platforms as possible. The ultimate goal is
to improve the portability of the distributions on CPAN, and provide good 
feedback to the authors.

Whether you have a common platform or a very unusual one, you can help by 
testing modules you install and submitting reports. There are plenty of 
module authors who could use test reports and helpful feedback on their 
modules and distributions. 

If you'd like to get involved, please take a look at the CPAN Testers Wiki,
where you can learn how to install and configure one of the recommended 
smoke tools.

For further help and advice, please subscribe to the the CPAN Testers 
discussion mailing list.

CPAN Testers Wiki - F<http://wiki.cpantesters.org>
CPAN Testers Discuss mailing list
- F<http://lists.cpan.org/showlist.cgi?name=cpan-testers-discuss>

=head1 AUTHOR

  Original author:    Leon Brocard <acme@astray.com>   2002-2008
  Current maintainer: Barbie       <barbie@cpan.org>   2008-2012

=head1 LICENSE

This code is distributed under the same license as Perl.
