

#$(INSTALLPATH): 
#	@echo "INSTALLPATH does not exist"
#	if [ ! -d "$(INSTALLPATH)" ]; then echo "$(INSTALLPATH) does not exists"; mkdir -p $@; fi


install: #$(INSTALLPATH)
	@clear
	INSTALLPATH ?= $(shell bash -c 'read -p "Installation Path: " installpath; echo $$installpath')
	mkdir -p $@
	cp -r ./SHELL $@/

hello:	
	echo "Hello!"
	
help: # HeaderTemplate.txt
	cat HeaderTemplate.txt

NewTestArea:
	echo "Here we go";
	./SHELL/CreateNewTestArea.sh
	
NewTestSeries:
	./SHELL/CreateNewTestSeries.sh

NewTestEquipment:
	./SHELL/CreateNewTestEquipment.sh
	
	
