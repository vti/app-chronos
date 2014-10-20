use strict;
use warnings;

use Test::More;
use App::Chronos::Application::GnomeTerminal;

subtest 'return false when unknown' => sub {
    my $filter = _build_filter();

    my $ok =
      $filter->run({role => 'pidgin', class => 'pidgin', name => ''});

    ok !$ok;
};

subtest 'return true when known' => sub {
    my $filter = _build_filter();

    my $ok = $filter->run(
        {
            role  => '"gnome-terminal"',
            class => '"gnome-terminal", "Gnome-terminal"',
            name  => 'Terminal'
        }
    );

    ok $ok;
};

subtest 'add application' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => '"gnome-terminal"',
        class => '"gnome-terminal", "Gnome-terminal"',
        name  => 'Terminal'
    };
    my $ok = $filter->run($info);

    is $info->{application}, 'Gnome Terminal';
};

subtest 'add category' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => '"gnome-terminal"',
        class => '"gnome-terminal", "Gnome-terminal"',
        name  => 'Terminal'
    };
    my $ok = $filter->run($info);

    is $info->{category}, 'terminal';
};

sub _build_filter {
    return App::Chronos::Application::GnomeTerminal->new;
}

done_testing;
