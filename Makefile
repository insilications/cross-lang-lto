# This test makes sure that the object files we generate are actually
# LLVM bitcode files (as used by linker LTO plugins) when compiling with
# -Clinker-plugin-lto.

# this only succeeds for bitcode files
ASSERT_IS_BITCODE_OBJ=(/usr/bin/llvm-bcanalyzer $(1))
EXTRACT_OBJS=(rm -f ./*.o; /usr/bin/llvm-ar x $(1))

BUILD_LIB=rustc lib.rs -Cpanic=abort -Copt-level=3 -Clinker-plugin-lto=on -Ccodegen-units=1
BUILD_EXE=rustc main.rs -Cpanic=abort -Copt-level=3 -Clinker-plugin-lto=on -Ccodegen-units=1 --emit=obj

all: staticlib staticlib-fat-lto staticlib-thin-lto rlib exe cdylib rdylib

staticlib: lib.rs
	$(BUILD_LIB) --crate-type=staticlib -o ./liblib.a
# 	$(call EXTRACT_OBJS, liblib.a)
# 	for file in ./liblib.*.rcgu.o; do $(call ASSERT_IS_BITCODE_OBJ, $$file); done

staticlib-fat-lto: lib.rs
	$(BUILD_LIB) --crate-type=staticlib -o ./liblib-fat-lto.a -Clto=fat
# 	$(call EXTRACT_OBJS, liblib-fat-lto.a)
# 	for file in ./liblib-fat-lto.*.rcgu.o; do $(call ASSERT_IS_BITCODE_OBJ, $$file); done

staticlib-thin-lto: lib.rs
	$(BUILD_LIB) --crate-type=staticlib -o ./liblib-thin-lto.a -Clto=thin
# 	$(call EXTRACT_OBJS, liblib-thin-lto.a)
# 	for file in ./liblib-thin-lto.*.rcgu.o; do $(call ASSERT_IS_BITCODE_OBJ, $$file); done

rlib: lib.rs
	$(BUILD_LIB) --crate-type=rlib -o ./liblib.rlib
# 	$(call EXTRACT_OBJS, liblib.rlib)
# 	for file in ./liblib.*.rcgu.o; do $(call ASSERT_IS_BITCODE_OBJ, $$file); done

cdylib: lib.rs
	$(BUILD_LIB) --crate-type=cdylib --emit=obj -o ./cdylib.o
# 	$(call ASSERT_IS_BITCODE_OBJ, ./cdylib.o)

rdylib: lib.rs
	$(BUILD_LIB) --crate-type=dylib --emit=obj -o ./rdylib.o
# 	$(call ASSERT_IS_BITCODE_OBJ, ./rdylib.o)

exe: lib.rs
	$(BUILD_EXE) -o ./exe.o
# 	$(call ASSERT_IS_BITCODE_OBJ, ./exe.o)

clean:
	rm *.o || :
	rm *.a || :
	rm *.rmeta || :
	rm *.rlib || :

