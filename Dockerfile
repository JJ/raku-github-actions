FROM ghcr.io/jj/raku-zef-gha:latest

LABEL version="1.0.5" maintainer="JJ@raku.org"

COPY --chown=raku META6.json .
COPY --chown=raku t/ t/
COPY --chown=raku lib/ lib/
USER raku
RUN zef install . --force && rm -rf META6.json lib/ t/

ENTRYPOINT ["raku"]
