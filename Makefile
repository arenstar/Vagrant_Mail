.PHONY: install
run:
	puppet apply --modulepath=/etc/puppet/modules -v --show_diff ./puppet/setup.pp
