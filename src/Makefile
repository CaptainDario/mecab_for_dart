CC = clang
CXX = clang++
LINK = clang++

CFLAGS = -O2 -std=c++11 -Wall -Wextra
LDFLAGS = 
DEFS = -DMECAB_USE_THREAD \
       -DDLL_EXPORT -DHAVE_GETENV -DHAVE_UNISTD_H -DDIC_VERSION=102 \
       -DVERSION="\"0.996\"" -DPACKAGE="\"mecab\"" \
       -DMECAB_DEFAULT_RC="\"/usr/local/etc/mecabrc\""

INC = -I. -I..
DEL = rm -f

OBJ =   param.o					string_buffer.o \
		char_property.o			tagger.o \
		connector.o				tokenizer.o \
		context_id.o			dictionary.o \
		utils.o 				 viterbi.o \
		writer.o iconv_utils.o \
		eval.o nbest_generator.o \
		dart_ffi.o

%.o: %.cpp
	$(CXX) $(CFLAGS) $(INC) $(DEFS) -c  $< -o $@

all: libmecab mecab mecab-dict-index mecab-dict-gen mecab-cost-train mecab-system-eval mecab-test-gen

mecab: $(OBJ) mecab.o
	$(LINK) $(LDFLAGS) -o $@ mecab.o $(OBJ)

mecab-dict-index: $(OBJ) mecab-dict-index.o
	$(LINK) $(LDFLAGS) -o $@ mecab-dict-index.o $(OBJ)

mecab-dict-gen: $(OBJ) mecab-dict-gen.o
	$(LINK) $(LDFLAGS) -o $@ mecab-dict-gen.o $(OBJ)

mecab-cost-train: $(OBJ) mecab-cost-train.o
	$(LINK) $(LDFLAGS) -o $@ mecab-cost-train.o $(OBJ)

mecab-system-eval: $(OBJ) mecab-system-eval.o
	$(LINK) $(LDFLAGS) -o $@ mecab-system-eval.o $(OBJ)

mecab-test-gen: mecab-test-gen.o
	$(LINK) $(LDFLAGS) -o $@ mecab-test-gen.o $(OBJ)

libmecab: $(OBJ) libmecab.o
	$(LINK) $(LDFLAGS) -dynamiclib -o libmecab.dylib $(OBJ) libmecab.o

clean:
	$(DEL) *.o mecab mecab-dict-index mecab-dict-gen mecab-cost-train mecab-system-eval mecab-test-gen libmecab.dylib
