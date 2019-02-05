(*********************************************************************************)

(*             Project : LLVM bindings for sml                                   *)
(*             Program : conv.sml                                                *)
(*             Author  : Rahul Dhawan                                            *)
(*             Purpose : To convert ast of the llvm into llvm Binary format      *)

(*********************************************************************************)


use "test.sml";

val binaryFile = "test.bin";

signature binaryPrinting = sig
    type t
    val conv_mod : ast.Module -> t
end

structure convertToBinary:binaryPrinting = struct
    type t = string list;

    fun conv_mod (ast.Module x) = ["00001011000011000000110011101101"];   (* magic number *)
end;

val d = convertToBinary.conv_mod defaultModule;

fun quit(outFile: string, list: string list) =
  let
    val outStream = TextIO.openOut outFile
    fun out(xs : string list) = case xs of
                []     => (TextIO.closeOut outStream)
               |x::xs' => (TextIO.output(outStream, x ^ "\r\n"); out(xs'))
  in
    out(list)
  end;

val e = quit(binaryFile,d);