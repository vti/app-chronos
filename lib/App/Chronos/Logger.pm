package App::Chronos::Logger;

use strict;
use warnings;

use App::Chronos::Logger::Stdout;

sub build {
    my $class = shift;
    my ($driver) = shift;

    my $logger_class = __PACKAGE__ . '::' . ucfirst($driver);

    return $logger_class->new(@_);
}

1;
