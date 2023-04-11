mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
my_iparent_path := $(notdir $(shell pwd))
sub_dir := .

SHELL:=/bin/bash
.ONESHELL:
#.SHELLFLAGS=

#source
HTML_SRC=$(shell find ./ -type d \( \
		 -name .md5 -o \
		 -name .stensal_extracted -o \
		 -name .stensal_included -o \
		 -name .deployment -o \
		 -name .stensal_instantiated -o \
		 -name .stensal_dependency \
		 \) -prune -o -name "*.html" -print)

# extract template/fragement
HTML_EXTRACTED=$(patsubst ./%.html, .stensal_extracted/$(my_iparent_path)/%.html, $(HTML_SRC))

# include template/fragement
HTML_INCLUDED=$(patsubst ./%.html, .stensal_included/$(my_iparent_path)/%.html, $(HTML_SRC))

# instantiate ..
HTML_INSTANTIATED=$(patsubst ./%.html, .stensal_instantiated/$(my_iparent_path)/%.html, $(HTML_SRC))

# extract ids
HTML_IDED=$(HTML_INSTANTIATED:%.html=%.jsid)

HTML_DEPLOYED=$(patsubst ./%.html, .deployment/$(my_iparent_path)/%.html, $(HTML_SRC))


.stensal_extracted/$(my_iparent_path)/%.html:%.html
	main_extract_template -i $< -o $(shell dirname $@) -b $(basename $(notdir $@))
	@if [ -f $(mkfile_dir).stensal_dependency/$(my_iparent_path)/$< ]; then
		while IFS='' read -r line; do
			touch $$line;
		done < $(mkfile_dir).stensal_dependency/$(my_iparent_path)/$<
	fi


.stensal_included/$(my_iparent_path)/%.html:%.html
	main_html_include -d $(mkfile_dir).stensal_dependency/$(my_iparent_path) \
	                  -m /$(my_iparent_path)=$(mkfile_dir).stensal_extracted/$(my_iparent_path) \
	                  -i $< -o $@

.stensal_instantiated/$(my_iparent_path)/%.html:%.html
	main_html_instantiate -i .stensal_included/$(my_iparent_path)/$(shell dirname $<)/$(notdir $<) \
	                      -o $(shell dirname $@)/$(basename $(notdir $@)).html

.stensal_instantiated/$(my_iparent_path)/%.jsid:%.html
	main_extract_ids -i .stensal_instantiated/$(my_iparent_path)/$(shell dirname $<)/$(basename $(notdir $<)).html \
			 -o $(shell dirname $@)/$(basename $(notdir $@)).jsid
	main_extract_id_prefix -i .stensal_instantiated/$(my_iparent_path)/$(shell dirname $<)/$(basename $(notdir $<)).html \
			       -a $(shell dirname $@)/$(basename $(notdir $@)).jsid

.deployment/$(my_iparent_path)/%.html:%.html
	main_html_merge -i .stensal_instantiated/$(my_iparent_path)/$(shell dirname $<)/$(notdir $<) \
			-j .stensal_instantiated/$(my_iparent_path)/$(shell dirname $<)/$(basename $(notdir $<)).jsid \
			-o $(shell dirname $@)/$(basename $(notdir $@)).html


extract: $(HTML_EXTRACTED)

include: $(HTML_INCLUDED)

instantiate: $(HTML_INSTANTIATED)

id: $(HTML_IDED)

merge: $(HTML_DEPLOYED)

merge: $(HTML_DEPLOYED)

all: sync_files extract include instantiate id merge

build: extract include instantiate id merge

list_src:
	echo $(HTML_SRC)

extracted:
	echo $(HTML_EXTRACTED)

included:
	echo $(HTML_INCLUDED)

instantiated:
	echo $(HTML_INSTANTIATED)

ided:
	echo $(HTML_IDED)

merged:
	echo $(HTML_DEPLOYED)


sync_files:
	echo $(mkfile_dir) $(sub_dir)
	sync_files -r $(mkfile_dir) -p $(sub_dir)

clean:
	rm -f $(HTML_EXTRACTED)
	rm -f $(HTML_INCLUDED)
	rm -f $(HTML_INSTANTIATED)
	rm -f $(HTML_IDED)
	rm -f $(HTML_DEPLOYED)
	rm -rf $(mkfile_dir).md5
	rm -rf $(mkfile_dir).deployment
	rm -rf $(mkfile_dir).stensal_extracted
	rm -rf $(mkfile_dir).stensal_included
	rm -rf $(mkfile_dir).stensal_instantiated
	rm -rf $(mkfile_dir).stensal_dependency

clean_ided:
	rm -f $(HTML_IDED)

my_iparent_path:
	echo $(my_iparent_path)
