unit module GitHub::Actions;

# Module implementation here
our %github is export;
our $EXIT_CODE = 0;

INIT {
    for %*ENV.kv -> $k, $v {
        if ( $k ~~ /^GITHUB_/ ) {
            $k ~~ /^GITHUB_$<nogithub>=(\w+)/;
            %github{$<nogithub>} = $v ;
        }
    }
}

sub set-output( Str:D $name!, $value = '') is export {
  say "::set-output name=$name\::$value";
}

sub cameliafy( $msg ) {
    return "🦋 $msg"
}

sub set-env( Str:D $name!, $value = '') is export {
  %github<ENV>.IO.spurt( "$name=$value", :append );
}

sub debug( Str:D $message! ) is export {
    say "::debug::" ~ cameliafy($message);
}

sub error( Str:D $message! ) is export {
  $EXIT_CODE = 1;
  say "::error::" ~ cameliafy($message);
}

sub warning( Str:D $message! ) is export {
  say "::warning::" ~ cameliafy($message);
}


sub error-on-file( $msg, $file, $line, $col ) is export {
  command-on-file( "::error", $msg, $file, $line, $col );
}

sub warning-on-file( $msg, $file, $line, $col ) is export {
  command-on-file( "::warning", $msg, $file, $line, $col );
}


sub command-on-file( Str:D $command is copy, $message, $file, $line, $col ) {
  if ( $file ) {
    my @data;
    push( @data, "file=$file");
    push( @data, "line=$line") if $line;
    push( @data, "col=$col") if $col;
    $command ~= " " ~ @data.join("," );
  }
  say $command ~ "::" ~ cameliafy($message);
}

sub start-group( $group-name ) is export {
  say "::group::" ~ $group-name;
}

sub end-group is export {
  say "::endgroup::";
}

sub set-failed( *@args ) is export {
  error( @args );
  exit( 1);
}

sub exit-action is export {
  exit( $EXIT_CODE );
}

=begin pod

=head1 NAME

GitHub::Actions - Work in GitHub Actions using Raku

=head1 VERSION

This document describes GitHub::Actions version 0.0.1

=head1 SYNOPSIS

    use GitHub::Actions;

    # Imported %github contains all GITHUB_* environment variables
    for %github.kv -> $k, $v  {
       say "GITHUB_$k -> ", $v
    }

    # Set step output
    set-output("FOO", "BAR");

    # Set environment variable value
    set-env("FOO", "BAR");

    # Produces an error and sets exit code to 1
    error( "FOO has happened" );

    # Error/warning with information on file
    error-on-file( "There's foo", $file, $line, $col );
    warning-on-file( "There's bar", $file, $line, $col );

    # Debugging messages and warnings
    debug( "Value of FOO is $bar" );
    warning( "Value of FOO is $bar" );

    # Start and end group
    start-group( "Foo" );
    # do stuff
    end-group;

    # Exits with error if that's the case
    exit-action();

    # Errors and exits
    set-failed( "We're doomed" );

Install this module within a GitHub action

      - name: "Install GitHub::Actions"
        run: sudo cpan GitHub::Actions

(we need C<sudo> since we're using the system Perl)

You can use this as a C<step> (if you are running this inside a Raku
container such as L<this one|https://github.com/JJ/alpine-raku>.

      - name: Test env variables
        shell: raku {0}
        run: |
          use GitHub::Actions;
          set-env( 'FOO', 'BAR');

In most cases, you'll want to just have it installed locally and fatpack it to
upload it to the repository.

=head1 DESCRIPTION

GitHub Actions include by default, at least in its Linux runners, a
system Perl which you can use directly in your GitHub actions. This here is
a (for the time being) minimalistic module that tries to help a bit
with that, by defining a few functions that will be useful when
performing GitHub actions. Besides the system Perl, you can use any of
L<the modules
installed|https://gist.github.com/JJ/edf3a39d68525439978da2a02763d42b>. You
can install other modules via cpan or, preferably for speed, via the
Ubuntu package (or equivalent)

Check out an example of using it in the L<repository|https://github.com/JJ/perl-GitHub-Actions/blob/main/.github/workflows/self-test.yml>

=head1 INTERFACE

=head2 set-env( $env-var-name, $env-var-value)

This is equivalent to
L<setting an environment variable|https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-an-environment-variable>

=head2 set-output( $output-name, $output-value)

Equivalent to L<C<set-output>|https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-an-output-parameter>

=head2 debug( $debug-message )

Equivalent to L<C<debug>|https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-a-debug-message>

=head2 error( $error-message )

Equivalent to
L<C<error>|https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-an-error-message>,
prints an error message. Remember to call L<exit-action()> to make the step fail
if there's been some error.

=head2 warning( $warning-message )

Equivalent to L<C<warning>|https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-a-warning-message>, simply prints a warning.

=head2 command-on-file( $error-message, $file, $line, $col )

Common code for L<error-on-file> and L<warning-on-file>. Can be used for any future commands.

=head2 error-on-file( $error-message, $file, $line, $col )

Equivalent to L<C<error>|https://docs.github.com/en/free-pro-team@latest/actions/reference/workflow-commands-for-github-actions#setting-an-error-message>, prints an error message with file and line info

=head2 warning-on-file( $warning-message, $file, $line, $col )

Equivalent to L<C<warning>|https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions#setting-a-warning-message>, prints an warning with file and line info.

=head2 set-failed( $error-message )

Exits with an error status of 1 after setting the error message.

=head2 start-group( $group-name )

Starts a group in the logs, grouping the following messages. Corresponds to
L<C<group>|https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions#grouping-log-lines>.

=head2 end-group

Ends current log grouping.

=head2 exit-action

Exits with the exit code generated during run, that is, 1 if there's been any
error reported.

=head1 CONFIGURATION AND ENVIRONMENT

GitHub::Actions requires no configuration files or environment
variables. Those set by GitHub Actions will only be available there,
or if you set them explicitly. Remember that they will need to be set
during the C<BEGIN> phase to be available when this module loads.

    BEGIN {
      $ENV{'GITHUB_FOO'} = 'foo';
      $ENV{'GITHUB_BAR'} = 'bar';
    }


=head1 DEPENDENCIES

Intentionally, no dependencies are included.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to L<https://github.com/JJ/perl-GitHub-Actions/issues>.


=head1 AUTHOR

JJ Merelo  C<< <jj@raku.org> >>. Many thanks to RENEEB and Gabor Szabo for
their help with test and metadata.


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2021, JJ Merelo C<< <jj@raku.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=end pod
