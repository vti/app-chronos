use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use JSON ();
use App::Chronos::Application::Firefox;

subtest 'return false when unknown' => sub {
    my $filter = _build_filter();

    my $ok =
      $filter->run({role => 'terminal', class => 'terminal', name => ''});

    ok !$ok;
};

subtest 'return true when known' => sub {
    my $filter = _build_filter(
        session => JSON::encode_json(
            {
                windows => [
                    {
                        tabs => [
                            {
                                lastAccessed => 1,
                                entries      => [{url => 'http://foo.bar'}]
                            }
                        ]
                    }
                ]
            }
        )
    );

    my $ok =
      $filter->run(
        {role => 'browser', class => 'Navigator', name => 'Firefox'});

    ok $ok;
};

subtest 'find last accessed url' => sub {
    my $filter = _build_filter(
        session => JSON::encode_json(
            {
                windows => [
                    {
                        tabs => [
                            {
                                lastAccessed => 1,
                                entries      => [{url => 'http://foo.bar'}]
                            },
                            {
                                lastAccessed => 2,
                                entries      => [
                                    {url => 'http://before.com'},
                                    {url => 'http://latest.bar/foo?bar'}
                                ]
                            }
                        ]
                    }
                ]
            }
        )
    );

    my $info = {role => 'browser', class => 'Navigator', name => 'Firefox'};
    my $ok = $filter->run($info);

    is $info->{url}, 'latest.bar';
};

subtest 'set empty url when not available' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => 'browser',
        class => 'Navigator',
        name  => 'Firefox'
    };

    my $ok = $filter->run($info);

    is $info->{url}, '';
};

subtest 'add activity' => sub {
    my $filter = _build_filter();

    my $info = {
        role  => 'browser',
        class => 'Navigator',
        name  => 'Firefox'
    };

    my $ok = $filter->run($info);

    is $info->{activity}, 'browser';
};

sub _build_filter {
    my (%params) = @_;

    my $filter = App::Chronos::Application::Firefox->new;
    $filter = Test::MonkeyMock->new($filter);
    $filter->mock(_slurp_session => sub { $params{session} || '{}' });
    return $filter;
}

done_testing;
