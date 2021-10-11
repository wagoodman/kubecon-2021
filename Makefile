RUN_PARAMS= -w name=share,volumeClaimTemplateFile=resources/pvc.yaml \
			--serviceaccount=build-bot \
			-p git-repo-url=https://github.com/wagoodman/count-goober \
			-p image-name=ghcr.io/wagoodman/count-goober \
			-p dockerfile-path=Dockerfile

.PHONY: run
run:
	tkn pipeline start build-and-validate $(RUN_PARAMS) -p git-repo-ref=main

.PHONY: run-all-scenarios
run-all-scenarios:
	# let's get an example of the app failing due to a vulnerability quality gate + secrets problem (tag 1-before-remediation)
	tkn pipeline start build-and-validate \
		$(RUN_PARAMS) \
		--showlog \
		-p git-repo-ref=12c3dfaa6cef62f39b95d7ef7e845644ab397477 || true

	# let's get a passing build (tag 2-after-remediation)
	tkn pipeline start build-and-validate \
		$(RUN_PARAMS) \
		--showlog \
		-p git-repo-ref=c3067e40f18c8c94003acfc6fe8ec31a1c91af8f

.PHONY: install-tekton
install-tekton:
	kubectl apply --filename https://storage.googleapis.com/tekton-releases-nightly/pipeline/latest/release.yaml
	kubectl apply --filename https://storage.googleapis.com/tekton-releases-nightly/dashboard/latest/tekton-dashboard-release.yaml


.PHONY: uninstall-tekton
uninstall-tekton:
	kubectl delete --filename https://storage.googleapis.com/tekton-releases-nightly/dashboard/latest/tekton-dashboard-release.yaml
	kubectl delete --filename https://storage.googleapis.com/tekton-releases-nightly/pipeline/latest/release.yaml


.PHONY: install
install: install-image-cache-pvc install-service-account install-fake-secret install-tasks install-pipelines

.PHONY: install-tasks
install-tasks: install-external-tasks install-local-tasks

.PHONY: install-fake-secret
install-fake-secret:
	# this isn't a real secret, we just need dummy data
	@kubectl create secret generic asset-token \
	--from-literal=username=devuser \
	--from-literal=token='12345A7a901b345678901234567890123456789012345678901234567890' || true

.PHONY: install-image-cache-pvc
install-image-cache-pvc:
	./scripts/install-image-cache-pvc.sh

.PHONY: install-service-account
install-service-account:
	./scripts/install-service-account.sh

.PHONY: install-external-tasks
install-external-tasks:
	./scripts/install-external-tasks.sh

.PHONY: install-local-tasks
install-local-tasks:
	./scripts/install-local-tasks.sh

.PHONY: install-pipelines
install-pipelines:
	./scripts/install-pipelines.sh