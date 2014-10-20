package App::Chronos::Application::GnomeTerminal;

use strict;
use warnings;

use base 'App::Chronos::Application::Base';

use Data::Dumper;
sub run {
    my $self = shift;
    my ($info) = @_;
    print STDERR Dumper($info);

    return
         unless $info->{role} =~ m/gnome-terminal/
            && $info->{class} =~ m/gnome-terminal/;

    $info->{application} = 'Gnome Terminal';
    $info->{category}    = 'terminal';

    return 1;
}

1;
