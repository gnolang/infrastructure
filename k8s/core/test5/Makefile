# Run or delete Helm templates in sub dirs

.PHONY: all
all: install

.PHONY: 
install:
	@for dir in $(shell find . -mindepth 1 -maxdepth 1 -type d); do \
		if [ -d $$dir/gno-secrets ]; then \
			echo "Executing helm in $$dir"; \
			kubectl apply -k $$dir; \
			helm install $$(basename $$dir) ../helm --values $$dir/values.yaml; \
		fi \
	done

.PHONY: template
template:
	@for dir in $(shell find . -mindepth 1 -maxdepth 1 -type d); do \
		if [ -d $$dir/gno-secrets ]; then \
			echo "Creating helm files in $$dir/out"; \
			helm template $$(basename $$dir) ../helm --output-dir $$dir/out --values $$dir/values.yaml; \
		fi \
	done

.PHONY: clean
clean:
	@for dir in $(shell find . -mindepth 1 -maxdepth 1 -type d); do \
		if [ -d $$dir/gno-secrets ]; then \
			echo "Removing helm output $$dir/out"; \
			rm -rf $$dir/out; \
			echo "Removing helm release"; \
			helm delete $$(basename $$dir); \
			kubectl delete -k $$dir; \
		fi \
	done
