
all:bin

_version=1.3.0

.PHONY:
bin:
	tar zcf src.tar.gz src/	
	cat run_log_tool.sh src.tar.gz >log-collect-$(_version).bin
	rm -rf src.tar.gz
	chmod a+x log-collect-$(_version).bin

.PHONY:
clean:
	rm -rf src.tar.gz
	rm -rf *.bin
