#!/usr/bin/perl -w
use strict;

use Cwd;
use File::Path;
use IO::File;
use Test::More tests => 11;

use CPAN::WWW::Testers::Generator;

my ($mock,$nomock);

BEGIN {
    eval "use Test::MockObject";
    $nomock = $@;

    if(!$nomock) {
        $mock = Test::MockObject->new();
        $mock->fake_module( 'Net::NNTP',
                    'group' => \&group,
                    'article' => \&getArticle);
        $mock->fake_new( 'Net::NNTP' );
        $mock->mock( 'group', \&group );
        $mock->mock( 'article', \&getArticle );
    }
}

my %articles = (
    1 => 't/nntp/126015.txt',
    2 => 't/nntp/125106.txt',
    3 => 't/nntp/1804993.txt',
    4 => 't/nntp/1805500.txt',
);

SKIP: {
    skip "Test::MockObject required for testing", 6 if $nomock;

    my $directory = cwd();
    rmtree($directory . '/logs');


    my $t = CPAN::WWW::Testers::Generator->new(
        directory   => $directory . '/logs',
        logfile     => $directory . '/logs/cpanstats.log'
    );

    is($t->directory, $directory . '/logs');
    is($t->articles,  $directory . '/logs/articles.db');
    is($t->database,  $directory . '/logs/cpanstats.db');
    is($t->logfile,   $directory . '/logs/cpanstats.log');

    # nothing should be created yet
    ok(!-f $directory . '/logs/cpanstats.db');
    ok(!-f $directory . '/logs/cpanstats.log');
    ok(!-f $directory . '/logs/articles.db');

    # first update should build all databases
    $t->generate;

    # just check they were created, if it ever becomes an issue we can
    # interrogate the contents at a later date :)
    ok(-f $directory . '/logs/cpanstats.db');
    ok(-f $directory . '/logs/cpanstats.log');
    ok(-f $directory . '/logs/articles.db');

    my $size = -s $directory . '/logs/articles.db';

    # second update should do nothing
    $t->generate;

    is(-s $directory . '/logs/articles.db', $size,'.. db should not change size');

    # now clean up!
    #rmtree($directory . '/logs');
}


sub getArticle {
    my ($self,$id) = @_;
    my @text;

    my $fh = IO::File->new($articles{$id}) or return \@text;
    while(<$fh>) { push @text, $_ }
    $fh->close;

    return \@text;
}

sub group {
    return(4,1,4);
}
