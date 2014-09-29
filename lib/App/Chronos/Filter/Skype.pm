package App::Chronos::Filter::Skype;

use strict;
use warnings;

use base 'App::Chronos::Filter::Base';

sub run {
    my $self = shift;
    my ($info) = @_;

    return
      unless $info->{role} =~ m/ConversationsWindow/
      && $info->{class} =~ m/Skype/
      && $info->{name} =~ m/Skype/;

    $info->{activity} = 'im';
    ($info->{contact}) = $info->{name} =~ m/^"(.*?) - Skype/;

    return 1;
}

1;
