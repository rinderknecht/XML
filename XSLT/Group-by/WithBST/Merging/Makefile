#-*- makefile -*-

TARGETS := cities.html tab.html

parts: ${TARGETS}

%.html: %.xml tab.xsl
	echo -n "Making $@ from $<..."
	java -jar ~/bin/saxon.jar -o $@ $^
	if test $$? -eq 0; then echo " done."; else " FAILED."; fi

clean::
	\rm --force ${TARGETS}

%: ;
