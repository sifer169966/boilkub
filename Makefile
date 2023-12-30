dest?="."

get:
	./bin/boilkub.sh config get-contexts

set:
	./bin/boilkub.sh config set-context $(name) --project-url=$(url)

use:
	./bin/boilkub.sh config use-context $(name)

apply:
	./bin/boilkub.sh appl -y -d $(dest)