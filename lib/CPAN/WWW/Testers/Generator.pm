package CPAN::WWW::Testers::Generator;
use DB_File;
use DBI;
use Email::Simple;
use File::Spec::Functions;
use Mail::Address;
use Net::NNTP;
use strict;
use vars qw($VERSION);
use version;
$VERSION = "0.20";

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
}

sub directory {
  my($self, $dir) = @_;
  if (defined $dir) {
    $self->{DIR} = $dir;
  } else {
    return $self->{DIR};
  }
}

sub generate {
  my $self = shift;

  $self->download;
  $self->insert;
}

sub download {
  my $self = shift;

  my $t = tie my %testers,  'DB_File', catfile($self->directory, "testers.dbm");
  my $nntp = Net::NNTP->new("nntp.perl.org") || die;
  my($num, $first, $last) = $nntp->group("perl.cpan.testers");

  my $count;
  foreach my $id ($first .. $last) {
    next if exists $testers{$id};
    print "[$id .. $last]\n";
    my $article = join "", @{$nntp->article($id) || []};
    $testers{$id} = $article;
    if (($count++ % 100) == 0) {
      print "[syncing]\n";
      $t->sync;
    }
  }
}


sub insert {
  my $self = shift;
  tie my %testers,  'DB_File', catfile($self->directory, "testers.dbm") || die;

  my $db_exists = -f catfile($self->directory, 'testers.db');
  my $dbh = DBI->connect("dbi:SQLite:dbname=" . catfile($self->directory, "testers.db"),"","", { RaiseError => 1, AutoCommit => 1});
  $dbh->do("PRAGMA default_synchronous = OFF");

  unless ($db_exists) {
    $dbh->do("
CREATE TABLE reports (
 id INTEGER, action, distversion, dist, version, platform,
 unique(id)
)");
    $dbh->do("CREATE INDEX action_idx on reports (action)");
    $dbh->do("CREATE INDEX dist_idx on reports (dist)");
    $dbh->do("CREATE INDEX version_idx on reports (version)");
    $dbh->do("CREATE INDEX distversion_idx on reports (version)");
    $dbh->do("CREATE INDEX platform_idx on reports (platform)");
  }

  # Right, let's use transactions for speed
  $dbh->{AutoCommit} = 0;

  my $sth = $dbh->prepare("REPLACE INTO reports VALUES (?, ?, ?, ?, ?, ?)");

  my $count = 0;
  while (my($id, $content) = each %testers) {
    if (($count++ % 1000) == 0) {
      print "$count...";
      $dbh->commit;
      print "\n";
    }

    my $mail = Email::Simple->new($content);
    my $subject = $mail->header("Subject");
    next unless $subject;
    next if $subject =~ /::/; # it's supposed to be distribution
    my($action, $distversion, $platform) = split /\s/, $subject;
    next unless defined $action;
    next unless $action =~ /^PASS|FAIL|UNKNOWN|NA$/;
    # Fix bug where reports are like A/AM/AMS/Crypt-TEA-1.22.tar.gz
    $distversion =~ s{^.+/}{};
    $distversion =~ s/\.tar\.gz$//;
    $distversion =~ s/\.zip$//;
    $distversion =~ s/\.tgz$//;
    my ($dist, $version) = $self->extract_name_version($distversion);
    next unless $version;
    $sth->execute($id, $action, $distversion, $dist, $version, $platform);
  }
  $dbh->commit;
  $dbh->disconnect;
}

# from TUCS, coded by gbarr
sub extract_name_version {
  my($self, $file) = @_;

  my ($dist, $version) = $file =~ /^
    ((?:[-+.]*(?:[A-Za-z0-9]+|(?<=\D)_|_(?=\D))*
      (?:
   [A-Za-z](?=[^A-Za-z]|$)
   |
   \d(?=-)
     )(?<![._-][vV])
    )+)(.*)
  $/xs or return ($file);

  $version = $1
    if !length $version and $dist =~ s/-(\d+\w)$//;

  $version = $1 . $version
    if $version =~ /^\d+$/ and $dist =~ s/-(\w+)$//;

     if ($version =~ /\d\.\d/) {
    $version =~ s/^[-_.]+//;
  }
  else {
    $version =~ s/^[-_]+//;
  }
  return ($dist, $version);
}

1;

__END__

=head1 NAME

CPAN::WWW::Testers::Generator - Download and summarize CPAN Testers data

=head1 SYNOPSIS

  % cpan_www_testers_generate
  # ... wait patiently for about 30 mins
  # ... then use testers.db, an SQLite database

=head1 DESCRIPTION

The distribution can download and summarize CPAN Testers data.
cpan-testers is a group which was initially setup by Graham Barr and
Chris Nandor. The objective of the group is to test as many of the
distributions on CPAN as possible, on as many platforms as possible.
The ultimate goal is to improve the portability of the distributions
on CPAN, and provide good feedback to the authors.

CPAN Testers is really a mailing list with a web interface,
testers.cpan.org. testers.cpan.org was painfully slow. I happened to
be doing metadata stuff for Module::CPANTS. This is the result.

This module downloads the cpan-testers newsgroup, and then generates
an SQLite database containing all the most important information. You
can then query this database, or use CPAN::WWW::Testers to present it
over the web.

A good example query for Acme-Colour would be:

  SELECT version, action, count(*) FROM reports WHERE 
  dist = 'Acme-Colour' GROUP BY version, action;

It takes about 30 minutes to generate the database file. If you don't
want to generate the database yourself, I am releasing daily copies of
it at http://testers.astray.com/testers.db

=head1 HISTORY

The CPAN testers was conceived back in May 1998 by Graham Barr and 
Chris Nandor as a way to provide multi-platform testing for modules.
Today there are over 68,000 tester reports and more than 400 testers 
giving valuable feedback for users and authors alike.

=head1 BECOME A TESTER

Whether you have a common platform or a very unusual one, you can help
by testing modules you install and submitting reports. There are plenty
of module authors who could use test reports and helpful feedback on their 
modules and distributions. If you'd like to get involved, please take a 
look at

Test::Reporter 
http://search.cpan.org/author/FOX/Test-Reporter-1.20/, 

CPANPLUS
http://search.cpan.org/author/KANE/CPANPLUS-0.042/lib/CPANPLUS/TesterGuide.pod,
 
the cpan-testers mailing list 
http://lists.cpan.org/showlist.cgi?name=cpan-testers 

and start submitting your reports.

=head1 AUTHOR

Leon Brocard <leon@astray.com>

=head1 LICENSE

This code is distributed under the same license as Perl.

