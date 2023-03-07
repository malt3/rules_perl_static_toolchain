export DOCKER_BUILDKIT=1

.PHONY: all container container-push clean

PERLS = smallperl-amd64 smallperl-arm64 bigperl-amd64 bigperl-arm64
OUTS = $(addprefix out/,$(PERLS))
ARTIFACTS = $(addprefix artifacts/,$(addsuffix .tar.xz,$(PERLS)))

all: $(OUTS) $(ARTIFACTS)

out/smallperl-%:
	docker build -o out -f Containerfile --platform linux/$* --target smallperl .

out/bigperl-%:
	docker build -o out -f Containerfile --platform linux/$* --target bigperl .

artifacts/%.tar.xz: out/%
	mkdir -p trees/$*/bin
	mkdir -p trees/$*/lib
	cp out/$* trees/$*/bin/perl
	touch trees/$*/bin/xsubpp
	chmod +x trees/$*/bin/xsubpp
	mkdir -p artifacts
	tar -C trees -cJf artifacts/$*.tar.xz $*

container:
	docker build -t ghcr.io/malt3/rules_perl_static_toolchain:latest -f Containerfile .

container-push: container
	docker push ghcr.io/malt3/rules_perl_static_toolchain:latest

clean:
	rm -rf out
	rm -rf trees
	rm -rf artifacts
