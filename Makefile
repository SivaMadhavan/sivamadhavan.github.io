.PHONY: help dev build clean new-post check

help:
	@echo "Available commands:"
	@echo "  make dev                 Start local development server with live reload"
	@echo "  make build               Build optimized production static site in public/"
	@echo "  make new-post slug=name  Scaffold a new post leaf bundle (e.g. make new-post slug=my-new-post)"
	@echo "  make clean               Remove build artifacts and locks"
	@echo "  make check               Verify Hugo installation and run dry build"

dev:
	hugo server -D --bind 0.0.0.0

build:
	hugo --gc --minify

new-post:
	@if [ -z "$(slug)" ]; then \
		echo "Error: slug argument is required. Usage: make new-post slug=my-post-name"; \
		exit 1; \
	fi
	hugo new content posts/$(slug)/index.md
	@echo "Created content/posts/$(slug)/index.md"

clean:
	rm -rf public resources/_gen .hugo_build.lock
	@echo "Cleaned public/, resources/_gen/, and .hugo_build.lock"

check:
	hugo version
	hugo config
