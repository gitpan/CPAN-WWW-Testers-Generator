package CPAN::WWW::Testers::Generator;
use strict;
use CPAN::DistnameInfo;
use CPAN::WWW::Testers::Generator::Article;
use DBI;
use Email::Simple;
use File::Spec::Functions;
use Mail::Address;
use Net::NNTP;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors(qw(directory));
use vars qw($VERSION);
use version;
$VERSION = "0.22";

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
}

sub generate {
  my $self = shift;

  $self->download;
  $self->insert;
}

sub _dbh {
  my $self = shift;
  my $name = shift;

  my $directory = $self->directory;
  my $dsn = "DBI:SQLite:dbname=$directory/$name.db";
  my $dbh = DBI->connect($dsn, "", "", {
    RaiseError => 1,
    AutoCommit => 0,
    sqlite_handle_binary_nulls => 1,
  });

  return $dbh;
}

sub download {
  my $self = shift;
  my $dbh  = $self->_dbh("news");

  eval { $dbh->do("
CREATE TABLE articles (
 id INTEGER PRIMARY KEY,  
 article TEXT
)"); };
  die $@ if $@ && $@ !~ /table articles already exists/;
  
  my $sth = $dbh->prepare("SELECT max(id) from articles");
  $sth->execute;
  my($max_id) = $sth->fetchrow_array || 0;

  $sth = $dbh->prepare("INSERT INTO articles VALUES (?, ?)");

  my $exists_sth = $dbh->prepare("SELECT id FROM articles WHERE id = ?");

  my $nntp = Net::NNTP->new("nntp.perl.org") 
	  || die "Cannot connect to nntp.perl.org";
  my($num, $first, $last) = $nntp->group("perl.cpan.testers");

  my $count;
  foreach my $id ($max_id+1 .. $last) {
    print "[$id .. $last]\n";
    my $article = join "", @{$nntp->article($id) || []};
    $sth->execute($id, $article);
    if ((++$count % 50) == 0) {
      print "[syncing]\n";
      $dbh->commit;
    }
  }

  $dbh->commit;
  $dbh->disconnect;
}


sub insert {
  my $self = shift;
  my $dbh  = $self->_dbh("testers");

  my @fields = qw(status distribution version perl osname osvers archname);

  eval {
    $dbh->do("
CREATE TABLE reports (
  id INTEGER PRIMARY KEY,
  status TEXT,
  distribution TEXT,
  version TEXT,
  perl TEXT,
  osname TEXT,
  osvers TEXT,
  archname TEXT
)");

    foreach my $field (@fields) {
      $dbh->do("CREATE INDEX ${field}_idx on reports (${field})");
    }
 };
  die $@ if $@ && $@ !~ /table reports already exists/;

  my $sth = $dbh->prepare("SELECT max(id) from reports");
  $sth->execute;
  my($max_id) = $sth->fetchrow_array || 0;

  my $news_dbh = $self->_dbh("news");
  my $article_sth = $news_dbh->prepare("SELECT id, article from articles WHERE id > ?");
  $article_sth->execute($max_id);

  $sth = $dbh->prepare("REPLACE INTO reports VALUES (?, ?, ?, ?, ?, ?, ?, ?)");

  my $count = $max_id;
  while (my($id, $content) = $article_sth->fetchrow_array) {
    if ((++$count % 1000) == 0) {
      print "$count...";
      $dbh->commit;
      print "\n";
    }

    my $article = CPAN::WWW::Testers::Generator::Article->new(\$content);
    next unless $article;

    my @values;
    foreach my $field (@fields) {
      push @values, $article->$field;
    }

    $sth->execute($id, @values);
  }
  $dbh->commit;
  $dbh->disconnect;
  $news_dbh->disconnect;
}


1;

__END__

=head1 NAME

CPAN::WWW::Testers::Generator - Download and summarize CPAN Testers data

=head1 SYNOPSIS

  % cpan_www_testers_generate
  # ... wait patiently for about an hour
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

  SELECT version, status, count(*) FROM reports WHERE
  distribution = "Acme-Colour" group by version, status;

It can over an hour to generate the database file. If you don't want to
generate the database yourself, I am releasing daily copies of it at 
http://testers.astray.com/testers.db

=head1 INTERFACE

=head2 The Constructor

=over

=item * new

Instatiates the object CPAN::WWW::Testers::Generator.

=back

=head2 Methods

=over

=item 

=item * directory

Accessor to set/get the directory where the news.db is to be created.

=item * generate

Initiates the $obj->download and $obj->insert method calls.

=item * download

Downloads the latest article updates from the NNTP server for the
cpan-testers newgroup. Articles are then stored in the news.db
SQLite database.

=item * insert

Reads the local copy of the news.db, and creates the testers.db.

=back

=head1 HISTORY

The CPAN testers was conceived back in May 1998 by Graham Barr and 
Chris Nandor as a way to provide multi-platform testing for modules.
Today there are over 100,000 tester reports and more than 400 testers 
giving valuable feedback for users and authors alike.

=head1 BECOME A TESTER

Whether you have a common platform or a very unusual one, you can help
by testing modules you install and submitting reports. There are plenty
of module authors who could use test reports and helpful feedback on their 
modules and distributions. If you'd like to get involved, please take a 
look at

Test::Reporter 
http://search.cpan.org/dist/Test-Reporter/, 

CPANPLUS
http://search.cpan.org/dist/CPANPLUS/lib/CPANPLUS/TesterGuide.pod,
 
the cpan-testers mailing list 
http://lists.cpan.org/showlist.cgi?name=cpan-testers 

and start submitting your reports.

=head1 AUTHOR

Leon Brocard <leon@astray.com>

=head1 LICENSE

This code is distributed under the same license as Perl.

