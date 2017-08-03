# If you update this line, update the first line of README.txt.
FROM alpine

# Arguments
ARG url
ARG build_directory=/tmp/zsh
ARG build_dependencies='coreutils diffutils util-linux curl git make automake autoconf gcc binutils libc-dev ncurses-dev pcre-dev yodl texinfo man man-pages mdocml-apropos groff'
ARG runtime_dependencies='pcre libcap gdbm'
ARG test_user=zsh

# Dependencies
RUN echo http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk add --update --no-cache $runtime_dependencies $build_dependencies

# Build and installation
WORKDIR $build_directory
RUN curl -LSf $url | tar xvz --strip-components=1
RUN ./Util/preconfig
RUN ./configure --enable-pcre --enable-cap --without-tcsetpgrp
RUN make
RUN make install
RUN make install.info || true # Issue 4

# Tests
# run as a non privileged user, as zsh test suite is not designed to run as root
RUN adduser -s /bin/sh -D $test_user
RUN chown -R $test_user $build_directory
RUN su - $test_user -c "cd $build_directory && make test"
RUN deluser --remove-home $test_user

# Cleaning
RUN rm -rf $build_directory
RUN apk del $build_dependencies

# Configuration
WORKDIR /
CMD ['zsh']
