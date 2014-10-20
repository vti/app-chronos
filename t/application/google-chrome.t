use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use JSON ();
use App::Chronos::Application::GoogleChrome;

subtest 'return false when unknown' => sub {
    my $filter = _build_filter();

    my $ok =
      $filter->run({role => 'terminal', class => 'terminal', name => ''});

    ok !$ok;
};

subtest 'return true when known' => sub {
    my $filter = _build_filter();

    my $ok =
      $filter->run(
        {role => 'browser', class => '"Google-chrome-stable", "Google-chrome-stable"', name => '"New Tab - Google Chrome"'});

    ok $ok;
};

subtest 'add application' => sub {
    my $filter = _build_filter();

    my $info = {role => 'browser', class => '"Google-chrome-stable", "Google-chrome-stable"', name => 'New Tab - Google Chrome'};

    my $ok = $filter->run($info);

    is $info->{application}, 'Google Chrome';
};

subtest 'add category' => sub {
    my $filter = _build_filter();

    my $info = {role => 'browser', class => '"Google-chrome-stable", "Google-chrome-stable"', name => 'New Tab - Google Chrome'};

    my $ok = $filter->run($info);

    is $info->{category}, 'browser';
};

sub _build_filter {
    my (%params) = @_;

    my $filter = App::Chronos::Application::GoogleChrome->new;
    $filter = Test::MonkeyMock->new($filter);
    return $filter;
}

done_testing;
