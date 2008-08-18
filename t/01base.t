#!/usr/bin/perl -w
use strict;

use Test::More tests => 2;

BEGIN {
	use_ok( 'CPAN::WWW::Testers::Generator' );
	use_ok( 'CPAN::WWW::Testers::Generator::Article' );
}
