use strict;
use warnings;

use Test::More;
use App::Chronos::Application::Thunderbird;

subtest 'return false when unknown' => sub {
    my $filter = _build_filter();

    my $ok =
      $filter->run({role => 'terminal', class => 'terminal', name => ''});

    ok !$ok;
};

subtest 'return true when known' => sub {
    my $filter = _build_filter();

    my $ok = $filter->run(
        {
            role  => 'MsgCompose',
            class => '"MsgCompose", "Icedove"',
            name  => 'Reply to: '
        }
    );

    ok $ok;
};

subtest 'add application' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => 'MsgCompose',
        class => '"MsgCompose", "Icedove"',
        name  => 'Reply to: '
    };
    $filter->run($info);

    is $info->{application}, 'Thunderbird';
};

sub _build_filter {
    return App::Chronos::Application::Thunderbird->new;
}

done_testing;
