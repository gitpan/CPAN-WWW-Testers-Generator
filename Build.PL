#!/usr/bin/perl
use strict;
use Module::Build;

my $build = Module::Build->new(
  module_name => 'CPAN::WWW::Testers::Generator',
  create_makefile_pl => 'traditional',
  license     => 'perl',
  requires    => {
    'CPAN::DistnameInfo' => 0,
    'DBD::SQLite'   => '1.07',
    'Email::Simple' => 0,
    'Net::NNTP'     => 0,
    'Mail::Address' => 0,
    'Test::More'    => 0,
    'version'       => 0,
    'Class::Accessor::Fast' => 0,
    'CPAN::DistnameInfo' => 0,
    'FindBin'       => 0,
    'Getopt::Long'  => 0,
  },
  script_files => ['bin/cpan_www_testers_generate'],
);
$build->create_build_script;
