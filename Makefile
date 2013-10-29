#
# Makefile Security Agency
#

JDIRS := $(shell find src -type d)
FILES := $(foreach d,$(JDIRS),$(wildcard $(d)/*.java))
CLASS := $(patsubst src/%.java,lib/%.class,$(FILES))
CPATH := lib:$(subst $() $(),:,$(wildcard lib/*.jar))
JOPTS := -encoding UTF8

.PHONY: deploy

lib/%.class: src/%.java
	@echo $<
	@javac $(JOPTS) -cp src:$(CPATH) -d lib $<

default: lib/shanghai.jar
	@echo "All compiled: make clean, make test"

compile: $(CLASS) 

lib/shanghai.jar: $(CLASS) lib/shanghai.ttl
	jar cf $@ -C lib org

lib/shanghai.ttl: lib/template.ttl
	@cp $< $@

test: 
	java -cp lib:lib/* org.shanghai.main.Main

check:
	@echo CPATH: $(CPATH)
	@echo FILES: $(FILES)

clean:
	@rm -f $(CLASS)
	@rm -rf lib/org

