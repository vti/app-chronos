package App::Chronos::Logger::Stdout;

use strict;
use warnings;

use base 'App::Chronos::Logger::Base';

use JSON ();

sub log_start {
    my $self = shift;
    my ($start, $info) = @_;

    $info->{_start} = $start;

    #use Data::Dumper; warn Dumper($info);
    #print $info->{name}, ' ', $start, '...';
}

sub log_end {
    my $self = shift;
    my ($end, $info) = @_;

    print JSON::encode_json({_end => $end, %$info}), "\n";
    #print ' ', $end, "\n";
}

1;
