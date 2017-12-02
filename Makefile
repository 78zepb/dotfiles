
setup:
	@./setup-mac

backup-atom-packages:
	@apm list --installed --bare > atom-packages.list
