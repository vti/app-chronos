use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MockTime ();
use Test::MonkeyMock;
use App::Chronos::Tracker;

subtest 'run on_start on start' => sub {
    my @args;
    my $started = 0;

    my $x11 = _mock_x11([{id => 'foo'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        time     => '123',
        on_start => sub { @args = @_; $started++ }
    );

    $tracker->track;

    is $started, 1;
    is_deeply \@args,
      [
        123,
        {
            _start   => 123,
            activity => 'other',
            id       => 'foo',
            name     => '',
            class    => '',
            role     => ''
        }
      ];
};

subtest 'not run on_end when same info' => sub {
    my $ended = 0;

    my $x11 = _mock_x11([{id => 'foo'}, {id => 'foo'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        on_start => sub { },
        on_end   => sub { $ended++ }
    );

    $tracker->track;
    $tracker->track;

    is $ended, 0;
};

subtest 'run on_end when idle' => sub {
    my $ended = 0;

    my $i       = 0;
    my $x11     = _mock_x11([{id => 'foo'}, {id => 'foo'}]);
    my $tracker = _build_tracker(
        idle_timeout => 10,
        idle_time    => sub { $i++ > 0 ? 100 : 0 },
        x11          => $x11,
        on_start => sub { },
        on_end   => sub { $ended++ }
    );

    $tracker->track;
    $tracker->track;

    is $ended, 1;
};

subtest 'not run on_end when idle but already finished' => sub {
    my $ended = 0;

    my $x11 = _mock_x11([{id => 'foo'}, {id => 'foo'}]);
    my $tracker = _build_tracker(
        idle_timeout => 10,
        idle_time    => sub { 100 },
        x11          => $x11,
        on_start     => sub { },
        on_end       => sub { $ended++ }
    );

    $tracker->track;

    is $ended, 0;
};

subtest 'when idle_timeout set end time not to the absolute time' => sub {
    my $ended = 0;

    my $i = 0;
    my $time;
    my $x11 = _mock_x11([{id => 'foo'}, {id => 'foo'}]);
    my $tracker = _build_tracker(
        idle_timeout => 15,
        idle_time    => sub { $i++ > 0 ? 100 : 0 },
        x11          => $x11,
        on_start => sub { },
        on_end   => sub { $time = shift }
    );

    Test::MockTime::set_absolute_time('1970-01-01T00:00:00Z');

    $tracker->track;

    Test::MockTime::set_absolute_time('1970-01-01T00:00:20Z');

    $tracker->track;

    Test::MockTime::restore_time();

    is $time, 15;
};

subtest 'run on_end when flush_timeout' => sub {
    my $ended = 0;

    my $i       = 0;
    my $x11     = _mock_x11([{id => 'foo'}, {id => 'foo'}]);
    my $tracker = _build_tracker(
        flush_timeout => 10,
        x11           => $x11,
        on_start      => sub { },
        on_end        => sub { $ended++ }
    );

    Test::MockTime::set_absolute_time('1970-01-01T00:00:00Z');

    $tracker->track;

    Test::MockTime::set_absolute_time('1970-01-01T00:00:20Z');

    $tracker->track;

    Test::MockTime::restore_time();

    is $ended, 1;
};

subtest 'when flush_timeout set end time not to the absolute time' => sub {
    my $ended = 0;

    my $i = 0;
    my $time;
    my $x11 = _mock_x11([{id => 'foo'}, {id => 'foo'}]);
    my $tracker = _build_tracker(
        flush_timeout => 10,
        x11           => $x11,
        on_start      => sub { },
        on_end        => sub { $time = shift }
    );

    Test::MockTime::set_absolute_time('1970-01-01T00:00:00Z');

    $tracker->track;

    Test::MockTime::set_absolute_time('1970-01-01T00:00:20Z');

    $tracker->track;

    Test::MockTime::restore_time();

    is $time, 10;
};

subtest 'run on_end on end' => sub {
    my @args;
    my $ended = 0;

    my $x11 = _mock_x11([{id => 'foo'}, {id => 'new'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        time     => '123',
        on_start => sub { },
        on_end   => sub { @args = @_; $ended++ }
    );

    $tracker->track;
    $tracker->track;

    is $ended, 1;
    is_deeply \@args,
      [
        123,
        {
            _start   => 123,
            id       => 'foo',
            activity => 'other',
            name     => '',
            class    => '',
            role     => ''
        }
      ];
};

subtest 'run filters' => sub {
    my @args;
    my $x11 = _mock_x11([{id => 'foo'}, {id => 'new'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        on_start => sub { },
        on_end   => sub { @args = @_ },
        filters  => [TestFilter->new]
    );

    $tracker->track;
    $tracker->track;

    is $args[1]->{filter}, 1;
};

subtest 'catch filter exceptions' => sub {
    my @args;
    my $x11 = _mock_x11([{id => 'foo'}, {id => 'new'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        on_start => sub { },
        on_end   => sub { @args = @_ },
        filters  => [TestFilterError->new]
    );

    ok !exception { $tracker->track };
};

subtest 'stop when filter returns true' => sub {
    my @args;
    my $x11 = _mock_x11([{id => 'foo'}, {id => 'new'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        on_start => sub { },
        on_end   => sub { @args = @_ },
        filters => [TestFilter->new, TestFilter->new]
    );

    $tracker->track;
    $tracker->track;

    is $args[1]->{filter}, 1;
};

subtest 'not stop when filter returns false' => sub {
    my @args;
    my $x11 = _mock_x11([{id => 'foo'}, {id => 'new'}]);
    my $tracker = _build_tracker(
        x11      => $x11,
        on_start => sub { },
        on_end   => sub { @args = @_ },
        filters => [TestFilterFalse->new, TestFilterFalse->new]
    );

    $tracker->track;
    $tracker->track;

    is $args[1]->{filter}, 2;
};

sub _mock_x11 {
    my ($variants) = @_;

    my $x11 = Test::MonkeyMock->new;
    $x11->mock(get_active_window => sub { shift @$variants });
    return $x11;
}

sub _build_tracker {
    my (%params) = @_;

    my $x11       = delete $params{x11};
    my $time      = delete $params{time};
    my $idle_time = delete $params{idle_time};

    my $tracker = App::Chronos::Tracker->new(%params);
    $tracker = Test::MonkeyMock->new($tracker);
    $tracker->mock(_time => sub { $time }) if $time;
    $tracker->mock(_build_x11 => sub { $x11 });
    $tracker->mock(_idle_time => $idle_time || sub { 0 });
    return $tracker;
}

done_testing;

package TestFilter;
use base 'App::Chronos::Filter::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    $info->{filter}++;

    return 1;
}

package TestFilterFalse;
use base 'App::Chronos::Filter::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    $info->{filter}++;

    return;
}

package TestFilterError;
use base 'App::Chronos::Filter::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    die 'here';

    return 1;
}
