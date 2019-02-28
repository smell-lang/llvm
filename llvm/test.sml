(*********************************************************************************)

(*                        Project : LLVM bindings for sml                        *)
(*                        Program : test.sml                                     *)
(*                        Author  : Rahul Dhawan                                 *)
(*                        Purpose : To capture the AST for LLVM code             *)

(*********************************************************************************)


use "ast.sml";

val outputFile = "test.ll";

val defaultBasicblock0 = ast.BasicBlock (ast.Name "entry" , [ (ast.Named ("%sum" , ast.Sub { nsw = true, nuw = true, operand0 = ast.LocalReference (ast.IntegerType 32, ast.Name "a") , operand1 = ast.LocalReference (ast.IntegerType 32, ast.Name "b") , metadata = ast.InstructionMetadata nil } ) ) , (ast.Named ("%cmp" , ast.ICmp { iPredicate = ast.ULT, operand0 = ast.LocalReference (ast.IntegerType 32, ast.Name "a") , operand1 = ast.LocalReference (ast.IntegerType 32, ast.Name "b") , metadata = ast.InstructionMetadata nil } ) ) , (ast.Named ("%ifcond" , ast.ICmp { iPredicate = ast.NE, operand0 = ast.LocalReference (ast.IntegerType 32, ast.Name "a") , operand1 = ast.LocalReference (ast.IntegerType 32, ast.Name "ifcond") , metadata = ast.InstructionMetadata nil } ) ) ] , ast.Do (ast.CondBr { condition = ast.LocalReference (ast.IntegerType 32, ast.Name "b") ,trueDest = ast.Name "cond", falseDest = ast.Name "cond", metadata = ast.InstructionMetadata nil } ) ); 

val defaultBasicblock1 = ast.BasicBlock (ast.Name "cond" , [ (ast.Named ("%sum" , ast.Mul { nsw = true, nuw = true, operand0 = ast.LocalReference (ast.IntegerType 32, ast.Name "a") , operand1 = ast.LocalReference (ast.IntegerType 32, ast.Name "b") , metadata = ast.InstructionMetadata nil } ) ) ] , ast.Do (ast.Ret { returnOperand = SOME (ast.LocalReference (ast.FloatingType (ast.HalfFP), ast.Name "sum") ), metadata = ast.InstructionMetadata nil } ) ); 


val defaultFunction = ast.Function {
        linkage = ast.Private, 
        visibility = ast.Default,
        storageClass = NONE,
        callingConvention = ast.GHC,
        returnAttributes = nil,
        functionAttributes = nil,
        returnType = ast.FloatingType (ast.HalfFP),
        name = ast.Name "add_two_integer",
        parameters = ( [ast.Parameter (ast.i32, ast.Name "a", [ast.ZeroExt]), ast.Parameter (ast.i32, ast.Name "b", [ast.ZeroExt])] , true ),
        section = NONE,
        comdat = NONE,
        allignment = 0,
        garbagecollectorName = NONE,
        prefix = NONE,
        basicblock = [defaultBasicblock0 , defaultBasicblock1],
        personalityFunction = NONE,
        metadata = nil 
      };


val Var1 = ast.GlobalVariable {
        name = ast.Name "first",
        linkage = ast.Common,
        visibility = ast.Default,
        unnamedadr = NONE, 
        adrspace = ast.AddrSpace 0,
        stoageclass = NONE,
        localmode = NONE,
        isconstant = true,
        initlizer = SOME (ast.Float 6.0),
        section = NONE,
        comdat = NONE,
        alignment = 4,
        types = ast.FloatingType (ast.HalfFP),
        metadata = nil
      };

val Var2 = ast.GlobalVariable {
        name = ast.Name "second",
        linkage = ast.Common,
        visibility = ast.Default,
        unnamedadr = NONE, 
        adrspace = ast.AddrSpace 0,
        stoageclass = NONE,
        localmode = NONE,
        isconstant = true,
        initlizer = SOME (ast.Float 8.9),
        section = NONE,
        comdat = NONE,
        alignment = 4,
        types = ast.FloatingType (ast.FP128FP),
        metadata = nil
      };

val defaultModule = ast.Module {
        modulename = "dd", 
        moduleSourceFilename = "ss", 
        moduleDatalayout = NONE,
        moduleTargetTriple = SOME "aaa",
        moduleDefination = [ast.GlobalDefinition Var1,ast.GlobalDefinition Var2(*,ast.GlobalDefinition defaultFunction*)]
              };