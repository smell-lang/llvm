(*********************************************************************************)

(*          Project : LLVM bindings for sml                                      *)
(*          Program : conv.sml                                                   *)
(*          Author  : Rahul Dhawan                                               *)
(*          Purpose : To capture the type for bitCode format and fun to convert  *)

(*********************************************************************************)

structure Binary_Format = struct
     
    datatype Id = Id of IntInf.int;

    datatype magicNumber = Number of Word32.word;

    datatype Instructions = EndBlock of 
      {
            alignBits : string
      }
                           |EnterSubBlock of 
      {
            blockID   : Word8.word,
            abbrLen   : string,
            alignbits : string,
            blockLen  : IntInf.int
      }
                           |UnAbbrev of 
      {
            code     : string,
            numofOp  : string,
            operands : string 
      }
                           |Abbrev of 
      {
            Abbrevid : string,
            numofOp  : string,
            operands : string 
      };

      datatype BitFormat = Lists of (magicNumber * ((Id * Instructions) list));
end;

signature Conversion = sig
    
    type t;

    val conv : Binary_Format.BitFormat -> t;
end;