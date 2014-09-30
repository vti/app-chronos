package App::Chronos::Report;

use strict;
use warnings;

use Time::Piece;
use JSON        ();
use Digest::MD5 ();

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{log_file} = $params{log_file};
    $self->{where}    = $params{where};
    $self->{group_by} = $params{group_by};
    $self->{fields}   = $params{fields};

    return $self;
}

sub run {
    my $self = shift;

    my @group_by = split /\s*,\s*/, ($self->{group_by} || '');

    my $where_cb;
    if (my $where = $self->{where}) {
        $where =~ s{\$([a-z]+)}{\$_[0]->{$1}}g;
        $where = "sub {no warnings; $where }";

        $where_cb = eval $where or die $@;
    }

    open my $fh, '<', $self->{log_file} or die $!;

    my @from = (gmtime(time))[3..5];
    my $from = join '-', ($from[2] + 1900), ($from[1] + 1), $from[0];
    $from = Time::Piece->strptime($from, '%Y-%m-%d')->epoch;
    my $to = time;

    my @records;
    while (defined(my $line = <$fh>)) {
        chomp $line;
        next unless $line;

        next
          unless my ($json, $start, $end) =
          $line =~ m/^(.*?) start=(\d+) end=(\d+)$/;

        next unless $end >= $from && $end <= $to;
        if ($start < $from) {
            $start = $from;
        }

        my $record = eval { JSON::decode_json($json); };
        next unless $record;

        next if $where_cb && !$where_cb->($record);

        $record->{_elapsed} = $end - $start;
        $record->{_sig} = calculate_sig($record, @group_by);
        push @records, $record;
    }

    my %groups;
    foreach my $record (@records) {
        if (exists $groups{$record->{_sig}}) {
            $groups{$record->{_sig}}->{_elapsed} += $record->{_elapsed};
        }
        else {
            $groups{$record->{_sig}} = $record;
        }
    }

    my @sorted_sig =
      sort { $groups{$b}->{_elapsed} <=> $groups{$a}->{_elapsed} } keys %groups;

    foreach my $sig (@sorted_sig) {
        my $record = $groups{$sig};
        $self->_print(sec2human($record->{_elapsed}), ' ');

        my @fields = split /\s*,\s*/, ($self->{fields} || '');
        @fields = @group_by unless @fields;
        foreach my $field (@fields) {
            $self->_print("$field=$record->{$field} ");
        }

        $self->_print("\n");
    }
}

sub calculate_sig {
    my ($record, @group_by) = @_;

    return '' unless @group_by;

    my $sig = '';
    foreach my $group_by (@group_by) {
        $record->{$group_by} //= '';
        $sig .= $record->{$group_by} . ':';
    }

    return Digest::MD5::md5_hex($sig);
}

sub sec2human {
    my $sec = shift;

    return
        sprintf('%02d', int($sec / (24 * 60 * 60))) . 'd '
      . sprintf('%02d', ($sec / (60 * 60)) % 24) . ':'
      . sprintf('%02d', ($sec / 60) % 60) . ':'
      . sprintf('%02d', $sec % 60);
}

sub _print {
    my $self = shift;

    print @_;
}

1;
