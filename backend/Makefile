#!make

production:
	rm pokr-backend.tar
	docker build -f docker/Dockerfile -t pokr-backend:latest .
	docker save -o pokr-backend.tar pokr-backend:latest
