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

    fun add_def [] = []
       |add_def (x::xs) = ["def"] 

    fun add_header x = ["4243 c0de " ^ "0000 0000 " ^ "0000 1000 " ^ "size " ^ "0000 0000 "];

    fun get_bit x = case x of
                   (#"a")  => "21"
                  | _   => "01";

    fun get_binary [] = ""
       |get_binary (x::xs) = (get_bit x) ^ (get_binary xs);

    fun get_encode "" =  ""
       |get_encode x  = get_binary (String.explode x);           

    fun add_triple (SOME x) = [get_encode x]
       |add_triple NONE     = [];

    fun add_dataLayout (SOME x) = []
       |add_dataLayout NONE     = [];

    fun conv_mod (ast.Module x) = (add_header x) @ (add_triple (#moduleTargetTriple x)) @ (add_dataLayout (#moduleDatalayout x)) @ (add_def (#moduleDefination x));
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