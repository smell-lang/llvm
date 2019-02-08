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


    fun con_bit n =
        let
          fun g' 0   acc = acc
            | g' num acc = g' (num div 2) (Int.toString(num mod 2) ^ acc)
        in
          g' n ""
        end

    fun addGlobalVar x = "0101 " ^ "0111" ^ "001111"; 

    fun add_global (ast.GlobalVariable x) = [addGlobalVar x]
       |add_global (ast.Function x)       = ["fn"] 
       |add_global _                      = [""];

    fun add_def [] = []
       |add_def (x::xs) = case x of
                ast.GlobalDefinition y => ((add_global y) @ (add_def xs)); 

    fun add_header x = ["4243 c0de " ^ "0000 0000 " ^ "0000 1000 " ^ "1111 1111 " ^ "0000 0000 "];

    fun get_bit x = case x of
                   (#"a")  => "000000"
                  |(#"b")  => "000001"
                  |(#"c")  => "000010"
                  |(#"d")  => "000011"
                  |(#"e")  => "000100"
                  |(#"f")  => "000101"
                  |(#"g")  => "000110"
                  |(#"h")  => "000111"
                  |(#"i")  => "001000"
                  |(#"j")  => "001001"
                  |(#"k")  => "001010"
                  |(#"l")  => "001011"
                  |(#"m")  => "001100"
                  |(#"n")  => "001101"
                  |(#"o")  => "001110"
                  |(#"p")  => "001111"
                  |(#"q")  => "010000"
                  |(#"r")  => "010001"
                  |(#"s")  => "010010"
                  |(#"t")  => "010011"
                  |(#"u")  => "010100"
                  |(#"v")  => "010101"
                  |(#"w")  => "010110"
                  |(#"x")  => "010111"
                  |(#"y")  => "011000"
                  |(#"z")  => "011001"
                  |(#"A")  => "011010"
                  |(#"B")  => "011011"
                  |(#"C")  => "011100"
                  |(#"D")  => "011101"
                  |(#"E")  => "011110"
                  |(#"F")  => "011111"
                  |(#"G")  => "100001 000000"
                  |(#"H")  => "100001 000001"
                  |(#"I")  => "100001 000010"
                  |(#"J")  => "100001 000011"
                  |(#"K")  => "100001 000100"
                  |(#"L")  => "100001 000101"
                  |(#"M")  => "100001 000110"
                  |(#"N")  => "100001 000111"
                  |(#"O")  => "100001 001000"
                  |(#"P")  => "100001 001001"
                  |(#"Q")  => "100001 001010"
                  |(#"R")  => "100001 001011"
                  |(#"S")  => "100001 001100"
                  |(#"T")  => "100001 001101"
                  |(#"U")  => "100001 001110"
                  |(#"V")  => "100001 001111"
                  |(#"W")  => "100001 010000"
                  |(#"X")  => "100001 010001"
                  |(#"Y")  => "100001 010010"
                  |(#"Z")  => "100001 010011"
                  |(#"0")  => "100001 010100"
                  |(#"1")  => "100001 010101"
                  |(#"2")  => "100001 010110"
                  |(#"3")  => "100001 010111"
                  |(#"4")  => "100001 011000"
                  |(#"5")  => "100001 011001"
                  |(#"6")  => "100001 011010"
                  |(#"7")  => "100001 011011"
                  |(#"8")  => "100001 011100"
                  |(#"9")  => "100001 011101"
                  |(#".")  => "100001 011110"
                  |(#"_")  => "100001 011111";

    fun get_binary [] = ""
       |get_binary (x::xs) = (get_bit x) ^ " " ^ (get_binary xs);

    fun get_encode "" =  ""
       |get_encode x  = get_binary (String.explode x);

    fun vbr_encoding x = if x < 33 then x else 0;

    fun get_size []      = 0
       |get_size (x::xs) = 1 + get_size(xs);   

    fun vbr x = case (String.size x) of
                1 => "00000" ^ x
               |2 => "0000"  ^ x
               |3 => "000"   ^ x
               |4 => "00"    ^ x
               |5 => "0"     ^ x
               |_ => x;


    fun add_triple (SOME x) = ["0100 " ^ "0010 " ^ vbr(con_bit(vbr_encoding(get_size(String.explode x)))) ^ " " ^ get_encode x]
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