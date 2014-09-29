use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use App::Chronos::X11;

subtest 'parse xprop results' => sub {
    my $x11 = _build_x11(
        '-root _NET_ACTIVE_WINDOW' =>
          '_NET_ACTIVE_WINDOW(WINDOW): window id # 0x0000001, 0x0',
        '-id 0x0000001' => <<'EOM',
WM_WINDOW_ROLE(STRING) = "conversation"
WM_CLASS(STRING) = "Pidgin", "Pidgin"
WM_NAME(STRING) = "foo"
_NET_WM_NAME(UTF8_STRING) = "foo"
EOM
    );

    my $info = $x11->get_active_window();

    is_deeply $info,
      {
        'id'      => '0x0000001',
        'name'    => '"foo"',
        'role'    => '"conversation"',
        'class'   => '"Pidgin", "Pidgin"',
        'command' => ''
      };
};

subtest 'parse xprop results when name is not a string' => sub {
    my $x11 = _build_x11(
        '-root _NET_ACTIVE_WINDOW' =>
          '_NET_ACTIVE_WINDOW(WINDOW): window id # 0x0000001, 0x0',
        '-id 0x0000001' => <<'EOM',
WM_WINDOW_ROLE(STRING) = "conversation"
WM_CLASS(STRING) = "Pidgin", "Pidgin"
WM_NAME(SOMETHING ELSE) = "foo"
_NET_WM_NAME(UTF8_STRING) = "foo"
EOM
    );

    my $info = $x11->get_active_window();

    is_deeply $info,
      {
        'id'      => '0x0000001',
        'name'    => '"foo"',
        'role'    => '"conversation"',
        'class'   => '"Pidgin", "Pidgin"',
        'command' => ''
      };
};

sub _build_x11 {
    my (%params) = @_;

    my $x11 = App::Chronos::X11->new(@_);
    $x11 = Test::MonkeyMock->new($x11);
    $x11->mock(
        _run_xprop => sub {
            shift;
            my (@args) = @_;

            my $cmd = join(' ', @args);
            if (exists $params{$cmd}) {
                return $params{$cmd};
            }

            die "unknown params: $cmd";
        }
    );
    return $x11;
}

done_testing;
