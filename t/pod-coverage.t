#!perl -T
 
use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "ok";
all_pod_coverage_ok();