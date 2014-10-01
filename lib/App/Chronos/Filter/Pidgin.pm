package App::Chronos::Filter::Pidgin;

use strict;
use warnings;

use base 'App::Chronos::Filter::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    return
      unless $info->{role} =~ m/conversation/
      && $info->{class} =~ m/Pidgin/;

    $info->{activity} = 'im';
    ($info->{contact}) = $info->{name} =~ m/"(.*?)"/;

    return 1;
}

1;
