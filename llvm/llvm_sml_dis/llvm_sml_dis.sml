(*********************************************************************************)

(*       Project : LLVM bindings for sml                                         *)
(*       Program : llvm_sml_as.sml                                               *)
(*       Author  : Rahul Dhawan                                                  *)
(*       Purpose : To convert the input bitcode file to corresponding llvm file  *)

(*********************************************************************************)

val str = valOf (TextIO.inputLine TextIO.stdIn)

fun getFileName x = let 
						val s = (explode x)
					in
						(implode (List.take(s,(List.length(s)-1))))
					end

val inputFile = getFileName str

fun convertToBitcode x = let
							val inp = "llvm-dis " ^ x
						 in
							OS.Process.system inp
						 end 

val flag = convertToBitcode inputFile

