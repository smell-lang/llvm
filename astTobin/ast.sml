(*********************************************************************************)

(*                        Project : LLVM bindings for sml                        *)
(*                        Program : ast.sml                                      *)
(*                        Author  : Rahul Dhawan                                 *)
(*                        Purpose : To capture the AST for LLVM                  *)

(*********************************************************************************)


structure ast = struct

        datatype ('a, 'b) either = Left of 'a | Right of 'b
        
        type 'a set = 'a list

        (* Name can be used for the variable and function *)


        datatype Name = Name of string
                      | UnName of IntInf.int 
                      
                      
        (* Named can be used for using instructions as name *)
        (* It just refrenced the instruction a by the name or just do it if that instruction is not usefull to  refrence *)

        datatype 'a Named = Named of string * 'a (* Reference it by some name *)
                          | Do of 'a (* Just execute it without reference it by some name *)
                      
        (* constants *)

        datatype Constant = Int of IntInf.int
                          | Float of real
                          | NONE

        (* Parameter attributes are used to communicate additional information about the result or parameters of a function *)

        datatype ParameterAttribute = ZeroExt (*     This indicates to the code generator that the parameter or return value should be zero-extended to the extent required by the target’s ABI( application binary interface ) by the caller (for a parameter) or the callee (for a return value). *)
                                    | SignExt (* This indicates to the code generator that the parameter or return value should be sign-extended to the extent required by the target’s ABI (which is usually 32-bits) by the caller (for a parameter) or the callee (for a return value). *)
                                    | InReg (*  *)
                                    | SRet (* *)
                                    | Alignment of IntInf.int (* *)
                                    | NoAlias (* *)
                                    | ByVal (* *)
                                    | NoCapture (* *)
                                    | Nest (* *)
                                    | ReadNone (* *)
                                    | ReadOnly (* *)
                                    | WriteOnly (* *)
                                    | InAlloca (* *)
                                    | NonNull (* This indicates that the parameter or return pointer is not null. *)
                                    | Dereferenceable of IntInf.int (* *)
                                    | DereferenceableOrNull of IntInf.int (* *)
                                    | Returned (* *)
                                    | SwiftSelf (* *)
                                    | SwiftError (* *)
                                    | StringAttribute of string * string (* *)


        (* used for capturing the floating point *)

        datatype FloatingPointType = HalfFP       (* 16-bit floating point value *)
                                   | FloatFP      (* 32-bit floating point value *)
                                   | DoubleFP    (* 64-bit floating point value *)
                                   | FP128FP      (* 128-bit floating point value (112-bit mantissa) *)
                                   | X86_FP80FP   (* 80-bit floating point value (X87) *)
                                   | PPC_FP128FP  (* 128-bit floating point value (two 64-bits) *)

        (* types used in llvm *)

        datatype Type = VoidType (* does not represent any value and has no size *)
                      | IntegerType of IntInf.int
                      | FloatingType of FloatingPointType
                      | PointerType of Type * IntInf.int (* used for capturing the pointer as type to which it pointed and the addresss *)
                      | FunctionType of Type * Type list (* used for signature of the function return type and lis of parameter *)
                      | VectorType of IntInf.int * Type (* used for capturing array of vector with size and type *)
                      | StructureType of bool * Type list (* sed to represent a collection of data members together in memory and the bool representing the padding between the elements *)
                      | ArrayType of IntInf.int * Type (* used for capturing array of  element with size and type *)
                      | NamedTypeReference of Name
                      | MetadataType (* used for parameter type for some instructions *)
                      | LabelType   (* used for the type of block name *)
                      | TokenType
                    
        (* void *)
        val void = VoidType

        (* 1 bit unsigned integer *)
        val i1 = IntegerType 1

        (* 8 bit unsigned integer *)
        val i8 = IntegerType 8

        (* 16 bit unsigned integer *)
        val i16 = IntegerType 16

        (* 32 bit unsigned integer *)
        val i32 = IntegerType 32

        (* 128 bit unsigned integer *)
        val i128 = IntegerType 128


        (* Parameters for function *)

        datatype Parameter = Parameter of Type * Name * ParameterAttribute list (* type , name of the parameters and thier attribute *)


        (* operand is roughly that which is an argument to instruction or function *)

        datatype Operand = LocalReference of Type * Name (* For local variable %foo *) 
                         | GlobalReference of Type * Name (* For global variable @foo *)
        
        
        (* MetaDataNodeId is a number for identifying the metadata node *)
        
        datatype MetaDataNodeId = MetaDataNodeId of string

        (* MDRef can either represent the piece of metadata or metadata itself *)

        datatype 'a MDRef = MDRef of MetaDataNodeId  (* For representing the metadata node *) 
                          | MDInline of 'a (* For representing the part of metadata node *)

        
        (* Scope for capturing the scope of the node *)
        
        datatype DICompileUnit = DICompileUnit
        
        (* ChecksumKind to capture the kind *)
        
        datatype ChecksumKind = SHA
                              | MD5
        
        (* ChecksumInfo to capture the Info as kind * value *)
        
        datatype ChecksumInfo = ChecksumInfo of 
          {
                checksumkind : ChecksumKind,
                checksumvalue : string
          }
        
        (* DIFile for capturing the filename * directory * ChecksumInfo *)
        
        datatype DIFile = File of 
          {
                filename : string, 
                directory : string, 
                checksuminfo : ChecksumInfo 
          }
          
        (* tag type *)  
          
        datatype BasicTypeTag = BaseType 
                              | UnspecifiedType
                              
        (* encoding type *)
        
        datatype Encoding = AddressEncoding
                          | BooleanEncoding
                          | FloatEncoding
                          | SignedEncoding
                          | SignedCharEncoding
                          | UnsignedEncoding
                          | UnsignedCharEncoding
          
        (* Basic type *)
        
        datatype DIBasicType = BasicType of
          {
                name : string,
                sizeInBits : IntInf.int, (* word64 *)
                alignInBits : IntInf.int,
                encoding : Encoding,
                tag : BasicTypeTag
          }
          
        (* Acessibility flag *)
        
        datatype DIAccessibility = Private
                                 | Protected
                                 | Public
                                
        (*  *)
        
        datatype DIModule = DIModules of
          {
                scope : (DIScope MDRef) option,
                name : string,
                configurationMacros : string,
                includePath : string,
                isysRoot : string
          }
                                
        (* Inheritance flag *)
        
        and DIInheritance = SingleInheritance
                          | MultipleInheritance
                          | VirtualInheritance
          
        (* flaf types *)
        
        and DIFlag = Accessibility of DIAccessibility
                   | FwdDecl
                   | AppleBlock
                   | BlockByrefStruct
                   | VirtualFlag
                   | Artificial
                   | Explicit
                   | Prototyped
                   | ObjcClassComplete
                   | ObjectPointer
                   | Vector
                   | StaticMember
                   | LValueReference
                   | RValueReference
                   | InheritanceFlag of DIInheritance
                   | IntroducedVirtual
                   | BitField
                   | NoReturn
                   | MainSubprogram
                       
        and DerivedTypeTag = Typedef
                           | PointerType
                           | PtrToMemberType
                           | ReferenceType
                           | RValueReferenceType
                           | ConstType
                           | VolatileType
                           | RestrictType
                           | AtomicType
                           | Member
                           | Inheritance
                           | Friend   
                            
        (*  *)
        
        and DISubroutineType = SubroutineType of
          {
                flags : DIFlag list,
                cc : IntInf.int, (* word8 *)
                typeArray :  ((DIType MDRef) option) list
          }
        
        (* globalvariable *)
        
        and DIGlobalVariable = GlobalVariable of
          { 
                name : string,
                scope : (DIScope MDRef) option,
                file : (DIFile MDRef) option,
                line : IntInf.int,
                types : (DIType MDRef) option,
                linkageName : string,
                locals : bool,
                definition : bool,
                staticDataMemberDeclaration : (DIDerivedType MDRef) option,
                alignInBits : IntInf.int
          }     
          
        (* dilocalvariabloe*)
        
        and DILocalVariable = LocalVariable of
          {
                name : string,
                scope : DIScope MDRef,
                file : (DIFile MDRef) option,
                line : int,
                types : (DIType MDRef) option,
                flags : DIFlag list,
                arg : int, (* instead of word16*)
                alignInBits : int
          }
          
        (* DIvariable *)
        
        and DIVariable = DIGlobalVariable of DIGlobalVariable
                       | DILocalVariable of DILocalVariable
          
        (*  *)
          
        and DICount = DICountConstant of IntInf.int (* int64 *)
                    | DICountVariable of (DIVariable MDRef)
        
        (*  *)
        
        and DISubrange = Subrange of
          {
                count : DICount, 
                lowerBound : IntInf.int (* int64 *)
          }
        
        (*  *)
        
        and DICompositeType = DIArrayType of
          {
                subscripts : DISubrange list,
                elementTy : (DIType MDRef) option,
                sizeInBits : IntInf.int, (* word64 *)
                alignInBits : IntInf.int,
                flags : DIFlag list
          }
        
        (* Derived type *)
        
        and DIDerivedType = DerivedType of
          { 
                tag : DerivedTypeTag,
                name : string,                   
                file : (DIFile MDRef),
                line : IntInf.int,
                scope : (DIScope MDRef) option,
                baseType : DIType MDRef,
                sizeInBits : IntInf.int, (* word64 *)
                alignInBits : IntInf.int,
                offsetInBits : IntInf.int, (* word64 *)
                addressSpace : IntInf.int,
                flags : DIFlag list
          }     
                
        (* Type of the DI *)
        
        and DIType = DIBasicType of DIBasicType
                   | DICompositeType of DICompositeType
                   | DIDerivedType of DIDerivedType
                   | DISubroutineType of DISubroutineType

        (* namespace capturing *)
       
        and DINamespace = Namespace of string * DIScope * bool
        
        (* lexicalblockbase *)
        
        and DILexicalBlockBase = DILexicalBlock of
          {
                scope : DILocalScope MDRef,
                file : (DIFile MDRef) option,
                line : int,
                column : int (* int instead of 16 bit *)
          }
                               | DILexicalBlockFile of
          {
                 scope : DILocalScope MDRef, 
                 file : (DIFile MDRef) option,
                 discriminator : int
          }
          
        (* virtuality *)
          
        and Virtuality = NoVirtuality 
                       | Virtual
                       | PureVirtual
                       
        (*  *)
        
        and TemplateValueParameterTag = TemplateValueParameter
                                      | GNUTemplateTemplateParam
                                      | GNUTemplateParameterPack
                       
        (*  *)
        
        and DITemplateParameter = DITemplateTypeParameter of
          {
                name : string,
                types : DIType MDRef
          }
                                | DITemplateValueParameter of
          {
                name : string,
                types : DIType MDRef,
                value : Metadata,
                tag : TemplateValueParameterTag
          }
          
        (* subprogram *)
        
        and DISubprogram = Subprogram of
          {
                scope : (DIScope MDRef) option,
                name : string,
                linkageName : string,
                file : (DIFile MDRef) option,
                line : int,
                types : (DISubroutineType MDRef) option,
                localToUnit : bool,
                definition : bool,
                scopeLine : int,
                containingType : (DIType MDRef) option,
                virtuality : Virtuality,
                virtualityIndex : int,
                thisAdjustment : int,
                flags : DIFlag list,
                optimized : bool,
                units : (DICompileUnit MDRef) option,
                templateParams : (DITemplateParameter MDRef) list,
                declaration : (DISubprogram MDRef) option,
                retainedNodes : (DILocalVariable MDRef) list,
                thrownTypes : (DIType MDRef) list
          }
        
        (* localscope *)
        
        and DILocalScope = DILexicalBlockBase of DILexicalBlockBase
                         | DISubprogram of DISubprogram
        
        (* scope of the di *)
        
        and DIScope = DICompileUnit of DICompileUnit
                    | DIFile of DIFile 
                    | DILocalScope of DILocalScope 
                    | DIModule of DIModule
                    | DINamespace of DINamespace
                    | DIType of DIType
                       
        

        (* DILocation for getting the location of the MDNode *)
        
        and DILocation = Location of 
          {
                line : IntInf.int,
                column : IntInf.int,
                scope : DIScope MDRef 
          }
          
        (* Information about the macro *)
        
        and DIMacroInfo = Define
                        | Undef
          
        (* macronode datatype *)
        
        and DIMacroNode = DIMacro of
          {
                info : DIMacroInfo,
                line : IntInf.int,
                name : string,
                value : string     
          }
                        | DIMacroFile of
          {
                line : IntInf.int,
                file : DIFile MDRef,
                elements : (DIMacroNode MDRef) list
          }
          
        (*  *)
         
        and DWOpFragment = DWOPLLVMFragment of
          { 
                offset : IntInf.int,
                size : IntInf.int
          }
        
        (*  *)
        
        and DWOp = DwOpFragment of DWOpFragment 
                 | DW_OP_StackValue 
                 | DW_OP_Swap
                 | DW_OP_ConstU of IntInf.int (* word 64 *)
                 | DW_OP_PlusUConst of IntInf.int
                 | DW_OP_Plus
                 | DW_OP_Minus
                 | DW_OP_Mul
                 | DW_OP_Deref
                 | DW_OP_XDeref
        
        (*  *)
                        
        and DIExpression = Expression of
          {
                operands : DWOp list
          }

        (*  *)
        
        and DIGlobalVariableExpression = GlobalVariableExpression of
          {
                var : DIGlobalVariable MDRef,
                exp : DIExpression MDRef
          }
          
        (*  *)
      
        and DIEnumerator = Enumerator of
          {
                value : int, (* 64 int *)
                isUnsigned : bool,
                name : string 
          }    
          
        (*  *)
          
        and DIObjCProperty = ObjCProperty of 
          {
                name : string,
                file : (DIFile MDRef) option,
                line : int,
                getterName : string,
                setterName : string,
                attributes : int,
                types : (DIType MDRef) option
          }
          
        and ImportedEntityTag = ImportedModule 
                              | ImportedDeclaration
                             
        (*  *)
        
        and DIImportedEntity = ImportedEntity of
          { 
                tag : ImportedEntityTag,
                name : string,
                scope : DIScope MDRef,
                entity : (DINode MDRef) option,
                file : (DIFile MDRef) option,
                line : int
          }
          
        (*  *)
        
        and DINode = DIEnumerator of DIEnumerator
                   | DIImportedEntity of DIImportedEntity
                   | DIObjCProperty of DIObjCProperty
                   | DIScope of DIScope
                   | DISubrange of DISubrange
                   | DITemplateParameter of DITemplateParameter
                   | DIVariable of DIVariable   
        
        (* Type of the MDNode *)
        
        and MDNode = MDTuple of Metadata option list  
                   | DIExpression of DIExpression
                   | DIGlobalVariableExpression of DIGlobalVariableExpression
                   | DILocation of DILocation
                   | DIMacroNode of DIMacroNode
                   | DINode of DINode

        
        (* metadata datatype to capture the metadata *)
        
        and Metadata = MDString of string
                     | MDValue of Operand
                     | MDNode of MDNode MDRef


        (* for capturing the Metadata operand *)
        
        datatype MetaOperand = MetaData of Metadata
        
        (* style of defining *)
        
        datatype Endianness = LittleEndian 
                            | BigEndian
                            
        (* A style of name mangling *)
        
        datatype Mangling = ELFMangling
                          | MIPSMangling
                          | MachOMangling
                          | WindowsCOFFManglin
                          
        (* An AlignmentInfo describes how a given type must and would best be aligned *)
        
        datatype AlignmentInfo = AlignmentInfo of
          {
                abiAlignment : IntInf.int,
                preferredAlignment : IntInf.int
          }
          
        (*  A type of type for which 'AlignmentInfo' may be specified *)
        
        datatype AlignType = IntegerAlign
                           | VectorAlign
                           | FloatAlign

        (* Addrspace type *)
        
        datatype AddrSpace = AddrSpace of IntInf.int 

        (* a description of the various data layout properties which may be used during optimization *)
        
        datatype Datalayout = Datalayout of
          {
                endianness : Endianness,
                mangling : Mangling option,
                stackAlignment : IntInf.int option,
                pointerLayouts : (AddrSpace * (IntInf.int * AlignmentInfo)),
                typeLayouts : ((AlignType * IntInf.int) * AlignmentInfo),          (* ASK SIR  about map*)     
                aggregateLayout : AlignmentInfo,
                nativeSizes : (IntInf.int set) option 
          }
        
        (* Linkage type *)
        
        datatype Linkage = Private
                         | Internal
                         | AvailableExternally
                         | LinkOnce
                         | Weak
                         | Common
                         | Appending
                         | ExternWeak
                         | LinkOnceODR
                         | WeakODR
                         | External
        
        (* visibility type *)
        
        datatype Visibility = Default 
                            | Hidden
                            | Protected
               
        (* unnameAddr type *)        
                        
        datatype UnnamedAddr = LocalAddr 
                             | GlobalAddr
        
        (* storage class type *)
        
        datatype StorageClass = Import
                              | Export
                              
        (* Model tye *) 
                             
        datatype Model = GeneralDynamic
                       | LocalDynamic
                       | InitialExec
                       | LocalExec
        
        (* calling convention *)
        
        datatype CallingConvention = C
                                   | Fast
                                   | Cold
                                   | GHC
                                   | HiPE
                                   | WebKit_JS
                                   | AnyReg
                                   | PreserveMost
                                   | PreserveAll
                                   | Swift
                                   | CXX_FastTLS
                                   | X86_StdCall
                                   | X86_FastCall
                                   | ARM_APCS
                                   | ARM_AAPCS
                                   | ARM_AAPCS_VFP
                                   | MSP430_INTR
                                   | X86_ThisCall
                                   | PTX_Kernel
                                   | PTX_Device
                                   | SPIR_FUNC
                                   | SPIR_KERNEL
                                   | Intel_OCL_BI
                                   | X86_64_SysV
                                   | Win64
                                   | X86_VectorCall
                                   | HHVM
                                   | HHVM_C
                                   | X86_Intr
                                   | AVR_Intr
                                   | AVR_Signal
                                   | AVR_Builtin
                                   | AMDGPU_VS
                                   | AMDGPU_HS
                                   | AMDGPU_GS
                                   | AMDGPU_PS
                                   | AMDGPU_CS
                                   | AMDGPU_Kernel
                                   | X86_RegCall
                                   | MSP430_Builtin
                                   | Numbered of IntInf.int
         
        (* Function Attributes types *)
        
        datatype FunctionAttribute = NoReturn
                                   | NoUnwind
                                   | ReadNone
                                   | ReadOnly
                                   | NoInline
                                   | NoRecurse
                                   | AlwaysInline
                                   | MinimizeSize
                                   | OptimizeForSize
                                   | OptimizeNone
                                   | StackProtect
                                   | StackProtectReq
                                   | StackProtectStrong
                                   | StrictFP
                                   | NoRedZone
                                   | NoImplicitFloat
                                   | Naked
                                   | InlineHint
                                   | StackAlignment of IntInf.int
                                   | ReturnsTwice
                                   | UWTable
                                   | NonLazyBind
                                   | Builtin
                                   | NoBuiltin
                                   | Cold
                                   | JumpTable
                                   | NoDuplicate
                                   | SanitizeAddress
                                   | SanitizeHWAddress
                                   | SanitizeThread
                                   | SanitizeMemory
                                   | Speculatable
                                   | WriteOnly
                                   | ArgMemOnly
                                   | Convergent
                                   | InaccessibleMemOnly
                                   | InaccessibleMemOrArgMemOnly
                                   | SafeStack
                                   | AllocSize of (IntInf.int * (IntInf.int option))
                                   | StringAttribute of
          {
                stringAttributeKind : string,
                stringAttributeValue : string
          }
                                                           
        (* GroupID for capturing the ID for the group *)
        
        datatype GroupID = GroupID of IntInf.int                           
        
        (* Metadata for the instruction *)
        
        datatype InstructionMetadata = InstructionMetadata of (string * (MDNode MDRef)) list
        
        (* The dialect of assembly used in an inline assembly string *)
        
        datatype Dialect = ATTDialect
                         | IntelDialect
        
        (* A representation of an LLVM inline assembly *)
        
        datatype InlineAssembly = InlineAssembly of 
          {
                types : Type,
                assembly : string,
                constraints : string,
                hasSideEffects : bool,
                alignStack : bool,
                dialect : Dialect
          }
           
        type CallableOperand  = (InlineAssembly , Operand) either
        
        (* Terminator for capturing the terminator of the node *)
        
        datatype Terminator = Ret of 
          {    
                returnOperand : Operand option,
                metadata : InstructionMetadata
          } 
                            | CondBr of
          {
                condition : Operand,
                trueDest : Name,
                falseDest : Name,
                metadata : InstructionMetadata
          }
                            | Br of
          {
                dest : Name,
                metadata : InstructionMetadata
          }
                            | Switch of
          {
                operand : Operand,
                defaultDest : Name,
                dests : ((Constant * Name) list),
                metadata : InstructionMetadata
          }
                           | IndirectBr of 
          {
                operand : Operand,
                possibleDests : Name list,
                metadata : InstructionMetadata
          }
                           | Invoke of
          {
                callingConvention : CallingConvention,
                returnAttributes : ParameterAttribute list,
                function : CallableOperand,
                arguments : ((Operand * (ParameterAttribute list)) list),
                functionAttributes : ((GroupID , FunctionAttribute) either) list,
                returnDest : Name,
                exceptionDest : Name,
                metadata : InstructionMetadata
          }
                          | Resume of
          {
                operand : Operand,
                metadata : InstructionMetadata
          }
                          | Unreachable of
          {
                metadata : InstructionMetadata
          }
                          | CleanupRet of
          {
                cleanupPad : Operand,
                unwindDest : Name option,
                metadata : InstructionMetadata
          }
                          | CatchRet of
          {
                catchPad : Operand,
                successor : Name,
                metadata : InstructionMetadata
          }
                          | CatchSwitch of 
          {
                parentPad : Operand,
                catchHandlers : Name list, (* ask sir about the non empty list *)
                defaultUnwindDest : Name option,
                metadata : InstructionMetadata
          }
        
        (*  call may use the following flags to enable otherwise unsafe floating-point transformations. *)
        (* http://llvm.org/docs/LangRef.html#fast-math-flag *)
        
        datatype FastMathFlags = FastMathFlags of 
          {
                allowReassoc : bool,
                noNaNs : bool,
                noInfs : bool,
                noSignedZeros : bool,
                allowReciprocal : bool,
                allowContract : bool,
                approxFunc : bool
          }
          
        (* Operations for the AtomicRMW instruction *)
        
        datatype RMWOperation = Xchg
                              | Add
                              | Sub
                              | And
                              | Nand
                              | Or
                              | Xor
                              | Max
                              | Min
                              | UMax
                              | UMin
                              
        (* Predicates for the ICmp instruction *)
        
        datatype IntegerPredicate = EQ
                                  | NE
                                  | UGT
                                  | UGE
                                  | ULT
                                  | ULE
                                  | SGT
                                  | SGE
                                  | SLT
                                  | SLE
                                  
        (* Predicates for the FCmp instruction *)
        
        datatype FloatingPointPredicate = False
                                        | OEQ
                                        | OGT
                                        | OGE
                                        | OLT
                                        | OLE
                                        | ONE
                                        | ORD
                                        | UNO
                                        | UEQ
                                        | Ugt
                                        | Uge
                                        | Ult
                                        | Ule
                                        | UNE
                                        | True
                                        
        (* For the call instruction *)
        
        datatype TailCallKind = Tail 
                              | MustTail
                              | NoTail
                              
        (* For the redoubtably complex LandingPad instruction *)
        
        datatype LandingPadClause = Catch of Constant
                                  | Filter of Constant
                                                
        datatype MemoryOrdering = Unordered
                                | Monotonic
                                | Acquire
                                | Release
                                | AcquireRelease
                                | SequentiallyConsistent
  
        datatype SynchronizationScope = SingleThread
                                      | System
  
        type Atomicity = SynchronizationScope * MemoryOrdering
        
        (* Non-terminator instructions *)
        (* <http://llvm.org/docs/LangRef.html#binaryops>
          <http://llvm.org/docs/LangRef.html#bitwiseops>
          <http://llvm.org/docs/LangRef.html#memoryops>
          <http://llvm.org/docs/LangRef.html#otherops> *)
        
        datatype Instruction = Add of
          {
                nsw : bool,
                nuw : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                             | FAdd of
          {
                fastMathFlags : FastMathFlags,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                             | Sub of
          {
                nsw : bool,
                nuw : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                             | FSub of
          {
                fastMathFlags : FastMathFlags,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                             | Mul of
          {
                nsw : bool,
                nuw : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                            | FMul of 
          {
                fastMathFlags : FastMathFlags,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | UDiv of 
          {
                exact : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | SDiv of
          {
                exact : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | FDiv of
          {
                fastMathFlags : FastMathFlags,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | URem of
          {
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | SRem of
          {
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | FRem of
          {
                fastMathFlags : FastMathFlags,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }          
                           | Shl of 
          {
                nsw : bool,
                nuw : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | LShr of 
          {
                exact : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | AShr of
          {
                exact : bool,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | And of
          {
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | Or of
          {
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | Xor of
          {
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | Alloca of
          {
                allocatedType : Type,
                numElements : Operand option,
                alignment : IntInf.int,
                metadata : InstructionMetadata
          }
                           | Load of 
          {
                volatile : bool,
                address : Operand,
                maybeAtomicity : Atomicity option,
                alignment : IntInf.int,
                metadata : InstructionMetadata
          }
                           | Store of
          {
                volatile : bool,
                address : Operand,
                value : Operand,
                maybeAtomicity : Atomicity option,
                alignment : IntInf.int,
                metadata : InstructionMetadata
          }
                           | GetElementPtr of
          {
                inBounds : bool,
                address : Operand,
                indices : Operand list,
                metadata : InstructionMetadata
          }   
                           | Fence of 
          {
                atomicity : Atomicity,
                metadata : InstructionMetadata
          }
                           | CmpXchg of
          {
                volatile : bool,
                address : Operand,
                expected : Operand,
                replacement : Operand,
                atomicity : Atomicity,
                failureMemoryOrdering : MemoryOrdering,
                metadata : InstructionMetadata
          }
                           | AtomicRMW of
          {
                volatile : bool,
                rmwOperation : RMWOperation,
                address : Operand,
                value : Operand,
                atomicity : Atomicity,
                metadata : InstructionMetadata
          }
                           | Trunc of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | ZExt of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | SExt of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | FPToUI of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | FPToSI of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | UIToFP of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | SIToFP of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | FPTrunc of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | FPExt of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | PtrToInt of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | IntToPtr of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | BitCast of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | AddrSpaceCast of
          {
                operand0 : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | ICmp of
          {
                iPredicate : IntegerPredicate,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | FCmp of
          {
                fpPredicate : FloatingPointPredicate,
                operand0 : Operand,
                operand1 : Operand,
                metadata : InstructionMetadata
          }
                           | Phi of
          {
                types : Type,
                incomingValues :  (Operand * Name) list,
                metadata : InstructionMetadata
          }
                           | Call of
          {
                tailCallKind : TailCallKind option,
                callingConvention : CallingConvention,
                returnAttributes : ParameterAttribute list,
                function : CallableOperand,
                arguments : (Operand * (ParameterAttribute list)) list,
                functionAttributes : ((GroupID , FunctionAttribute) either) list,
                metadata : InstructionMetadata
          }
                           | Select of
          {
                condition : Operand,
                trueValue : Operand,
                falseValue : Operand,
                metadata : InstructionMetadata
          }
                           | VAArg of
          {
                argList : Operand,
                types : Type,
                metadata : InstructionMetadata
          }
                           | ExtractElement of
          {
                vectors : Operand,
                index : Operand,
                metadata : InstructionMetadata
          }
                           | InsertElement of
          {
                vectors : Operand,
                element : Operand,
                index : Operand,
                metadata : InstructionMetadata
          }
                           | ShuffleVector of
          {
                operand0 : Operand,
                operand1 : Operand,
                mask : Constant,
                metadata : InstructionMetadata
          }
                           | ExtractValue of
          {
                aggregate : Operand,
                indices : int list,
                metadata : InstructionMetadata
          }
                           | InsertValue of
          {
                aggregate : Operand,
                element : Operand,
                indices : int list,
                metadata : InstructionMetadata
          }
                           | LandingPad of
          {
                types : Type,
                cleanup : bool,
                clauses : LandingPadClause list,
                metadata : InstructionMetadata
          }
                           | CatchPad of
          {
                catchSwitch : Operand,
                args : Operand list,
                metadata : InstructionMetadata
          }
                           | CleanupPad of
          {
                parentPad : Operand,
                args : Operand list,
                metadata : InstructionMetadata
          }

      
        
        (* LLVM code in a function is a sequence of 'BasicBlock's each with a label, some instructions, and a terminator. *)
        
        datatype BasicBlock = BasicBlock of Name * ((Instruction Named) list) * (Terminator Named)
                                                             
        (* global datatype to capture global variable, function *)
        
        datatype Global = GlobalVariable of
          {
                name : Name,
                linkage : Linkage,
                visibility : Visibility,
                unnamedadr : UnnamedAddr option, 
                adrspace : AddrSpace,
                stoageclass : StorageClass option,
                localmode : Model option,
                isconstant : bool,
                initlizer : Constant option,
                section : string option,
                comdat : string option,
                alignment : IntInf.int,
                types : Type,
                metadata : (string * (MDNode MDRef)) list              
          }
                        | GlobalAlias of
          {
                 name : Name,
                 linkage : Linkage,
                 visibility : Visibility,
                 storageclass : StorageClass option,
                 localMode : Model option,
                 unnamedAddr : UnnamedAddr option,
                 types : Type,
                 addrSpace : AddrSpace,
                 aliasee : Constant
          }
                        | Function of
          {
                 linkage : Linkage,
                 visibility : Visibility,
                 storageClass : StorageClass option,
                 callingConvention : CallingConvention,
                 returnAttributes : ParameterAttribute list,
                 functionAttributes : ((GroupID , FunctionAttribute) either) list,
                 returnType : Type,
                 name : Name,
                 parameters : ( (Parameter list) * bool ),
                 section : string option,
                 comdat : string option,
                 allignment : IntInf.int,
                 garbagecollectorName : string option,
                 prefix : Constant option,
                 basicblock : BasicBlock list,
                 personalityFunction : Constant option,
                 metadata : (string * (MDNode MDRef)) list
          }
        
        (*  Any thing which can be at the top level of a 'Module' *)
        
        datatype Defination = GlobalDefinition of  Global
                            | TypeDefinition of Name * (Type option)
                            | MetadataNodeDefinition of MetaDataNodeId * MDNode
                            | NamedMetadataDefinition of string * MetaDataNodeId list
                            | ModuleInlineAssembly of string
                            | FunctionAttributes
                            | COMDAT 

        (* module is basically translation unit of the input programm *)
        (* module basically contain global var, local var and fun *)

        datatype Module = Module of 
          {
                modulename : string,
                moduleSourceFilename : string,
                moduleDatalayout : Datalayout option,
                moduleTargetTriple : string option,
                moduleDefination : Defination list 
          }

end;
