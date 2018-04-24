.PHONY: test

default: test

CXX ?= g++
CXX_FLAGS ?= -O3

# Which ICU version to use
ICU_DIR ?= 60.2
ICU_FILE ?= 60_2

ICU4J=icu4j-${ICU_FILE}.jar
ICU4C=icu4c-${ICU_FILE}-src.tgz

cache/${ICU4J}:
	mkdir -p cache ; cd cache ; wget http://download.icu-project.org/files/icu4j/${ICU_DIR}/${ICU4J}
cache/${ICU4C}:
	mkdir -p cache ; cd cache ; wget http://download.icu-project.org/files/icu4c/${ICU_DIR}/${ICU4C}

ICU4C_DIR=icu-${ICU_DIR}
# Extra file/target we use to compile icu4c
ICU4C_STATUS=icu4c

COLLATIONS ?= \
	"pl@colStrength=primary;colCaseLevel=yes" \
	pl@colStrength=primary \
	pl@colStrength=secondary \
	pl@colStrength=tertiary \
	pl@colCaseLevel=yes \
	"pl@colStrength=primary;colAlternate=shifted" \
	
TEST_FILE ?= data/test-file.txt

icu4c-test: icu4c-test.cpp ${ICU4C_STATUS}
	${CXX} ${CXX_FLAGS} -Wall --std=c++14 -g $< -o $@ -L ${ICU4C_DIR}/install/lib -I ${ICU4C_DIR}/install/include/ \
		-licuuc -licui18n -licudata
		
ICU4JTest.class: ICU4JTest.java cache/${ICU4J}
	javac -cp .:cache/${ICU4J} $< 2>&1

# Fake target to make sure we only compile C if we have ICU compiled
${ICU4C_STATUS}: cache/${ICU4C}
	rm -rf icu ${ICU4C_DIR}
	tar xf cache/${ICU4C}
	mv icu ${ICU4C_DIR}
	cd ${ICU4C_DIR} ; \
	mkdir build ; \
	cd build ; \
	CXX=${CXX} CXX_FLAGS=${CXX_FLAGS} ../source/configure --prefix=$$PWD/../install && \
	make VERBOSE=1 -j 4 && \
	make install
	touch ${ICU4C_STATUS}

test: icu4c-test ICU4JTest.class
	@rm -rf out ; mkdir -p out
	@for c in ${COLLATIONS} ; do \
		echo -e "\n===================== $$c\n"; \
		java -ea -cp .:cache/${ICU4J} ICU4JTest $$c data/test-data.txt > "out/java-$$c" ; \
		LD_LIBRARY_PATH=${ICU4C_DIR}/install/lib ./icu4c-test $$c data/test-data.txt > "out/c-$$c"; \
		diff -b "out/java-$$c" "out/c-$$c" ; \
	done

clean: 
	rm -rf *.class *.jar *.tgz ${ICU4C_DIR} ${ICU4C_STATUS} icu4c-test *~ out
