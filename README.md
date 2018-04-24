# icu-c-java-test

Testing ICU's C vs Java collation compatibility.

It downloads and compiles ICU.

Then it generates collation keys in Java and in C for input files and collations, and compares the results  

### Usage

* Run this to make everything

    
    make
    
    
* Or, run steps one by one

    
    # Fetch and compile ICU4C
    make icu4c
    
    # Compile C test program
    make icu4c-test
    
    # Compile Java test program
    make ICU4JTest.class
    
    # Run tests - if there are any diffs they will show
    make test
    
### Main variables

* `COLLATIONS` - a set of collations used. Note - collations containing `;` need an extra quote, see below
* `TEST_FILE` - the file with inputs

Example:


    TEST_FILE=data/pl.txt \
    COLLATIONS="'pl@colStrength=primary;colCaseLevel=yes' pl@colStrength=primary" \
    make test


### Additional variables

* `CXX` - specify C++ compiler
* `CXX_FLAGS` - specify C++ compiler flags
* `ICU_DIR` - directory containing ICU downloads on ICU servers, e.g. `60.2`
* `ICU_FILE` - the version number in the downloaded files, e.g. `60.2`

