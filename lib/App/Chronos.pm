package App::Chronos;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use App::Chronos::Logger;
use App::Chronos::Tracker;
use App::Chronos::Filter::Firefox;
use App::Chronos::Filter::Chromium;
use App::Chronos::Filter::Skype;
use App::Chronos::Filter::Pidgin;
use App::Chronos::Filter::Thunderbird;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{logger}  = App::Chronos::Logger->build($params{logger});
    $self->{tracker} = App::Chronos::Tracker->new(
        idle_timeout  => $params{idle_timeout},
        flush_timeout => $params{flush_timeout},
        filters       => [
            App::Chronos::Filter::Firefox->new,
            App::Chronos::Filter::Chromium->new,
            App::Chronos::Filter::Skype->new,
            App::Chronos::Filter::Pidgin->new,
            App::Chronos::Filter::Thunderbird->new,
        ],
        on_start => sub {
            my ($start, $info) = @_;

            $self->{logger}->log_start($start, $info);
        },
        on_end => sub {
            my ($end, $info) = @_;

            $self->{logger}->log_end($end, $info);
        }
    );

    return $self;
}

sub track {
    my $self = shift;

    $self->{tracker}->track;

    return $self;
}

1;
__END__

=encoding utf-8

=head1 NAME

App::Chronos - It's new $module

=head1 SYNOPSIS

    use App::Chronos;

=head1 DESCRIPTION

App::Chronos is ...

=head1 LICENSE

Copyright (C) vti.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

vti E<lt>viacheslav.t@gmail.comE<gt>

=cut

