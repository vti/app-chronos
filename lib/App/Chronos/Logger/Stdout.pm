package App::Chronos::Logger::Stdout;

use strict;
use warnings;

use base 'App::Chronos::Logger::Base';

use JSON ();

sub log_start {
    my $self = shift;
    my ($start, $info) = @_;

    print "\n", JSON::encode_json($info), ' start=', $start, ' ';
}

sub log_end {
    my $self = shift;
    my ($end, $info) = @_;

    print 'end=', $end, "\n";
}

1;
