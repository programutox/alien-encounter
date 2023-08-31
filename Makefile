NAME = AlienEncounter

default:
	~/AppImages/love.AppImage .

release:
	zip -9r $(NAME).love assets classes lib *.lua
	rm -rf output
	love.js $(NAME).love output -c -t $(NAME)