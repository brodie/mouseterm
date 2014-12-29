CC=gcc
LD=$(CC)

ARCH=
ARCHES=$(foreach arch,$(ARCH),-arch $(arch))
OSXVER=10.5
OSXVER64=10.5
ifneq ($(OSXVER),$(OSXVER64))
ARCHES+=-Xarch_x86_64 -mmacosx-version-min=$(OSXVER64)
endif

OPTLEVEL=2
CFLAGS+=-std=c99 -O$(OPTLEVEL) -Wall -mmacosx-version-min=$(OSXVER) $(ARCHES)
LDFLAGS+=-bundle -framework Cocoa

OBJS=JRSwizzle.o MouseTerm.m MTAppPrefsController.o MTParser.o \
	MTProfile.o MTShell.o MTTabController.o MTView.o
NAME=MouseTerm
BUNDLE=$(NAME).bundle
DMG=$(NAME).dmg
TARGET=$(BUNDLE)/Contents/MacOS/$(NAME)
DMGFILES=$(BUNDLE) LICENSE.txt
SIMBLDIR=$(HOME)/Library/Application\ Support/SIMBL/Plugins
TERMINALAPP=/Applications/Utilities/Terminal.app/Contents/MacOS/Terminal

default: all
%.o: %.m
	$(CC) -c $(CFLAGS) $< -o $@
$(TARGET): $(OBJS)
	mkdir -p $(BUNDLE)/Contents/MacOS
	$(LD) $(CFLAGS) $(LDFLAGS) -o $@ $^
	cp Info.plist $(BUNDLE)/Contents
	mkdir -p $(BUNDLE)/Contents/Resources
	cp -R *.lproj $(BUNDLE)/Contents/Resources
	rm -f $(BUNDLE)/Contents/Resources/English.lproj/*.xib
	ibtool --errors --warnings --notices \
		--output-format human-readable-text --compile \
		$(BUNDLE)/Contents/Resources/English.lproj/Configuration.nib \
		English.lproj/Configuration.xib
all: $(TARGET)

dist: $(TARGET)
	rm -rf $(NAME) $(DMG)
	mkdir $(NAME)
	osacompile -o $(NAME)/Install.app Install.scpt
	osacompile -o $(NAME)/Uninstall.app Uninstall.scpt
	cp -R $(DMGFILES) $(NAME)
	cp README.md $(NAME)/README.txt
	hdiutil create -fs HFS+ -imagekey zlib-level=9 -srcfolder $(NAME) \
		-volname $(NAME) $(DMG)
	rm -rf $(NAME)
clean:
	rm -f *.o
	rm -rf $(BUNDLE) $(NAME)
	rm -f $(DMG) Terminal.classdump Terminal.otx
install: $(TARGET)
	mkdir -p $(SIMBLDIR)
	rm -rf $(SIMBLDIR)/$(BUNDLE)
	cp -R $(BUNDLE) $(SIMBLDIR)
test: install
	$(TERMINALAPP)

classdump:
	class-dump $(TERMINALAPP) > Terminal.classdump
otx:
	otx $(TERMINALAPP) > Terminal.otx

.PHONY: all dist clean install test classdump otx
