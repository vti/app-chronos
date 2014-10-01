use strict;
use warnings;

use Test::More;
use App::Chronos::Application::Pidgin;

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
            role  => '"conversation"',
            class => '"Pidgin", "Pidgin"',
            name  => 'name'
        }
    );

    ok $ok;
};

subtest 'add application' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => '"conversation"',
        class => '"Pidgin", "Pidgin"',
        name  => 'name'
    };
    my $ok = $filter->run($info);

    is $info->{application}, 'Pidgin';
};

subtest 'add contact' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => '"conversation"',
        class => '"Pidgin", "Pidgin"',
        name  => '"name"'
    };
    my $ok = $filter->run($info);

    is $info->{contact}, 'name';
};

sub _build_filter {
    return App::Chronos::Application::Pidgin->new;
}

done_testing;
