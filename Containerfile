FROM alpine as builder
ARG TARGETARCH
RUN apk add --no-cache \
    build-base \
    xz \
    curl

WORKDIR /
COPY SHA256SUMS /SHA256SUMS
RUN curl -o /usr/local/bin/staticperl -fsSL http://staticperl.schmorp.de/staticperl && \
    sha256sum -c SHA256SUMS && \
    chmod +x /usr/local/bin/staticperl
COPY staticperlrc /etc/staticperlrc
COPY *.bundle /

WORKDIR /out
ENTRYPOINT [ "/usr/local/bin/staticperl" ]
CMD [ "mkperl", "--static"]

FROM builder as bigperl-build

RUN /usr/local/bin/staticperl mkperl --static /bigperl.bundle && \
    mv /out/perl /out/bigperl-${TARGETARCH}

FROM builder as smallperl-build

RUN /usr/local/bin/staticperl mkperl --static /smallperl.bundle && \
    mv /out/perl /out/smallperl-${TARGETARCH}

FROM scratch as bigperl
COPY --from=bigperl-build /out/* /


FROM scratch as smallperl
COPY --from=smallperl-build /out/* /
