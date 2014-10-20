package App::Chronos::Application::GnomeTerminal;

use strict;
use warnings;

use base 'App::Chronos::Application::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    return
         unless $info->{role} =~ m/gnome-terminal/
            && $info->{class} =~ m/gnome-terminal/;

    $info->{application} = 'Gnome Terminal';
    $info->{category}    = 'terminal';

    return 1;
}

1;
