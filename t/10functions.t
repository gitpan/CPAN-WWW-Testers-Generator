#!/usr/bin/perl -w
use strict;
use Test::More tests => 8;
use CPAN::WWW::Testers::Generator;

my @perls = (
  {
    text => 'Summary of my perl5 (revision 5.0 version 6 subversion 1) configuration',
    perl => '5.6.1'
  },
  {
    text => 'Summary of my perl5 (revision a version b subversion c) configuration',
    perl => '0'
  },
  {
    text => 'Summary of my perl5 (revision 5.0 version 8 subversion 0 patch 17332) configuration',
    perl => '5.8.0 patch 17332',
  },
  {
    text => 'Summary of my perl5 (revision 5.0 version 8 subversion 1 RC3) configuration',
    perl => '5.8.1 RC3',
  },
#  {
#    text => '',
#    perl => '',
#  },
);

my $t = CPAN::WWW::Testers::Generator->new();
isa_ok($t,'CPAN::WWW::Testers::Generator');

is($t->directory,undef);
is($t->directory('here'),'here');
is($t->directory,'here');

foreach (@perls) {
  my $text = $_->{text};
  my $perl = $_->{perl};

  my $version = CPAN::WWW::Testers::Generator::Article->_extract_perl_version(\$text);
  is($version, $perl);
}

# generate, download & insert are not tested
