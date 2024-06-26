#!/usr/bin/perl

use warnings;
use strict;

use File::Basename;
use YAML ();
use Test::More;

plan tests => 7;

chdir(dirname($0));
my $conf = YAML::LoadFile("docker-compose.yml");

is(ref $conf->{'services'}, "HASH", "read docker-compose.yml");
is(scalar %{$conf->{'services'}}, 1, "read services from docker-compose.yml");

for my $svc (sort keys %{$conf->{'services'}}) {
	my $app = $conf->{'services'}->{$svc};
	ok(1, $svc);
	for my $port (@{$app->{'ports'}}) {
		my($localport, $remoteport) = split(/:/mx, $port);
		ok(1, " - ".$remoteport);
		if($remoteport eq "5901") {
			# vnc test
			eval {
				alarm(3);
				local $SIG{'ALRM'} = sub { die("timeout"); };
				my $out = `echo "" | nc -q 1 -w 1 0.0.0.0 $localport 2>&1`;
				like($out, '/RFB/', "vnc connect header found")
			};
			alarm(0);
			fail($@) if $@;
		}
		elsif($remoteport eq "6901") {
			# http test
			eval {
				alarm(3);
				local $SIG{'ALRM'} = sub { die("timeout"); };
				my $out = `curl -s http://0.0.0.0:$localport/?password=123 2>&1`;
				like($out, '/noVNC/', "web vnc html contains noVNC")
			};
			alarm(0);
			fail($@) if $@;
		} else {
			die("unknown port: ".$remoteport);
		}
	}
}
