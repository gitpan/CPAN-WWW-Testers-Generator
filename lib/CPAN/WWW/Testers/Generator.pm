package CPAN::WWW::Testers::Generator;

use strict;
use vars qw($VERSION);

$VERSION = '0.24';

#----------------------------------------------------------------------------
# Library Modules

use CPAN::WWW::Testers::Generator::Article;
use DBI;
use File::Basename;
use File::Path;
use IO::File;
use Net::NNTP;

use base qw(Class::Accessor::Fast);

#----------------------------------------------------------------------------
# The Application Programming Interface

__PACKAGE__->mk_accessors(qw(articles database directory logfile));

sub new {
    my $class = shift;
    my %hash  = @_;

    $hash{directory} ||= '.';

    my $self = {};
    bless $self, $class;

    # continue when no article
    $self->{ignore} = $hash{ignore} if($hash{ignore});

    # prime the logging
    $self->logfile($hash{logfile})  if($hash{logfile});

    # prime the databases
    $self->directory($hash{directory});
    $self->database("$hash{directory}/cpanstats.db");
    $self->articles("$hash{directory}/articles.db");

    return $self;
}

sub DESTROY {
    my $self = shift;
    $self->_dbh_disconnect();
}

sub generate {
    my $self = shift;

    $self->{stats} = $self->_dbh_connect($self->database)   unless($self->{stats});
    $self->{arts}  = $self->_dbh_connect($self->articles)   unless($self->{arts});

    # connect to NNTP server
    my $nntp = Net::NNTP->new("nntp.perl.org")
        || die "Cannot connect to nntp.perl.org";
    my($num, $first, $last) = $nntp->group("perl.cpan.testers");

    # starting from last retrieved article
    for(my $id = $self->_get_lastid() +1; $id <= $last; $id++) {

        $self->_log("ID [$id]");
        my $article = join "", @{$nntp->article($id) || []};

        # no article for that id!
        unless($article) {
            $self->_log(" ... no article\n");
            if($self->{ignore}) {
                next;
            } else {
                die "No article returned [$id]\n";
            }
        }

        $self->insert_article($id,$article);
        my $object = CPAN::WWW::Testers::Generator::Article->new($article);

        unless($object) {
            $self->_log(" ... bad parse\n");
            next;
        }

        my $subject = $object->subject;
        my $from    = $object->from;
        $self->_log(" [$from] $subject\n");
        next    if($subject =~ /Re:/i);

        unless($subject =~ /(CPAN|FAIL|PASS|NA|UNKNOWN)\s+/i) {
            $self->_log(" . [$id] ... bad subject\n");
            next;
        }

        my $state = lc $1;
        my ($post,$date,$dist,$version,$platform,$perl,$osname,$osvers) = ();

        if($state eq 'cpan') {
            if($object->parse_upload()) {
                $dist      = $object->distribution;
                $version   = $object->version;
            }

            next    unless($self->_valid_field($id, 'dist'    => $dist));
            next    unless($self->_valid_field($id, 'version' => $version));

        } else {
            if($object->parse_report()) {
                $dist      = $object->distribution;
                $version   = $object->version;
                $from      = $object->from;
                $perl      = $object->perl;
                $platform  = $object->archname;
                $osname    = $object->osname;
                $osvers    = $object->osvers;

                $from      =~ s/'/''/g; #'
            }

            next    unless($self->_valid_field($id, 'dist'     => $dist));
            next    unless($self->_valid_field($id, 'version'  => $version));
            next    unless($self->_valid_field($id, 'from'     => $from));
            next    unless($self->_valid_field($id, 'perl'     => $perl));
            next    unless($self->_valid_field($id, 'platform' => $platform));
            next    unless($self->_valid_field($id, 'osname'   => $osname));
            next    unless($self->_valid_field($id, 'osvers'   => $osvers));
        }

        $post = $object->postdate;
        $date = $object->date;
        $self->insert_stats($id,$state,$post,$from,$dist,$version,$platform,$perl,$osname,$osvers,$date);
    }

    #$self->_dbh_disconnect();
}

sub insert_stats {
    my $self = shift;

    my $INSERT = 'INSERT INTO cpanstats VALUES (?,?,?,?,?,?,?,?,?,?,?)';

    my $sth = $self->{stats}->prepare($INSERT);
    unless($sth) {
        printf STDERR "ERROR: %s : %s\n", $self->{stats}->errstr, $INSERT;
        exit;   # bail out
    }

    my @fields = @_;
    $fields[$_] ||= 0   for(0);
    $fields[$_] ||= ''  for(1,2,3,4,5,6,8,9);
    $fields[$_] ||= '0' for(7);

    if(!$sth->execute(@fields)) {
        printf STDERR "ERROR: %s : %s : [%s]\n", $sth->errstr, $INSERT,join(',',@fields);
        exit;   # bail out
    }

    $sth->finish;

    if((++$self->{stat_count} % 50) == 0) {
        $self->{stats}->commit;
    }
}

sub insert_article {
    my $self = shift;

    my $INSERT = 'INSERT INTO articles VALUES (?,?)';

    my $sth = $self->{arts}->prepare($INSERT);
    unless($sth) {
        printf STDERR "ERROR: %s : %s\n", $self->{arts}->errstr, $INSERT;
        exit;   # bail out
    }

    my @fields = @_;
    $fields[$_] ||= 0   for(0);
    $fields[$_] ||= ''  for(1);

    if(!$sth->execute(@fields)) {
        printf STDERR "ERROR: %s : %s : [%s]\n", $sth->errstr, $INSERT,join(',',@fields);
        exit;   # bail out
    }

    $sth->finish;

    if((++$self->{arts_count} % 50) == 0) {
        $self->{arts}->commit;
    }
}

#----------------------------------------------------------------------------
# Private Functions

sub _valid_field {
    my ($self,$id,$name,$value) = @_;
    return 1    if(defined $value);
    $self->_log(" . [$id] ... missing field: $name\n");
    return 0;
}

sub _dbh_connect {
    my $self = shift;
    my $db   = shift;
    my $exists = -f $db;

    mkpath(dirname($db))    unless($exists);

    my $dsn = "DBI:SQLite:dbname=$db";
    my $dbh = DBI->connect($dsn, "", "", {
        RaiseError => 1,
        AutoCommit => 0,
        sqlite_handle_binary_nulls => 1,
    });

    if(!$exists) {
        eval { $self->_dbh_create($dbh,$db) };
        die "Failed to create database: $@"  if($@);
    }

    return $dbh;
}

sub _dbh_disconnect {
    my $self = shift;

    if($self->{stats}) {
        $self->{stats}->commit;
        $self->{stats}->disconnect;
        $self->{stats} = undef;
    }

    if($self->{arts}) {
        $self->{arts}->commit;
        $self->{arts}->disconnect;
        $self->{arts} = undef;
    }
}

sub _dbh_create {
    my ($self,$dbh,$db) = @_;
    my @sql;

    if($db =~ /cpanstats.db$/) {
        push @sql,
            'CREATE TABLE cpanstats (
                          id            INTEGER PRIMARY KEY,
                          state         TEXT,
                          postdate      TEXT,
                          tester        TEXT,
                          dist          TEXT,
                          version       TEXT,
                          platform      TEXT,
                          perl          TEXT,
                          osname        TEXT,
                          osvers        TEXT,
                          date          TEXT)',

            'CREATE INDEX distverstate ON cpanstats (dist, version, state)',
            'CREATE INDEX ixperl ON cpanstats (perl)',
            'CREATE INDEX ixplat ON cpanstats (platform)',
            'CREATE INDEX ixdate ON cpanstats (postdate)';
    } else {
        push @sql,
            'CREATE TABLE articles (
                          id            INTEGER PRIMARY KEY,
                          article       TEXT)';
    }

    $dbh->do($_)    for(@sql);
}

sub _get_lastid {
    my $self = shift;

    my $sth = $self->{arts}->prepare("SELECT max(id) FROM articles");
    return 0    unless($sth);
    unless($sth->execute) {
        $sth->finish;
        return 0;
    }

    my $row = $sth->fetchrow_arrayref();
    $sth->finish();

    return 0    unless($row);
    return $row->[0] || 0;
}

sub _log {
    my $self = shift;
    my $log = $self->logfile()  or return;
    mkpath(dirname($log))   unless(-f $log);
    my $fh = IO::File->new($log,'a+') or die "Cannot append to log file [$log]: $!\n";
    print $fh @_;
    $fh->close;
}


1;

__END__

=head1 NAME

CPAN::WWW::Testers::Generator - Download and summarize CPAN Testers data

=head1 SYNOPSIS

  % cpanstats
  # ... wait patiently, very patiently
  # ... then use cpanstats.db, an SQLite database

=head1 DESCRIPTION

This distribution was originally written by Leon Brocard to download and
summarize CPAN Testers data. However, all of the original code has been
rewritten to use the CPAN Testers Statistics database generation code. This
now means that all the CPAN Testers sites including the Reports site, the
Statistics site and the CPAN Dependencies site, can use the same database.

This module downloads articles from the cpan-testers newsgroup, generating or
updating an SQLite database containing all the most important information. You
can then query this database, or use CPAN::WWW::Testers to present it over the
web.

A good example query for Acme-Colour would be:

  SELECT version, status, count(*) FROM cpanstats WHERE
  distribution = "Acme-Colour" group by version, state;

To create a database from scratch can take several hours, as there are now over
1.5 million articles in the newgroup. As such updating from a known copy of the
database is much more advisable. If you don't want to generate the database
yourself, you can obtain the latest official copy (compressed with gzip) at
http://stats.cpantesters.org/cpanstats.db.gz

It should be noted that now with nearly 2 million articles in the archive,
running this software to generate the databases from scratch can take a long
time (days), unless you have a high-end processor machine. And even then it
will still take a long time!

=head1 DATABASE SCHEMA

The cpanstats database schema is very straightforward, one main table with
several index tables to speed up searches. The main table is as below:

  +--------------------------------+
  | cpanstats                      |
  +----------+---------------------+
  | id       | INTEGER PRIMARY KEY |
  | state    | TEXT                |
  | postdate | TEXT                |
  | tester   | TEXT                |
  | dist     | TEXT                |
  | version  | TEXT                |
  | platform | TEXT                |
  | perl     | TEXT                |
  | osname   | TEXT                |
  | osvers   | TEXT                |
  | archname | TEXT                |
  +----------+---------------------+

The articles database schema is again very straightforward, and consists of one
table, as below:

  +--------------------------------+
  | cpanstats                      |
  +----------+---------------------+
  | id       | INTEGER PRIMARY KEY |
  | article  | TEXT                |
  +----------+---------------------+

=head1 INTERFACE

=head2 The Constructor

=over

=item * new

Instatiates the object CPAN::WWW::Testers::Generator. Accepts a hash containing
values to prepare the object. These are described as:

  my $obj = CPAN::WWW::Testers::Generator->new(
                logfile   => './here/logfile',
                directory => './here'
  );

Where 'logfile' is the location to write log messages. Log messages are only
written if a logfile entry is specified, and will always append to any existing
file. The 'directory' value is where all databases will be created.

=back

=head2 Methods

=over

=item

=item * articles

Accessor to set/get the database full path.

=item * database

Accessor to set/get the database full path.

=item * directory

Accessor to set/get the directory where the database is to be created.

=item * generate

Starting from the last recorded article, retrieves all the more recent articles
from the NNTP server, parsing each and recording the articles that either
upload announcements or reports.

=item * insert_article

Inserts an article into the articles database.

=item * insert_stats

Inserts the components of a parsed article into the statistics database.

=item * logfile

Accessor to set/get where the logging information is to be kept. Note that if
this not set, no logging occurs.

=back

=head1 HISTORY

The CPAN testers was conceived back in May 1998 by Graham Barr and Chris
Nandor as a way to provide multi-platform testing for modules. Today there
are over 1.5 million tester reports and more than 100 testers each month
giving valuable feedback for users and authors alike.

=head1 BECOME A TESTER

Whether you have a common platform or a very unusual one, you can help by
testing modules you install and submitting reports. There are plenty of
module authors who could use test reports and helpful feedback on their
modules and distributions.

If you'd like to get involved, please take a look at the CPAN Testers Wiki,
where you can learn how to install and configure one of the recommended
smoke tools.

For further help and advice, please subscribe to the the CPAN Testers
discussion mailing list.

  CPAN Testers Wiki - http://wiki.cpantesters.org
  CPAN Testers Discuss mailing list
    - http://lists.cpan.org/showlist.cgi?name=cpan-testers-discuss

=head1 AUTHOR

  Original author:    Leon Brocard <acme@astray.com>   200?-2008
  Current maintainer: Barbie       <barbie@cpan.org>   2008-present

=head1 LICENSE

This code is distributed under the same license as Perl.
