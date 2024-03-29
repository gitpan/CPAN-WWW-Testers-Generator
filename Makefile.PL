#!/usr/bin/perl

use strict;
use warnings;
use 5.006;

use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR              => 'Barbie <barbie@cpan.org>',
    NAME                => 'CPAN::WWW::Testers::Generator',
    VERSION_FROM        => 'lib/CPAN/WWW/Testers/Generator.pm',
    ABSTRACT            => 'The pre-2009 CPAN Testers data manager codebase',
    NO_META             => 1,
    PREREQ_PM           => {

        # build/test prereqs
        'Test::More'        => '0.70',
        'IO::File'          => '0'

    }
);
