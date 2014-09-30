use strict;
use warnings;

use Test::More;
use App::Chronos::Filter::Thunderbird;

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

sub _build_filter {
    return App::Chronos::Filter::Thunderbird->new;
}

done_testing;
