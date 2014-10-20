package App::Chronos;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use App::Chronos::Logger;
use App::Chronos::Tracker;
use App::Chronos::Application::Firefox;
use App::Chronos::Application::Chromium;
use App::Chronos::Application::Skype;
use App::Chronos::Application::Pidgin;
use App::Chronos::Application::Thunderbird;
use App::Chronos::Application::GnomeTerminal;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{logger}  = App::Chronos::Logger->build($params{logger});
    $self->{tracker} = App::Chronos::Tracker->new(
        idle_timeout  => $params{idle_timeout},
        flush_timeout => $params{flush_timeout},
        applications  => [
            App::Chronos::Application::Firefox->new,
            App::Chronos::Application::Chromium->new,
            App::Chronos::Application::Skype->new,
            App::Chronos::Application::Pidgin->new,
            App::Chronos::Application::Thunderbird->new,
            App::Chronos::Application::GnomeTerminal->new,
        ],
        on_end => sub {
            my ($info) = @_;

            $self->{logger}->log($info);
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

