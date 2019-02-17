(*********************************************************************************)

(*          Project : LLVM bindings for sml                                      *)
(*          Program : conv.sml                                                   *)
(*          Author  : Rahul Dhawan                                               *)
(*          Purpose : To capture the type for bitCode format and fun to convert  *)

(*********************************************************************************)


val currAbrrLen = ref 2;

val (prevAbbrLen : int list ref)  = ref [];

datatype Id = Id of IntInf.int;

datatype magicNumber = Number of Word32.word;

datatype Instructions = EndBlock of string
                       |EnterSubBlock of 
  {
        blockID   : Word8.word,
        abbrLen   : string,
        alignbits : string,
        blockLen  : string
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

datatype BitFormat = Lists of magicNumber * ((Id * Instructions) list);


signature Conversion = sig
    
    type t;

    val conv : BitFormat -> t;
end;

structure conversion = struct

    type t = string;

    fun ff(nil) = nil 
       |ff x  = List.take (x,4)::ff(List.drop (x,4));

    fun ctos(nil) = nil
       |ctos (x::xs) = (Char.toString x)::(ctos xs);

    fun convtoHex [] = ""
       |convtoHex (x::xs) = List.nth (x,1) ^ List.nth (x,2) ^ List.nth (x,3) ^ convtoHex(xs); 

    fun power(x,0) = 1
      | power(x,n) = power(x,n-1)*x;

    fun getValue (nil,y)     = 0
       |getValue ((x::xs),y) = case x of
                        (#"0") => 0 + getValue(xs,y-1)
                       |(#"1") => power(2,y) + getValue(xs,y-1)
                       |_    => 0;

    fun convIns (x,y) = case y of
                EnterSubBlock x =>
                                  let
                                        fun getEncodedId 2 = "00"
                                           |getEncodedId y = "0" ^ getEncodedId (y-1)
                                        val id = getEncodedId(List.hd(!prevAbbrLen))
                                  in 
                                        (prevAbbrLen := [!currAbrrLen] @ !prevAbbrLen ; currAbrrLen := getValue (String.explode (convtoHex (ff (ctos (String.explode (#abbrLen(x)))))), (String.size (convtoHex (ff (ctos (String.explode (#abbrLen(x)))))) - 1)); id ^ Word8.toString (#blockID(x)) ^ (#abbrLen(x)) ^ (#alignbits(x)) ^(#blockLen(x)) )
                                  end
               |EndBlock x      =>
                                  let
                                        fun getEncodedId 2 = "00"
                                           |getEncodedId y = "0" ^ getEncodedId (y-1)
                                        val id = getEncodedId(List.hd(!prevAbbrLen))
                                  in
                                        (currAbrrLen := List.hd(!prevAbbrLen) ;prevAbbrLen := List.drop (!prevAbbrLen,1); id ^ x)
                                  end
               |Abbrev x        => 
                                  let
                                        fun getEncodedId 2 = "00"
                                           |getEncodedId y = "0" ^ getEncodedId (y-1)
                                        val id = getEncodedId(!currAbrrLen)
                                  in
                                        (id ^ (#Abbrevid(x)) ^ (#numofOp(x)) ^ (#operands(x)))
                                  end
               |UnAbbrev x      => 
                                  let
                                        fun getEncodedId 2 = "00"
                                           |getEncodedId y = "0" ^ getEncodedId (y-1)
                                        val id = getEncodedId(!currAbrrLen)
                                  in
                                        (id ^ (#code(x)) ^ (#numofOp(x)) ^ (#operands(x)))
                                  end;

    fun convInstructions []          = ""  
       |convInstructions (x::xs) = (convIns x) ^ (convInstructions xs);

    fun conMagic (Number x) = (Word32.toString x);

    fun conv (Lists (y,x)) = (conMagic y) ^ (convInstructions x);

end;

(*EndBlock x      => (prevAbbrLen := [!currAbrrLen] @ !prevAbbrLen;currAbrrLen := getValue (String.explode (convtoHex (ff (ctos (String.explode x)))), (String.size (convtoHex (ff (ctos (String.explode x)))) - 1)) ;x)*)
