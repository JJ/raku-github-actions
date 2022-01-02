FROM ghcr.io/jj/raku-zef-gha:latest

LABEL version="1.0.3" maintainer="JJ@Graku.org"

ADD META6.json .
RUN zef install . && rm META6.json

ENTRYPOINT ["raku"]