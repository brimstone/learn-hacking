.PHONY: serve
serve:
	hugo serve --baseURL http://localhost:1313/ --navigateToChanged --minify --verboseLog --log --verbose

.PHONY: build
build:
	hugo --cleanDestinationDir
	tree public
	du -hs public

.PHONY: clean
clean:
	-rm -rf public
