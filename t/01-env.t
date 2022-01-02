use Test;

BEGIN {
  %*ENV{'GITHUB_FOO'} = 'foo';
  %*ENV{'GITHUB_BAR'} = 'bar';
}

use GitHub::Actions;

for <foo bar>  -> $k {
  is( %github{uc($k)}, $k, "Key «$k» set" );
}

if (%*ENV<CI> ) { # We're in an actual Github Action
  diag(%github);
  is(%github{'ACTOR'}, %*ENV{'GITHUB_ACTOR'}, 'Action run by us' );
  like( %github{'EVENT_NAME'}, rx{^(push|pull_request)$}, "Activated by push
or pull_request" );
  is( %github{'REPOSITORY'},
          %*ENV{'GITHUB_REPOSITORY'},
          'We are in the right repository' );
  is( %github{'REF'}, %*ENV<GITHUB_REF>, 'We are in the right branch' );
  like( %github{'REF'},
          rx/ ^ "refs" ("heads"|"pull"|"tags" )/,
          'We are in the right branch' );
  is( %github{'SERVER_URL'}, 'https://github.com', 'We are in the correct server' );
  for <RUN_ID RUN_NUMBER> -> $n {
    like( %github{$n}, rx/\d+/, 'Run-related numbers are numbers' );
  }
  like( %github{'WORKSPACE'}, rx/GitHub/, "Workspace includes repo name" );
}


done-testing;