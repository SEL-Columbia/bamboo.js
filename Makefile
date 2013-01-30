GLOBAL_COFFEE	=		$(shell which coffee)
LOCAL_COFFEE	=		./node_modules/coffee-script/bin/coffee
COFFEE				:=	$(shell if [[ -f index.html ]]; then echo $(GLOBAL_COFFEE); else echo $(LOCAL_COFFEE); fi;)

watch:
	${COFFEE} -w -o ./lib -c ./src

build:
	${COFFEE} -o ./lib -c ./src
