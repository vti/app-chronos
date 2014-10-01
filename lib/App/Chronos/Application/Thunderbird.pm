package App::Chronos::Application::Thunderbird;

use strict;
use warnings;

use base 'App::Chronos::Application::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    return unless $info->{class} =~ m/(?:Thunderbird|Icedove)"$/;

    $info->{application} = 'Thunderbird';

    return 1;
}

1;
