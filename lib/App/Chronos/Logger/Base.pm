package App::Chronos::Logger::Base;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub log_start {
    ...
}

sub log_end {
    ...
}

1;
