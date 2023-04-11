LESS := $(notdir $(wildcard *.less))

CSS := $(LESS:%.less=css/%.css)


css/%.css:%.less
	./clessc -f $< -m --source-map-url=$<.map -o $@

.PHONY: echo all copy

prelog:
	@if [ ! -f css ]; then\
		mkdir -p css;\
	fi

all: prelog $(CSS)
	
echo:
	@echo $(CSS)
