# This Makefile was generated by the Cake3
# https://github.com/grwlf/cake3

GUARD = .cake3/GUARD_$(1)_$(shell echo $($(1)) | md5sum | cut -d ' ' -f 1)

ifdef MAIN

# Main section

URVERSION = $(shell urweb -version)
.PHONY: all
all: ./Pastebin.db ./Pastebin.exe ./Pastebin.sql
.PHONY: clean
clean: 
	rm -rf .cake3 ./Pastebin.sql ./Pastebin.exe
./Pastebin.db: ./Pastebin.exe ./Pastebin.sql
	-rm ./Pastebin.db
	touch ./Pastebin.db
	sqlite3 ./Pastebin.db < ./Pastebin.sql
./Pastebin.exe: .fix-multy1
./Pastebin.urp: ./Pastebin.urp.in
	cat ./Pastebin.urp.in > ./Pastebin.urp
./Pastebin.urp.in: ./../uru/lib.urp ./../urweb-callback/lib.urp ./Cb.ur ./Cb.urs ./Job.ur ./Job.urs ./Job2.ur ./Job2.urs ./Job3.ur ./Job3.urs ./Pastebin.ur ./Pastebin.urs
	touch ./Pastebin.urp.in
./Pastebin.sql: .fix-multy1
.INTERMEDIATE: .fix-multy1
.fix-multy1: ./Pastebin.urp $(call GUARD,URVERSION)
	urweb -dbms sqlite ./Pastebin
$(call GUARD,URVERSION):
	rm -f .cake3/GUARD_URVERSION_*
	touch $@

else

# Prebuild/postbuild section

.PHONY: all
all: .fix-multy1
.PHONY: clean
clean: .fix-multy1
.PHONY: ./Pastebin.db
./Pastebin.db: .fix-multy1
.PHONY: ./Pastebin.exe
./Pastebin.exe: .fix-multy1
.PHONY: ./Pastebin.urp
./Pastebin.urp: .fix-multy1
.PHONY: ./Pastebin.urp.in
./Pastebin.urp.in: .fix-multy1
.PHONY: ./Pastebin.sql
./Pastebin.sql: .fix-multy1
.INTERMEDIATE: .fix-multy1
.fix-multy1: 
	-mkdir .cake3
	$(MAKE) -C ./../urweb-callback -f Makefile
	$(MAKE) -C ./../uru -f Makefile
	$(MAKE) -f ./Makefile MAIN=1 $(MAKECMDGOALS)

endif
