use Test;
use Test::Output;
use Temp::Path;

BEGIN {
    my $temp-file-name;
    with make-temp-path :suffix<env> {
        $temp-file-name = .path;
    }
    %*ENV{'GITHUB_ENV'} //= $temp-file-name;
}
use GitHub::Actions;

sub setting_output {
  set-output('FOO','BAR');
}

stdout-is(&setting_output,"::set-output name=FOO::BAR\n", "Sets output" );

set-env("FOO", "bar");

is( %github<ENV>.IO.slurp, "FOO=bar", "Setting env variables OK");

sub setting_empty_output {
  set-output('FOO');
}

stdout-is(&setting_empty_output,"::set-output name=FOO::\n", "Sets output
with empty value" );

sub setting_debug {
  debug('FOO');
}

stdout-is(&setting_debug,"::debug::🦋 FOO\n", "Sets output with empty value" );

sub setting_error {
  error('FOO');
}

stdout-is(&setting_error,"::error::🦋 FOO\n", "Sets error with FOO value" );


sub setting_warning {
  warning('FOO');
}

stdout-is(&setting_warning,"::warning::🦋 FOO\n", "Sets warning with FOO value" );

sub setting_error_on_file {
  error-on-file('FOO', 'foo.pl', 1,1 );
}
stdout-is(&setting_error_on_file,"::error file=foo.pl,line=1,col=1::🦋 FOO\n",
        "Sets error with FOO value" );

sub setting_warning_on_file {
  warning-on-file('FOO', 'foo.pl', 1,1 );
}
stdout-is(&setting_warning_on_file,
        "::warning file=foo.pl,line=1,col=1::🦋 FOO\n",
        "Sets warning with FOO value" );

sub setting-group {
  start-group( "foo" );
  warning("bar");
  end-group;
}
stdout-is(&setting-group,
        "::group::foo\n::warning::🦋 bar\n::endgroup::\n",
        "Opens and closes a group" );

done-testing;
