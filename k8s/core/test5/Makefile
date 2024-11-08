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
			echo "To install the chart:"; \
			echo "helm install $$(basename $$dir) ../helm --values $$dir/values.yaml"; \
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

.PHONY: config-adjust
config-adjust:
	@for dir in $(shell find . -mindepth 1 -maxdepth 1 -type d); do \
		if [ -d $$dir/gno-secrets ]; then \
			echo "altering config for $$dir/"; \
			docker run --rm -ti \
				-v "$$dir/config:/gnoroot/gnoland-data/config" \
				--entrypoint sh ghcr.io/gnolang/gno/gnoland:master -c "\
				gnoland config set moniker gnocore-$$(basename $$dir); \
				gnoland config set consensus.timeout_commit 1s; \
				gnoland config set consensus.peer_gossip_sleep_duration 10ms; \
				gnoland config set mempool.size 10000; \
				gnoland config set p2p.max_num_inbound_peers 40; \
				gnoland config set p2p.flush_throttle_timeout 10ms; \
				gnoland config set telemetry.enabled true; \
				gnoland config set telemetry.service_name test5_gnoland; \
				gnoland config set telemetry.service_instance_id gnocore-$$(basename $$dir); \
				gnoland config set telemetry.exporter_endpoint otel-svc:4317; \
			"; \
		fi \
	done
