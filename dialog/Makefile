run: build
	./run.sh

stop:
	docker rm -f dialog

restart: stop run

build:
	docker build -t dialog:latest .


