requires 'perl', '5.010000';
requires 'Docopt';
requires 'File::Which';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::MockTime';
    requires 'Test::MonkeyMock';
};

