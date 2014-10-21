#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;

use Net::Ping;
use Hijk;
require Hijk::HTTP::XS if $ENV{HIJK_XS};

unless ($ENV{TEST_LIVE}) {
    plan skip_all => "Enable live testing by setting env: TEST_LIVE=1";
}

# find a ip and confirm it is not reachable.
my $pinger = Net::Ping->new("tcp", 2);
$pinger->port_number(80);

my $ip;
my $iter = 10;
do {
    $ip = join ".", 172, (int(rand()*15+16)), int(rand()*250+1),  int(rand()*255+1);
} while($iter-- > 0 && $pinger->ping($ip));

if ($iter == 0) {
    plan skip_all => "Cannot randomly generate an unreachable IP."
}

pass "ip generated = $ip";

throws_ok {
    my $res = Hijk::request({
        host => $ip,
        port => 80,
        timeout => 1            # seconds
    });
} qr/CONNECT\s*TIMEOUT/i;

lives_ok {
    my $res = Hijk::request({
        host => 'google.com',
        port => 80,
        timeout => 0
    });
};


done_testing;

