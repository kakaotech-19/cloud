# app1/Makefile
APP_NAME=backend
NAMESPACE=default
CHART_PATH=.
VALUES_FILE=values.yaml

deploy:
	@echo "Deploying $(APP_NAME) to namespace $(NAMESPACE)..."
	helm upgrade --install $(APP_NAME) $(CHART_PATH) \
		--namespace $(NAMESPACE) \
		--values $(VALUES_FILE)

status:
	@echo "Checking status for $(APP_NAME)..."
	helm status $(APP_NAME) -n $(NAMESPACE)

upgrade:
	@echo "Upgrading $(APP_NAME)..."
	helm upgrade $(APP_NAME) $(CHART_PATH) \
		--namespace $(NAMESPACE) \
		--values $(VALUES_FILE)

delete:
	@echo "Deleting $(APP_NAME) from namespace $(NAMESPACE)..."
	helm uninstall $(APP_NAME) -n $(NAMESPACE)