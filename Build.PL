#!/usr/bin/perl
use strict;
use Module::Build;

my $build = Module::Build->new(
  module_name => 'CPAN::WWW::Testers::Generator',
  license     => 'perl',
  requires    => {
    'Test::More'    => 0,
    'Net::NNTP'     => 0,
    'DBD::SQLite'   => 0,
    'Email::Simple' => 0,
    'DateTime'      => 0,
    'Mail::Address' => 0,
    'version'       => 0,
  },
  script_files => ['bin/cpan_www_testers_generate'],
);
$build->create_build_script;
