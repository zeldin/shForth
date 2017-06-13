all: forth

forth: config.sh
	./forth.sh --dump

config.sh: autoconf.sh core.sh forth.sh io.sh coreext.sh interpreter.sh memory.sh
	./forth.sh --configure

check: forth
	@echo '." Test complete." cr bye' | ./forth

clean:
	rm -f config.sh forth

.PHONY: all check clean
