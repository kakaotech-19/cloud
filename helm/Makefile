# project-root/Makefile
APPS = ingress backend frontend ai-text ai-image ai-music

# 모든 애플리케이션을 배포
deploy-all:
	@for app in $(APPS); do \
		echo "Deploying $$app..."; \
		make -C $$app deploy; \
	done

# 모든 애플리케이션 상태 확인
status-all:
	@for app in $(APPS); do \
		echo "Checking status for $$app..."; \
		make -C $$app status; \
	done

# 모든 애플리케이션 업그레이드
upgrade-all:
	@for app in $(APPS); do \
		echo "Upgrading $$app..."; \
		make -C $$app upgrade; \
	done

# 모든 애플리케이션 삭제
delete-all:
	@for app in $(APPS); do \
		echo "Deleting $$app..."; \
		make -C $$app delete; \
	done

# 개별 애플리케이션 작업을 위한 기본 명령어
deploy/%:
	@make -C $* deploy

status/%:
	@make -C $* status

upgrade/%:
	@make -C $* upgrade

delete/%:
	@make -C $* delete

ingress:
	@echo "Deploying ingress"
	helm install ingress-nginx ingress-nginx/ingress-nginx --namespace default
