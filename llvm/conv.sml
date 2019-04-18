(*********************************************************************************)

(*                        Project : LLVM bindings for sml                        *)
(*                        Program : conv.sml                                     *)
(*                        Author  : Rahul Dhawan                                 *)
(*                        Purpose : To convert ast of the llvm into llvm IR      *)

(*********************************************************************************)


use "test.sml";

signature prettyPrinting = sig
    type t
    val conv_mod : ast.Module -> t
end

structure convert:prettyPrinting = struct 
    type t = string list;

    fun get_name (ast.Name x) = x;

    fun get_float_type x = case x of
                ast.HalfFP      => "half" 
               |ast.FloatFP     => "float"
               |ast.DoubleFP    => "double"
               |ast.FP128FP     => "fp128"
               |ast.X86_FP80FP  => "x86_fp80"
               |ast.PPC_FP128FP => "ppc_fp128";

    fun get_type x = case x of
                (ast.VoidType)       => "void"
               |(ast.IntegerType y)  => "i" ^ IntInf.toString(y)
               |(ast.FloatingType x) => get_float_type(x)
               |_                    => "";

    fun get_value (SOME (ast.Int x))   = IntInf.toString(x)
       |get_value (SOME (ast.Float x)) = Real.toString(x); 
                       
    fun get_visibility x = case x of
                ast.Default => "@"
               |_           => "%";

    fun get_parameters (ast.Parameter (x,y,_)) = get_type(x) ^ " " ^ get_name(y);

    fun get_para_helper []      = ""
       |get_para_helper (x::xs) = case xs of
                [] => get_parameters(x)
               |_  => get_parameters(x) ^ " , " ^ get_para_helper(xs);

    fun get_para (x,y) = case y of 
                false => ""
               |true  => get_para_helper(x);

    fun get_bb_name (ast.Name x) = [x ^ ":"];

    fun get_terminator_value NONE = ""
       |get_terminator_value (SOME x) = case x of
                (ast.LocalReference (x,y))  => get_type(x) ^ " " ^ get_name(y)
               |(ast.GlobalReference (x,y)) => get_type(x) ^ get_name(y);

    fun get_termin_val x = case x of
                (ast.LocalReference (x,y))  => get_type(x) ^ " " ^ get_name(y)
               |(ast.GlobalReference (x,y)) => get_type(x) ^ " " ^ get_name(y);

    fun get_terminator (ast.Do x) = case x of
                (ast.Ret y)    => ["ret " ^ get_terminator_value(#returnOperand(y))]
               |(ast.Br y)     => ["br label " ^ get_name(#dest(y))]
               |(ast.CondBr y) => ["br " ^ get_termin_val(#condition(y)) ^ " " ^ "label %" ^ get_name(#trueDest(y)) ^ " label %" ^ get_name(#falseDest(y))]  
               |_              => [];  

    fun get_values (ast.LocalReference (x,ast.Name y)) = y;  

    fun get_ret_type (ast.LocalReference (x,_)) = get_type(x);

    fun get_pred (x : ast.IntegerPredicate) = case x of
                ast.EQ  => "eq"
               |ast.NE  => "ne"
               |ast.UGT => "ugt"
               |ast.UGE => "uge"
               |ast.ULT => "ult"
               |ast.ULE => "ule"
               |ast.SGT => "sgt"
               |ast.SGE => "sge"
               |ast.SLT => "slt"
               |ast.SLE => "sle";

    fun get_inc_type x = case x of
                (ast.LocalReference (x,y))  => "%" ^ get_type(x)
               |(ast.GlobalReference (x,y)) => "%" ^ get_type(x);
    
    fun get_inc(x,y) =  get_inc_type(x) ^ " , %" ^ get_name(y) ;

    fun get_inc_val []           = ""
       |get_inc_val (x::xs)   = case xs of 
                [] => "[" ^ get_inc(x) ^ "]"
               |_  => "[" ^ get_inc(x) ^ "]" ^ " , " ^ get_inc_val(xs);

    fun get_decode_inst x = case x of
                (ast.Add x)   => "add " ^ get_ret_type(#operand0(x)) ^ " " ^ "%" ^ get_values(#operand0(x)) ^ " " ^ get_ret_type(#operand1(x)) ^ " " ^ "%" ^ get_values(#operand1(x))
               |(ast.Sub x)  => "sub " ^ get_ret_type(#operand0(x)) ^ " " ^ "%" ^ get_values(#operand0(x)) ^ " " ^ get_ret_type(#operand1(x)) ^ " " ^ "%" ^ get_values(#operand1(x))
               |(ast.Mul x)  => "mul " ^ get_ret_type(#operand0(x)) ^ " " ^ "%" ^ get_values(#operand0(x)) ^ " " ^ get_ret_type(#operand1(x)) ^ " " ^ "%" ^ get_values(#operand1(x))
               |(ast.UDiv x) => "udiv " ^ get_ret_type(#operand0(x)) ^ " " ^ "%" ^ get_values(#operand0(x)) ^ " " ^ get_ret_type(#operand1(x)) ^ " " ^ "%" ^ get_values(#operand1(x))
               |(ast.ICmp x) => "ICmp " ^ get_pred(#iPredicate(x)) ^ " " ^ get_ret_type(#operand0(x)) ^ " " ^ "%" ^ get_values(#operand0(x)) ^ " " ^ get_ret_type(#operand1(x)) ^ " " ^ "%" ^ get_values(#operand1(x))
               |(ast.Phi x)  => "phi " ^ get_type(#types(x)) ^ " " ^ get_inc_val(#incomingValues(x))
               |_            => "";

    fun get_inst (ast.Named (x,y)) = [ x ^ " = " ^ get_decode_inst(y)];

    fun get_instruction_set nil     = []
       |get_instruction_set (x::xs) = get_inst(x) @ get_instruction_set(xs); 


    fun get_block (ast.BasicBlock (x,y,z)) = get_bb_name(x) @ get_instruction_set(y) @ get_terminator(z) ;

    fun get_bb []      = []
       |get_bb (x::xs) = (get_block x) @ (get_bb xs);


    fun conv_global (ast.GlobalVariable x) = ["@" ^ get_name(#name(x)) ^ " = global " ^ get_type(#types(x)) ^ " " ^ (get_value(#initlizer(x))) ^ " "]
       |conv_global (ast.Function x)       = ["define " ^ get_type(#returnType(x)) ^ " " ^ get_visibility(#visibility(x)) ^ get_name(#name(x)) ^ "(" ^ get_para(#parameters(x)) ^ ") {"] @ get_bb(#basicblock(x)) @ ["}"] 
       |conv_global _                      = [""];

    fun conv_def [] = []
       |conv_def (x::xs) = case x of
                ast.GlobalDefinition y => ((conv_global y) @ (conv_def xs));

    fun conv_mod (ast.Module x) = conv_def (#moduleDefination x);
end;


val d = convert.conv_mod defaultModule;

fun quit(outFile: string, list: string list) =
  let
    val outStream = TextIO.openOut outFile
    fun out(xs : string list) = case xs of
                []     => (TextIO.closeOut outStream)
               |x::xs' => (TextIO.output(outStream, x ^ "\r\n"); out(xs'))
  in
    out(list)
  end;

val e = quit(outputFile,d);