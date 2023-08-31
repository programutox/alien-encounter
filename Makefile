NAME = AlienEncounter

default:
	~/AppImages/love.AppImage .

release:
	zip -9 -r $(NAME).love assets classes lib *.lua
	rm -rf output
	love.js $(NAME).love output -c

testweb:
	cd output
	python3 -m http.server