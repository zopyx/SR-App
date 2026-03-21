.PHONY: dev build test test-visual test-visual-update

dev:
	npm run tauri:dev

build:
	npm run tauri:build


test:
	npm test

test-visual:
	npm run test:visual

test-visual-update:
	npm run test:visual:update
