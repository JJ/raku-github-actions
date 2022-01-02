FROM ghcr.io/jj/raku-zef-gha:latest

LABEL version="1.0.3" maintainer="JJ@Graku.org"

COPY META6.json .
COPY t/ t/
COPY lib/ lib/
RUN zef install . && rm -rf META6.json lib/ t/

ENTRYPOINT ["raku"]