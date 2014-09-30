package App::Chronos::Filter::Thunderbird;

use strict;
use warnings;

use base 'App::Chronos::Filter::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    return unless $info->{class} =~ m/(?:Thunderbird|Icedove)"$/;

    $info->{activity} = 'email';

    return 1;
}

1;
