EXE=make_flash
EXE_GENVER=gen_softver
EXE_GENHARDVER=gen_hardver

OBJS=make_flash.o md5.o md5_interface.o cJSON.o
OBJS_GENVER=gen_softver.o md5.o md5_interface.o cJSON.o
OBJS_GENHARDVER=gen_hardver.o

# These are host tools: always use the host compiler, even when the outer
# build exports a cross CC.
CC=gcc

LDFLAGS += -lm
CFLAGS += -std=gnu99
CFLAGS += $(SMB_PRIV_COMMON_CFLAGS)

all: $(EXE) $(EXE_GENVER) $(EXE_GENHARDVER)
.PHONY: all clean

$(EXE):$(OBJS)
	$(CC) $^ -o $(EXE) $(LDFLAGS)

$(EXE_GENVER):$(OBJS_GENVER)
	$(CC) $^ -o $(EXE_GENVER) $(LDFLAGS)

$(EXE_GENHARDVER):$(OBJS_GENHARDVER)
	$(CC) $^ -o $(EXE_GENHARDVER) $(LDFLAGS)

%.o:%.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	@rm -rf $(EXE) $(EXE_GENVER) $(EXE_GENHARDVER) *.o
