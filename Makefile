GODOT ?= godot

.PHONY: test run build-web serve

test:
	$(GODOT) --headless --path . --run res://tests/TestRunner.tscn

run:
	$(GODOT) --path .

build-web:
	@mkdir -p build/web 2>/dev/null || powershell -NoProfile -Command "New-Item -ItemType Directory -Force -Path build/web > $null"
	$(GODOT) --headless --path . --export-release "Web" build/web/index.html

serve:
	python -m http.server 8000 --directory build/web
