package CPAN::WWW::Testers::Generator::Article;
use strict;
use CPAN::DistnameInfo;
#use DateTime::Format::Mail;
use Email::Simple;
use base qw( Class::Accessor::Fast );
__PACKAGE__->mk_accessors(qw( 
date status distribution version
perl osname osvers archname
));

sub new {
  my($class, $article) = @_;
  my $self = {};
  bless $self, $class;

  my $mail = Email::Simple->new($$article);
  return if $mail->header("In-Reply-To");
  my $subject = $mail->header("Subject");
  return unless $subject;
  return if $subject =~ /::/; # it's supposed to be distribution
  my($status, $distversion, $platform) = split /\s/, $subject;
  return unless $status =~ /^(PASS|FAIL|UNKNOWN|NA)$/;

  $distversion .= '.tar.gz' unless $distversion =~ /\.(tar|tgz|zip)/;
  my $d = CPAN::DistnameInfo->new($distversion);
  my ($dist, $version) = ($d->dist, $d->version);
  return unless $dist;
  return unless $version;

#  my $dfm = DateTime::Format::Mail->new(loose => 1);
#  my $datetime = $dfm->parse_datetime($mail->header("Date"));

  my $body = $mail->body;

  my $perl = $self->_extract_perl_version(\$body);

  my($osname) = $body =~ /osname=(?:3D)?([^ ,]+)/;
  my($osvers) = $body =~ /osvers=([^ ,]+)/;
  my($archname) = $body =~ /archname=([^ ,]+)/m;
  $archname =~ s/\n//;

#  $self->date($datetime);
  $self->status($status);
  $self->distribution($dist);
  $self->version($version);
  $self->perl($perl);
  $self->osname($osname || "");
  $self->osvers($osvers || "");
  $self->archname($archname || "");

  return $self;
}

sub passed {
  my $self = shift;
  return $self->status eq 'PASS';
}

sub failed {
  my $self = shift;
  return $self->status eq 'FAIL';
}

# there are a few old test reports that omitted the perl version number.
# In these instances 0 is assumed. These reports are now so old, that
# worrying about them is not worth the effort.

sub _extract_perl_version {
  my($self, $body) = @_;

  # Summary of my perl5 (revision 5.0 version 6 subversion 1) configuration:
  my ($rev, $ver, $sub, $extra) = 
	  $$body =~ /Summary of my (?:perl\d+)? \((?:revision )?(\d+(?:\.\d+)?) (?:version|patchlevel) (\d+) subversion\s+(\d+) ?(.*?)\) configuration/s;
  
  unless(defined $rev) {
#    warn "Cannot parse perl version for article:\n$body";
    return 0;
  }

  my $perl = $rev + ($ver / 1000) + ($sub / 1000000);
  $rev = int($perl);
  $ver = int(($perl*1000)%1000);
  $sub = int(($perl*1000000)%1000);

  my $version = sprintf "%d.%d.%d", $rev, $ver, $sub;
  $version .= " $extra" if $extra;
  return $version;
#  return sprintf "%0.6f", $perl;	# an alternate format
}

1;

__END__

=head1 NAME

CPAN::WWW::Testers::Generator::Article - Parse a CPAN Testers article

=head1 DESCRIPTION

This is used by CPAN::WWW::Testers::Generator.

=head1 METHOD

=head2 new

The constructor. Pass in a reference to the article.

=head2 passed

Whether it was a PASS

=head2 failed

Whether it was a FAIL

=head1 AUTHOR

Leon Brocard <leon@astray.com>

=head1 LICENSE

This code is distributed under the same license as Perl.

