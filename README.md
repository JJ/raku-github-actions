# GitHub::Actions for Raku [![Test in a Raku container - template](https://github.com/JJ/raku-github-actions/actions/workflows/test.yaml/badge.svg)](https://github.com/JJ/raku-github-actions/actions/workflows/test.yaml)

Use the GitHub actions console API easily from [Raku](https://raku.org). Essentially, a
 port to
Raku of the [equivalent Perl module](https://metacpan.org/pod/GitHub::Actions), mainly intended to be run inside the [Raku
container for GitHub actions](https://github.com/JJ/alpine-raku), but can of
course be used independently.

## Installing


Install it the usual way, using `zef`:

    zef install GitHub::Actions

Also use it from the companion Docker image,

    docker pull --rm -it --entrypoint=/bin/sh ghcr.io/jj/raku-github-actions:latest


## Running

This is a version derived from the base [Raku image for
GHA](ghcr.io/jj/raku-zef-gha) with this module and its dependencies
installed. You can use it directly in your GitHub actions, for instance like
this:

```yaml
      - name: Test output
        id: output_test
        shell: raku {0}
        run:
          use GitHub::Actions;
          set-output( 'FOO', 'BAR');
```

What this is doing is using the GHA syntax for using alternative shells
 `shell`; the script in the `run` clause will be interpreted using that "shell".

Check [the Pod6 here](lib/GitHub/Actions.rakumod) for methods available.

## Synopsis

```raku

use GitHub::Actions:

say %github; # Contains all GITHUB_xyz variables

set-output('FOO','BAR');
set-output('FOO'); # Empty value
set-env("FOO", "bar");
debug('FOO');
error('FOO');
warning('FOO');

error-on-file('FOO', 'foo.pl', 1,1 );

warning-on-file('FOO', 'foo.raku', 1,1 );

# sets group
start-group( "foo" );
warning("bar");
end-group;
```

## See also

Created from the
[Raku distribution template](https://github.com/JJ/raku-dist-template).

## License

(c) JJ Merelo, jj@raku.org, 2022
Licensed, under the Artistic 2.0 License (the same as Raku itself).
