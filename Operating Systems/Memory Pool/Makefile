CXX=gcc ##why we using CXX and perl?
CFLAGS=-Wall -g -fomit-frame-pointer


#-fdefer-pop -fdelayed-branch -fguess-branch-probability -fcprop-registers
# -floop-optimize -fif-conversion -fif-conversion2 -ftree-ccp
#            -ftree-dce -ftree-dominator-opts -ftree-dse -ftree-ter -ftree-lrs
#            -ftree-sra -ftree-copyrename -ftree-fre -ftree-ch -funit-at-a-time
#            -fmerge-constants
#EXTRA_LIB_DIR=../../lib

#PERL=perl
#CXXTEST_DIR=$(EXTRA_LIB_DIR)/cxxtest
#CXXTEST_CFLAGS=-I$(CXXTEST_DIR)/lib/cxxtest
#CXXTEST_GEN=$(PERL) $(CXXTEST_DIR)/cxxtestgen.pl --error-printer

all:	timer packet main_malloc main_mm packet_extra
test:	test_mm
	./test_mm

#
# timer
#

timer:	timer.o mm_public.o
	$(CXX) $(CFLAGS) timer.o mm_public.o -o $@

timer.o:	timer.c
	$(CXX) $(CFLAGS) -c timer.c -o $@


#
# main_malloc
#

main_malloc:	main_malloc.o mm_public.o
	$(CXX) $(CFLAGS) main_malloc.o mm_public.o -o $@

main_malloc.o:	main_malloc.c
	$(CXX) $(CFLAGS) -c main_malloc.c -o $@


#
# main_mm
#

main_mm:	main_mm.o mm_public.o
	$(CXX) $(CFLAGS) main_mm.o mm_public.o -o $@

main_mm.o:	main_mm.c
	$(CXX) $(CFLAGS) -c main_mm.c -o $@


#
# packet
#

packet:	packet_public.o mm_public.o
	$(CXX) $(CFLAGS) -o $@ packet_public.o mm_public.o


packet_public.o:	packet_public.c packet_public.h mm_public.h
	$(CXX) $(CFLAGS) -c packet_public.c -o $@


#
# packet_extra
#

packet_extra:	packet_extra.o mm_public.o
	$(CXX) $(CFLAGS) -o $@ packet_extra.o mm_public.o


packet_extra.o:	packet_extra.c packet_public.h mm_public.h
	$(CXX) $(CFLAGS) -c packet_extra.c -o $@


#
# mm_public
#

mm_public.o:	mm_public.c mm_public.h
	$(CXX) $(CFLAGS) -c mm_public.c -o $@


#
# test
#

test_mm:	test_mm.o
	$(CXX) $(CFLAGS) test_mm.o mm_public.o -o $@

test_mm.o:	test_mm.c mm_public.o
	$(CXX) $(CFLAGS) -c -o $@ test_mm.c





clean:
	rm -rf *.o timer test_mm packet main_malloc main_mm packet_extra
