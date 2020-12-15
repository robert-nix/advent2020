input%:
	$(eval i := $(shell printf '%d' $*))
	@curl -o $@ -H "Cookie: session=${SESSION_ID}" https://adventofcode.com/2020/day/$i/input

advent%: input%
	cat input$* | mix run priv/$*.exs
