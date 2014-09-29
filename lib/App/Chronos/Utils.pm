package App::Chronos::Utils;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(are_hashes_equal);

sub are_hashes_equal {
    my ($first, $second) = @_;

    foreach my $key (keys %$first) {
        if (defined $first->{$key} && defined $second->{$key}) {
            if ($first->{$key} ne $second->{$key}) {
                return 0;
            }
        }
        elsif (!defined $first->{$key} && !defined $second->{$key}) {
            next;
        }
        else {
            return 0;
        }
    }

    return 1;
}


1;
