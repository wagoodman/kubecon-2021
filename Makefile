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
		-p git-repo-ref=bfda665e81023bf46b296c9c179f8818f5dce190 || true

	# # let's get an example of the app failing due to a secrets (tag 2-remediate-nltk)
	# tkn pipeline start build-and-validate \
	# 	$(RUN_PARAMS) \
	# 	--showlog \
	# 	-p git-repo-ref=46744628d2e63cb0ba7e810488549c39e2d517a5 || true

	# let's get a passing build (tag 3-remediate-secret-leak)
	tkn pipeline start build-and-validate \
		$(RUN_PARAMS) \
		--showlog \
		-p git-repo-ref=4f5e6e4a05a2134ffbcb6e4802c72bc301594ebe

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