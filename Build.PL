#!/usr/bin/perl
use strict;
use Module::Build;

my $build = Module::Build->new(
  module_name => 'CPAN::WWW::Testers::Generator',
  license     => 'perl',
  requires    => {
    'Test::More'  => '0.01',
    'DB_File'     => '0.01',
    'Net::NNTP'   => '0.01',
    'DBD::SQLite' => '0.01',
    'Email::Simple' => '0.01',
    'DateTime'    => '0.01',
    'Mail::Address' => '0.01',
  },
  script_files => ['bin/cpan_www_testers_generate'],
);
$build->create_build_script;
