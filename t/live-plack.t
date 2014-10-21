#!/usr/bin/env perl

use strict;
use FindBin;

use Hijk;

use Test::More;
use Test::Exception;

unless ($ENV{TEST_LIVE}) {
    plan skip_all => "Enable live testing by setting env: TEST_LIVE=1";
}

my $pid = fork;
die "Fail to fork then start a plack server" unless defined $pid;

if ($pid == 0) {
    require Plack::Runner;
    my $runner = Plack::Runner->new;
    print STDERR "$FindBin::Bin/bin/it-takes-time.psgi\n";
    $runner->parse_options("--port", "5001", "$FindBin::Bin/bin/it-takes-time.psgi");
    $runner->run;
    exit;
}

sleep 5; # hopfully this is enough to launch that psgi.

my %args = (
    host => "localhost",
    port => "5001",
    query_string => "t=5",
    method => "GET",
);

subtest "expect timeout" => sub {
    throws_ok {
        my $res = Hijk::request({%args, timeout => 1});
    } qr/timeout/i;
};

subtest "do not expect timeout" => sub {
    lives_ok {
        my $res = Hijk::request({%args, timeout => 10_000});
    } 'local plack send back something within 10s';
};

kill INT => $pid;

done_testing;
