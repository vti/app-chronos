use strict;
use warnings;

use Test::More;
use App::Chronos::Filter::Skype;

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
            role  => 'ConversationsWindow',
            class => '"skype", "Skype"',
            name  => 'contact - Skype'
        }
    );

    ok $ok;
};

subtest 'add activity' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => 'ConversationsWindow',
        class => '"skype", "Skype"',
        name  => 'contact - Skype'
    };
    my $ok = $filter->run($info);

    is $info->{activity}, 'im';
};

subtest 'add contact' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => 'ConversationsWindow',
        class => '"skype", "Skype"',
        name  => '"name - Skype"'
    };
    my $ok = $filter->run($info);

    is $info->{contact}, 'name';
};

subtest 'remove contact prefix' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => 'ConversationsWindow',
        class => '"skype", "Skype"',
        name  => '"[1]name - Skype"'
    };
    my $ok = $filter->run($info);

    is $info->{contact}, 'name';
};

sub _build_filter {
    return App::Chronos::Filter::Skype->new;
}

done_testing;
