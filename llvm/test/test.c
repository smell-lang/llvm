#include <llvm-c/BitWriter.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/Target.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Core.h>
#include <stdio.h>

LLVMBool llvm_write_bitcode_file(LLVMModuleRef M, const char *Path) {
  int Result = LLVMWriteBitcodeToFile(M, Path);
  return (Result == 0);
}


int main()
{
	LLVMModuleRef mod = LLVMModuleCreateWithName("my_module");
	printf("hello\n");
}

/* cc `llvm-config --cflags` -c sum.c */
/* c++ `llvm-config --cxxflags --ldflags --libs core executionengine interpreter analysis native bitwriter --system-libs` test.o -o test */
/* ./test */