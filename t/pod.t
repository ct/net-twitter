#!perl -T
 
use Test::More;
eval "use Test::Pod 1.14";
plan skip_all => "ok";
all_pod_files_ok();