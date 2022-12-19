#!make

deploy:
	mix deps.clean --unlock --unused
	mix deps.get --only prod
	MIX_ENV=prod mix compile
	MIX_ENV=prod mix phx.gen.release
	yes | MIX_ENV=prod mix release
