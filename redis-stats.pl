#!/usr/bin/perl

use Redis;
use Data::Dumper;
use Getopt::Long;

my $host = '';
my $port = 6379;
my $auth = '';
my $db = 'db0';

GetOptions(
    'hostname=s' => \$host, 
    'port=s' => \$port,
    'auth=s' => \$auth,
    'db=s' => \$db,
);

unless ($host) {
    print "Hostname/IP is needed!\n";
    exit(1);
}

my $redis_info;
eval {
    my $redis = Redis->new(server => $host . ":" . $port);
    $redis_info = $redis->info;
};
exit(0) if $@;

my %status = (
    'total_connections_received' => 0,
    'connected_clients' => 0,
    'used_memory' => 0,
    'total_commands_processed' => 0,
    'keys' => 0,
    'expires' => 0,
);

if (exists %$redis_info->{$db}) {
    # db0:keys=2,expires=0
    @status{"keys", "expires"} = %$redis_info->{$db} =~ /(?:.*)=(.*),(?:.*)=(.*)$/g;
}

while (($key, $val) = each %status) {
    if (exists %$redis_info->{$key}) {
        $val = %$redis_info->{$key};
    }
    print "$key:" . "$val ";
}


__END__

=head1 NAME
Redis statistics for Cacti

=head1 SYNOPSIS
usage: %prog [--port PORT] [--auth AUTH_PASSWORD ] [ --host HOSTNAME ] [ --db dbx]

Options:
  -help  brief help message
  --port redis server port, default 6379
  --auth redis server auth password
  --host hostname or ip of redis server
  --db   db number, default is db0

=cut
