# Run or delete Helm templates in sub dirs

.PHONY: all
all: install

.PHONY: install
install:
	@for dir in $(shell find . -mindepth 1 -maxdepth 1 -type d); do \
		if [ -d $$dir/secrets ]; then \
			echo "Executing helm in $$dir..."; \
			helm template gno-validator ../helm --output-dir $$dir/out --values $$dir/values.yaml; \
		fi \
	done

.PHONY: clean
clean:
	@for dir in $(shell find . -mindepth 1 -maxdepth 1 -type d); do \
		if [ -d $$dir/secrets ]; then \
			echo "Removing helm output $$dir/out"; \
			rm -rf $$dir/out; \
		fi \
	done
# helm delele gno-validator

