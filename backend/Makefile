#!make

deploy:
	mix deps.clean --unlock --unused
	mix deps.get --only prod
	env MIX_ENV=prod mix compile
	yes | env MIX_ENV=prod mix release
