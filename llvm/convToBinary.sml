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

    fun triple_size x = case (String.size x) of
                1 => "000" ^ x
               |2 => "00"  ^ x
               |3 => "0"   ^ x
               |_ => x;

    val count = ref 3;


    fun con_bit n =
        let
          fun g' 0   acc = acc
            | g' num acc = g' (num div 2) (Int.toString(num mod 2) ^ acc)
        in
          g' n ""
        end


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
                  |(#"G")  => "100000"
                  |(#"H")  => "100001"
                  |(#"I")  => "100010"
                  |(#"J")  => "100011"
                  |(#"K")  => "100100"
                  |(#"L")  => "100101"
                  |(#"M")  => "100110"
                  |(#"N")  => "100111"
                  |(#"O")  => "101000"
                  |(#"P")  => "101001"
                  |(#"Q")  => "101010"
                  |(#"R")  => "101011"
                  |(#"S")  => "101100"
                  |(#"T")  => "101101"
                  |(#"U")  => "101110"
                  |(#"V")  => "101111"
                  |(#"W")  => "110000"
                  |(#"X")  => "110001"
                  |(#"Y")  => "110010"
                  |(#"Z")  => "110011"
                  |(#"0")  => "110100"
                  |(#"1")  => "110101"
                  |(#"2")  => "110110"
                  |(#"3")  => "110111"
                  |(#"4")  => "111000"
                  |(#"5")  => "111001"
                  |(#"6")  => "111010"
                  |(#"7")  => "111011"
                  |(#"8")  => "111100"
                  |(#"9")  => "111101"
                  |(#".")  => "111110"
                  |(#"_")  => "111111";

    fun get_binary [] = ""
       |get_binary (x::xs) = (get_bit x) ^ " " ^ (get_binary xs);

    fun addLinkage x = case x of
                  ast.Private             => get_binary(String.explode "Private")
                | ast.Internal            => get_binary(String.explode "Internal")
                | ast.AvailableExternally => get_binary(String.explode "AvailableExternally")
                | ast.LinkOnce            => get_binary(String.explode "LinkOnce")
                | ast.Weak                => get_binary(String.explode "Weak")
                | ast.Common              => get_binary(String.explode "Common")
                | ast.Appending           => get_binary(String.explode "Appending")
                | ast.ExternWeak          => get_binary(String.explode "ExternWeak")
                | ast.LinkOnceODR         => get_binary(String.explode "LinkOnceODR")
                | ast.WeakODR             => get_binary(String.explode "WeakODR")
                | ast.External            => get_binary(String.explode "External"); 

    fun addVisibility x = case x of
                  ast.Default   => get_binary(String.explode "Default")
                | ast.Hidden    => get_binary(String.explode "Hidden")
                | ast.Protected => get_binary(String.explode "Protected");

    fun addUnamed NONE     = ""
       |addUnamed (SOME x) = case x of 
                     ast.LocalAddr  => get_binary(String.explode "LocalAddr")
                   | ast.GlobalAddr => get_binary(String.explode "GlobalAddr");

    fun addStorage NONE     = ""
       |addStorage (SOME x) = case x of 
                     ast.Import  => get_binary(String.explode "Import")
                   | ast.Export  => get_binary(String.explode "Export");

    fun addCombat NONE     = ""
       |addCombat (SOME x) = get_binary(String.explode x);

    fun get_float_type x = case x of
                ast.HalfFP      => "half" 
               |ast.FloatFP     => "float"
               |ast.DoubleFP    => "double"
               |ast.FP128FP     => "fp128"
               |ast.X86_FP80FP  => "x86_fp80"
               |ast.PPC_FP128FP => "ppc_fp128";

    fun add_type x = case x of
                (ast.VoidType)       => get_binary(String.explode "void")
               |(ast.IntegerType y)  => get_binary(String.explode ("i" ^ IntInf.toString(y)))
               |(ast.FloatingType x) => get_binary(String.explode  (get_float_type(x)))
               |_                    => "";

    fun addIsCons x = case x of
                  false => "000000"
                | true  => "000001";

    fun addValue (SOME (ast.Int x))   = get_binary(String.explode (IntInf.toString(x)))
       |addValue (SOME (ast.Float x)) = get_binary(String.explode (Real.toString(x)));

    fun addSection NONE     = ""
       |addSection (SOME x) = get_binary(String.explode x);

    fun addAllig x = get_binary(String.explode (IntInf.toString(x)));

    fun add_global (ast.GlobalVariable x) = 
                let 
                    val counts = !count + 1
                    val s = con_bit counts
                    val temp = triple_size s
                in
                    (count := !count + 1;[temp ^ " 0111 " ^ "001100" ^ " strtab offset " ^ " strtab size " ^ " " ^ add_type(#types(x)) ^ " " ^ addIsCons(#isconstant(x)) ^ " " ^ addValue(#initlizer(x)) ^ " " ^ addLinkage(#linkage(x)) ^ " " ^ addAllig(#alignment(x)) ^ " " ^ addSection(#section(x)) ^ " " ^ addVisibility(#visibility(x)) ^ " " ^ addUnamed(#unnamedadr(x)) ^ " " ^ addStorage(#stoageclass(x)) ^ " " ^ addCombat(#comdat(x))])
                end
       |add_global (ast.Function x)       = ["fn"] 
       |add_global _                      = [""];

    fun add_def [] = []
       |add_def (x::xs) = case x of
                ast.GlobalDefinition y => ((add_global y) @ (add_def xs)); 

    fun add_header x = ["4243 c0de " ^ "0000 0000 " ^ "0000 1000 " ^ "1111 1111 " ^ "0000 0000 "];

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


    fun add_triple (SOME x) = 
                let 
                    val counts = !count + 1
                    val s = con_bit counts
                    val temp = triple_size s
                in
                    (count := !count + 1;[temp ^ " 0010 " ^ vbr(con_bit(vbr_encoding(get_size(String.explode x)))) ^ " " ^ get_encode x])
                end
       |add_triple NONE     = [];

    fun add_dataLayout (SOME x) = []
       |add_dataLayout NONE     = [];

    

    fun addStrBlock x =
                let 
                    val counts = !count + 1
                    val s = con_bit counts
                    val temp = triple_size s
                    val size  = "get_size x"
                in
                    (count := !count + 1;"00010111 " ^ temp ^ size)
                end    
       

    fun add_strtab x = [addStrBlock x]  

    fun conv_mod (ast.Module x) = (add_header x) @ (add_triple (#moduleTargetTriple x)) @ (add_dataLayout (#moduleDatalayout x)) @ (add_def (#moduleDefination x)) @ (add_strtab x);
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