package App::Chronos::Tracker;

use strict;
use warnings;

use App::Chronos::X11;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{idle_timeout}  = $params{idle_timeout}  || 300;
    $self->{flush_timeout} = $params{flush_timeout} || 300;
    $self->{filters}       = $params{filters};
    $self->{on_start}      = $params{on_start};
    $self->{on_end}        = $params{on_end};

    return $self;
}

sub track {
    my $self = shift;

    if ($self->_is_idle || $self->_is_time_to_flush) {
        $self->{on_end}->($self->_time, $self->{prev})
          if %{$self->{prev} || {}};
        $self->{prev} = {};
        return;
    }

    my $x11 = $self->{x11} ||= $self->_build_x11;
    my $info = $x11->get_active_window;

    my $prev = $self->{prev} ||= {};
    my $time = $self->_time;

    foreach my $filter (@{$self->{filters}}) {
        local $@;
        my $rv = eval { $filter->run($info) };
        next if $@;

        last if $rv;
    }

    $info->{$_} //= '' for (qw/id name role class/);
    $info->{activity} ||= 'other';

    if (  !$prev->{id}
        || $info->{id} ne $prev->{id}
        || $info->{name} ne $prev->{name}
        || $info->{role} ne $prev->{role}
        || $info->{class} ne $prev->{class})
    {
        $self->{on_end}->($time, $prev) if %$prev;

        $self->{on_start}->($time, $info);
    }

    $self->{prev} = $info;

    return $self;
}

sub _is_idle {
    my $self = shift;

    return $self->_idle_time > $self->{idle_timeout};
}

sub _is_time_to_flush {
    my $self = shift;

    $self->{flush_time} //= $self->_time;

    if ($self->_time - $self->{flush_time} > $self->{flush_timeout}) {
        $self->{flush_time} = $self->_time;
        return 1;
    }

    return 0;
}

sub _build_x11 {
    return App::Chronos::X11->new;
}

sub _idle_time { int(`xprintidle` / 1000) }
sub _time      { time }

1;
