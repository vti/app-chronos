package App::Chronos::Application::Firefox;

use strict;
use warnings;

use base 'App::Chronos::Application::Base';

use URI;
use JSON ();

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub run {
    my $self = shift;
    my ($info) = @_;

    return
      unless $info->{role} =~ 'browser'
      && $info->{class} =~ 'Navigator'
      && $info->{name} =~ m/(?:Iceweasel|Firefox)/;

    $info->{activity} = 'browser';
    $info->{url} = $self->_find_current_url;

    return 1;
}

sub _find_current_url {
    my $self = shift;

    my $json = $self->_parse_current_session;

    my @tabs;
    foreach my $w (@{$json->{"windows"}}) {
        foreach my $t (@{$w->{"tabs"}}) {
            push @tabs,
              {
                last_accessed => $t->{lastAccessed},
                url           => $t->{"entries"}[-1]->{"url"}
              };
        }
    }

    @tabs = sort { $b->{last_accessed} <=> $a->{last_accessed} } @tabs;

    return URI->new($tabs[0]->{url})->host;
}

sub _parse_current_session {
    my $self = shift;

    my $session = $self->_slurp_session;
    return JSON::decode_json($session);
}

sub _slurp_session {
    my $self = shift;

    my ($session_file) =
      glob "$ENV{HOME}/.mozilla/firefox/*default/sessionstore.js";
    return do { local $/; open my $fh, '<', $session_file; <$fh> };
}

1;
