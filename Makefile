####################################################################################
# Makefile (configuration file for GNU make - see http://www.gnu.org/software/make/)
#
# --------------------------------------------------------------------------------
# This is a generic makefile in the sense that it doesn't require to be 
# modified when adding/removing new source files.
# --------------------------------------------------------------------------------
#
# Author: Sebastien Varrette <Sebastien.Varrette@uni.lu>
#          Web page : http://www-id.imag.fr/~svarrett/
# Version : 1.2
# Creation date : 2012-07-24
#
# Compilation of files written in LaTeX
#
# This makefile search for LaTeX sources from the current directory, identifies 
# the main files (i.e the one containing the sequence '\begin{document}') and 
# launch the compilation for the generation of PDFs and optionnaly compressed 
# Postscript files. 
# Two compilation modes can be configured using the USE_PDFLATEX variable:
#    1/ Rely on pdflatex to generate directly a pdfs from the LaTeX sources. 
#       The compilation follow then the scheme: 
#
#                main.tex --[pdflatex/bibtex]--> main.pdf + main.[aux|log etc.]
#
#       Note that in that case, your figures should be in pdf format instead of eps.
#       To use this mode, just set the USE_PDFLATEX variable to 'yes'
# 
#    2/ Respect the classical scheme:                             +-[dvips]-> main.ps
#                                                                 |             |             
#                                                                 |        +-[gzip]
#       main.tex -[latex/bibtex]-> main.dvi + main.[aux|log etc.]-+        |     
#                                                                 |        +-> main.ps.gz     
#                                                                 +-[dvipdf]-> main.pdf
#       To use this mode, just set the USE_PDFLATEX variable to 'no'
# In all cases: 
#   - all the intermediate files (main.aux, main.log etc.) will be moved
#     to $(TRASH_DIR)/ (if it exists). 
#   - the dvi file (generated if pdflatex is not used) will stay in the current directory.  
#   - other target files (pdfs + compressed Postscript files if pdflatex is not used)
#     are moved to the $(OUTPUT_DIR) directory. 
#     Note that this directory is automatically created if $(OUTPUT_DIR) differs from '.'
#
# Available Commands  
# ------------------
# make       : Compile LaTeX files, generated files (pdf etc.) are placed in $(OUTPUT_DIR)/ 
# make force : Force re-compilation, even if not needed 
# make clean : Remove all generated files 
# make rtf :   Generate an RTF file using latex2rtf
# make html  : generate HTML files from tex in $(HTML_DIR)/ (using latex2html)
#                  The directory is created on the first invocation
# make help      : print help message 
#
############################## Variables Declarations ##############################
SHELL = /bin/bash

# set to 'yes' to use pdflatex for the direct generation of pdf from LaTeX sources
# set to 'no' to use the classical scheme tex -> dvi -> [ps|pdf] by dvips
USE_PDFLATEX = yes

# Directory where PDF, Postcript files and other generated files will be placed
# /!\ Please ensure there is no trailing space after the values
OUTPUT_DIR = .
TRASH_DIR  = .Trash
HTML_DIR   = $(OUTPUT_DIR)/HTML
# Check avalibility of source files
TEX_SRC    = $(wildcard *.tex)
ifeq ($(TEX_SRC),)
all:
	@echo "No source files available - I can't handle the compilation"
	@echo "Please check the presence of source files (with .tex extension)"
else
# Main tex file and figures it may depend on 
MAIN_TEX   = Tutorial_Latex.tex
FIGURES    = $(shell find . -name "*.eps" -o -name "*.fig" | xargs echo)
ifeq ($(MAIN_TEX),)
all:
	@echo "I can't find any .tex file with a '\begin{document}' directive "\
		"among $(TEX_SRC). Please define a main tex file!"
else
# Commands used during compilation
LATEX        = $(shell which latex)
PDFLATEX     = $(shell which pdflatex)
LATEX2HTML   = $(shell which latex2html)
BIBTEX       = $(shell which bibtex)
DVIPS        = $(shell which dvips)
DVIPDF       = $(shell which dvipdf)
GZIP         = $(shell which gzip)
LATEX2RTF    = $(shell which latex2rtf)
# Generated files
DVI    	     = $(MAIN_TEX:%.tex=%.dvi)
PS           = $(MAIN_TEX:%.tex=%.ps)
PS_GZ        = $(MAIN_TEX:%.tex=%.ps.gz)
PDF          = $(MAIN_TEX:%.tex=%.pdf)
RTF          = $(MAIN_TEX:%.tex=%.rtf)
TARGET_PDF   = $(PDF)   
TARGET_PS_GZ = $(PS_GZ) 
ifneq ($(OUTPUT_DIR),.)
TARGET_PDF   = $(PDF:%=$(OUTPUT_DIR)/%)
TARGET_PS_GZ = $(PS_GZ:%=$(OUTPUT_DIR)/%) 
endif
TARGETS      = $(DVI) $(TARGET_PDF) $(TARGET_PS_GZ)
BACKUP_FILES = $(shell find . -name "*~")
# Files to move to $(TRASH_DIR) after compilation
# Never add *.tex (or any reference to source files) for this variable.
TO_MOVE      = *.aux *.log *.toc *.lof *.lot *.bbl *.blg *.out

# Git stuff management
LAST_TAG_COMMIT = $(shell git rev-list --tags --max-count=1)
LAST_TAG = $(shell git describe --tags $(LAST_TAG_COMMIT) )
TAG_PREFIX = "latex-tutorial-v"

BUILD_VERSION = $(shell git log --oneline | wc -l | xargs echo)  # total number of commits 
VERSION  = $(shell head VERSION)
#VERSION = '0.6.6-b18'
# OR try to guess directly from the last git tag
# VERSION  = $(shell  git describe --tags $(LAST_TAG_COMMIT) | sed "s/^latex-tutorial-v//")
MAJOR      = $(shell echo $(VERSION) | sed "s/^\([0-9]*\).*/\1/")
MINOR      = $(shell echo $(VERSION) | sed "s/[0-9]*\.\([0-9]*\).*/\1/")
PATCH      = $(shell echo $(VERSION) | sed "s/[0-9]*\.[0-9]*\.\([0-9]*\).*/\1/")
#REVISION   = $(shell git rev-list $(LAST_TAG).. --count)
#ROOTDIR    = $(shell git rev-parse --show-toplevel)
NEXT_MAJOR_VERSION = "$(shell expr $(MAJOR) + 1).0.0-b$(BUILD_VERSION)"
NEXT_MINOR_VERSION = "$(MAJOR).$(shell expr $(MINOR) + 1).0-b$(BUILD_VERSION)"
NEXT_PATCH_VERSION = "$(MAJOR).$(MINOR).$(shell expr $(PATCH) + 1)-b$(BUILD_VERSION)"


############################### Now starting rules ################################
# Required rule : what's to be done each time 
all: $(TARGET_PDF)

versioninfo:
	@echo "Current version: $(VERSION) (major: $(MAJOR), minor: $(MINOR), patch: $(PATCH) )"
	@echo "Last tag: $(LAST_TAG)"
	@echo "Revision: $(REVISION) (number of commits since last tag)"
	@echo "Build: $(BUILD_VERSION) (total number of commits)"
	@echo "next major version: $(NEXT_MAJOR_VERSION)"
	@echo "next minor version: $(NEXT_MINOR_VERSION)"
	@echo "next patch version: $(NEXT_PATCH_VERSION)"

# Git flow management 
start_bump_patch:
	@echo "Start the patch release of the repository from $(VERSION) to $(NEXT_PATCH_VERSION)"
	git pull origin
	git flow release start $(NEXT_PATCH_VERSION)
	@echo $(NEXT_PATCH_VERSION) > VERSION
	git commit -s -m "Patch bump to version $(NEXT_PATCH_VERSION)" VERSION

# git pull origin
# git flow feature start "bump_to_$(MAJOR).$(MINOR).$(REVISION)"
# @echo "$(MAJOR).$(MINOR).$(REVISION)" > VERSION
# git commit -s -m "Patch bump to version $(MAJOR).$(MINOR).$(REVISION)" VERSION
# @echo "Run 'make release' once you finished the patching"

# release: 
# 	git flow feature finish "bump_to_$(VERSION)"

# Dvi files generation
dvi $(DVI) : $(TEX_SRC) $(FIGURES)
	@echo "==> Now generating $(DVI)"
	@for f in $(MAIN_TEX); do                                    \
	   $(LATEX) $$f;                                             \
	   bib=`grep "^[\]bibliography{" $$f|sed -e "s/^[\]bibliography{\(.*\)}/\1/"|tr "," " "`;\
	   if [ ! -z "$$bib" ]; then                                 \
	  	echo "==> Now running BibTeX ($$bib used in $$f)";   \
		$(BIBTEX) `basename $$f .tex`;                       \
		$(LATEX) $$f;                                        \
	   fi;                                                       \
	   $(LATEX) $$f;                                             \
	   $(MAKE) move_to_trash;                                    \
	done
	@echo "==> $(DVI) generated"

# Compressed Postscript generation 
ps $(PS) $(TARGET_PS_GZ) : $(DVI)
	@for dvi in $(DVI); do                                \
	   	ps=`basename $$dvi .dvi`.ps;                  \
	   	echo "==> Now generating $$ps.gz from $$dvi"; \
	  	$(DVIPS) -q -o $$ps $$dvi;                    \
	   	$(GZIP) -f $$ps;                              \
	done
	@if [ "$(OUTPUT_DIR)" != "." ]; then                        \
		$(MAKE) create_output_dir;                           \
		for ps in $(PS); do                                 \
			echo "==> Now moving $$ps.gz to $(OUTPUT_DIR)/"; \
			mv $$ps.gz $(OUTPUT_DIR);                   \
		done;                                               \
	fi

###################### The following part is specific for the case where pdflatex is used ######################
ifeq ("$(USE_PDFLATEX)", "yes")
pdflatex $(TARGET_PDF): $(TEX_SRC) $(FIGURES)
	@echo "==> Now generating $(PDF)"
	@for f in $(MAIN_TEX); do                                    \
	   $(PDFLATEX) $$f;                                             \
	   bib=`grep "^[\]bibliography{" $$f|sed -e "s/^[\]bibliography{\(.*\)}/\1/"|tr "," " "`;\
	   if [ ! -z "$$bib" ]; then                                 \
	  	echo "==> Now running BibTeX ($$bib used in $$f)";   \
		$(BIBTEX) `basename $$f .tex`;                       \
		$(PDFLATEX) $$f;                                             \
	   fi;                                                       \
	   $(PDFLATEX) $$f;                                          \
	   $(MAKE) move_to_trash;                                    \
	done
	@if [ "$(OUTPUT_DIR)" != "." ]; then                         \
		$(MAKE) create_output_dir;                           \
		for pdf in $(PDF); do                                \
			echo "==> Now moving $$pdf to $(OUTPUT_DIR)/"; \
			mv $$pdf $(OUTPUT_DIR);                      \
		done;                                                \
	fi
	@$(MAKE) help

###################### End of specific case where pdflatex is used ######################
else 
pdf $(TARGET_PDF): $(DVI)
	@for dvi in $(DVI); do                                \
	   	ps=`basename $$dvi .dvi`.pdf;                 \
	   	echo "==> Now generating $$pdf from $$dvi";   \
	  	$(DVIPDF) $$dvi;                              \
	done
	$(MAKE) create_output_dir           	     
	@if [ "$(OUTPUT_DIR)" != "." ]; then                             \
		for pdf in $(PDF); do                                    \
			echo "==> Now moving $$pdf to $(OUTPUT_DIR)/";   \
			mv $$pdf $(OUTPUT_DIR);                          \
		done;                                                    \
	fi
	@$(MAKE) help
endif
###################### End of specific case where pdflatex is NOT used ######################

TO_TRASH=$(shell ls $(TO_MOVE) 2>/dev/null | xargs echo)
move_to_trash:
	@if [ ! -z "${TO_TRASH}" -a -d $(TRASH_DIR) -a "$(TRASH_DIR)" != "." ]; then  \
                echo "==> Now moving ${TO_TRASH} to $(TRASH_DIR)/";                   \
                mv -f ${TO_TRASH} $(TRASH_DIR)/;                                      \
        elif [ ! -d $(TRASH_DIR) ]; then                             \
                echo "*** /!\ The trah directory $(TRASH_DIR)/ does not exist!!!";       \
                echo "***     May be you should create it to hide the files ${TO_TRASH}";\
        fi;   

create_output_dir: 
	@if [ ! -d $(OUTPUT_DIR) ]; then                                                  \
		echo "    /!\ $(OUTPUT_DIR)/ does not exist ==> Now creating ./$(OUTPUT_DIR)/"; \
		mkdir -p ./$(OUTPUT_DIR);                                                 \
	fi;  


# Clean option
clean:
	rm -f *.dvi $(RTF) $(TO_MOVE) $(BACKUP_FILES)
	@if [ ! -z "$(OUTPUT_DIR)" -a -d $(OUTPUT_DIR) -a "$(OUTPUT_DIR)" != "." ]; then       \
	   for f in $(MAIN_TEX); do                                  \
		base=`basename $$f .tex`;                            \
		echo "==> Now cleaning $(OUTPUT_DIR)/$$base*";       \
		rm -rf $(OUTPUT_DIR)/$$base*;                        \
           done                                                      \
	fi
	@if [ "$(OUTPUT_DIR)" == "." ]; then                         \
	   for f in $(MAIN_TEX); do                                  \
		base=`basename $$f .tex`;                            \
		echo "==> Now cleaning $$base.ps.gz and $$base.pdf"; \
		rm -rf $$base.ps.gz $$base.pdf;                	     \
	   done							     \
	fi
	@if [ ! -z "$(TRASH_DIR)" -a -d $(TRASH_DIR)  -a "$(TRASH_DIR)" != "." ];   then       \
	   for f in $(MAIN_TEX); do                                  \
		base=`basename $$f .tex`;                            \
		echo "==> Now cleaning $(TRASH_DIR)/$$base*";        \
		rm -rf $(TRASH_DIR)/$$base*;                         \
	   done                                                      \
	fi
	@if [ ! -z "$(HTML_DIR)" -a -d $(HTML_DIR) -a "$(HTML_DIR)" != "." ]; then       \
	   echo "==> Now removing $(HTML_DIR)";                      \
	   rm  -rf $(HTML_DIR);                                      \
	fi

# force recompilation
force :
	@touch $(MAIN_TEX)
	@$(MAKE)

# Test values of variables - for debug purpose  
test:
	@echo "USE_PDFLATEX: $(USE_PDFLATEX)"
	@echo "--- Directories --- "
	@echo "OUTPUT_DIR -> $(OUTPUT_DIR)"
	@echo "TRASH_DIR  -> $(TRASH_DIR)"
	@echo "HTML_DIR   -> $(HTML_DIR)"
	@echo "--- Compilation commands --- "
	@echo "PDFLATEX   -> $(PDFLATEX)"
	@echo "LATEX      -> $(LATEX)"
	@echo "LATEX2HTML -> $(LATEX2HTML)"
	@echo "LATEX2RTF  -> $(LATEX2RTF)"
	@echo "BIBTEX     -> $(BIBTEX)"
	@echo "DVIPS      -> $(DVIPS)"
	@echo "DVIPDF     -> $(DVIPDF)"
	@echo "GZIP       -> $(GZIP)"
	@echo "--- Files --- "
	@echo "TEX_SRC    -> $(TEX_SRC)"
	@echo "MAIN_TEX   -> $(MAIN_TEX)"
	@echo "FIGURES    -> $(FIGURES)"
	@echo "BIB_FILES  -> $(BIB_FILES)"
	@echo "DVI        -> $(DVI)"
	@echo "PS         -> $(PS)"
	@echo "PS_GZ      -> $(PS_GZ)"
	@echo "PDF        -> $(PDF)"
	@echo "TO_MOVE    -> $(TO_MOVE)"
	@echo "TARGET_PS_GZ -> $(TARGET_PS_GZ)"
	@echo "TARGET_PDF   -> $(TARGET_PDF)"
	@echo "TARGETS      -> $(TARGETS)"
	@echo "BACKUP_FILES -> $(BACKUP_FILES)"

# print help message
help :
	@echo '+---------------------------------------------------------------+'
	@echo '|                        Available Commands                     |'
	@echo '+------------+--------------------------------------------------+'
	@echo '| make       | Compile LaTeX files.                             |'
	@echo '|            | Generated files (pdf etc.) are placed in $(OUTPUT_DIR)/ '
	@echo '| make force | Force re-compilation, even if not needed         |'
	@echo '| make clean | Remove all generated files                       |'
	@echo '| make html  | Generate HTML files from TeX in $(HTML_DIR)/     '
	@echo '| make help  | Print help message                               |'
	@echo '+------------+--------------------------------------------------+'

# RTF generation using latex2rtf
rtf $(RTF): $(TARGET_PDF)
ifeq ($(LATEX2RTF),)
	@echo "Please install latex2rtf to use this option!"
else
	@echo "==> Now generating $(RTF)"
	-cp $(TRASH_DIR)/*.aux $(TRASH_DIR)/*.bbl .
	@for f in $(MAIN_TEX); do    \
	   $(LATEX2RTF) -i english $$f;  \
	done
	@$(MAKE) move_to_trash
	@echo "==> $(RTF) is now generated"
	@$(MAKE) help
endif


# HTML pages generation using latex2html
# First check that $(LATEX2HTML) and $(HTML_DIR)/ exist
html :
ifeq ($(LATEX2HTML),)
	@echo "Please install latex2html to use this option!"
	@echo "('apt-get install latex2html' under Debian)"
else
	@if [ ! -d ./$(HTML_DIR) ]; then                                    \
	   echo "$(HTML_DIR)/ does not exist => Now creating $(HTML_DIR)/"; \
	   mkdir -p ./$(HTML_DIR);                                          \
	fi
	-cp $(TRASH_DIR)/*.aux $(TRASH_DIR)/*.bbl .
	$(LATEX2HTML) -show_section_numbers -local_icons -split +1 \
		-dir $(HTML_DIR) $(MAIN_TEX)
	@rm -f *.aux *.bbl $(HTML_DIR)/*.tex $(HTML_DIR)/*.aux $(HTML_DIR)/*.bbl
	@echo "==> HTML files generated in $(HTML_DIR)/" 
	@echo "May be you can try to execute 'mozilla ./$(HTML_DIR)/index.html'"
endif
endif
endif
