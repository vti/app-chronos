package App::Chronos::Filter::Chromium;

use strict;
use warnings;

use base 'App::Chronos::Filter::Base';

use URI;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub run {
    my $self = shift;
    my ($info) = @_;

    return
      unless $info->{role} =~ m/browser/
      && $info->{name} =~ m/Chromium/
      && $info->{class} =~ m/Chromium/;

    $info->{activity} = 'browser';
    $info->{url} = $self->_find_current_url;

    return 1;
}

sub _find_current_url {
    my $self = shift;

    my $file = "$ENV{HOME}/.config/chromium/Default/Current Session";
    my $current_session = do { local $/; open my $fh, '<', $file; <$fh> };

    my ($sig, $version, @commands) = unpack("LL(v/a)*", $current_session);

    my $last_command;
    foreach my $command (reverse @commands) {
        my $type = substr($command, 0, 1, '');
        $type = unpack 'c', $type;

        if ($type == 1 || $type == 6) {
            $last_command = $command;
            last;
        }
    }

    return unless $last_command;

    my (undef, undef, undef, $url) = unpack 'VVVV/a', $last_command;

    return URI->new($url)->host;
}

1;