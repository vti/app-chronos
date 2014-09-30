use strict;
use warnings;

use Test::More;
use App::Chronos::Utils qw(are_hashes_equal parse_time);

subtest 'compare two empty hashes' => sub {
    ok are_hashes_equal({}, {});
};

subtest 'compare two equal hashes' => sub {
    ok are_hashes_equal({foo => 'bar'}, {foo => 'bar'});
};

subtest 'equal when values undefined' => sub {
    ok are_hashes_equal({foo => undef}, {foo => undef});
};

subtest 'not equal when different values' => sub {
    ok !are_hashes_equal({foo => 'bar'}, {foo => 'baz'});
};

subtest 'not equal when one is undefined' => sub {
    ok !are_hashes_equal({foo => 'bar'}, {foo => undef});
};

subtest 'not equal different keys' => sub {
    ok !are_hashes_equal({foo => 'bar'}, {bar => 'foo'});
};

subtest 'parse date' => sub {
    is parse_time('2014-09-30'), 1412035200;
};

subtest 'parse date with time' => sub {
    is parse_time('2014-09-30 09:01:12'), 1412067672;
};

done_testing;
