// including all the libraries that is needed for the conversion

#include <llvm-c/Core.h>
#include <llvm-c/ExecutionEngine.h>
#include <llvm-c/Target.h>
#include <llvm-c/Analysis.h>
#include <llvm-c/BitWriter.h>

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


// function to convert the module 

int convert( LLVMModuleRef mod )
{
        if (LLVMWriteBitcodeToFile(mod, "sum.bc") != 0)
        {
                fprintf(stderr, "error writing bitcode to file, skipping\n");
                return 0;
        }
        return 1;
}


// helper function 
void helper(char a[],char **s,int length)
{
        int i,j,k,l,m,n,index,paracount,flag = 0,BBcount,instcount;
        
        char b[10][10];
        char valName[200][10];
        
        LLVMValueRef val[200];
        
        LLVMModuleRef mod = LLVMModuleCreateWithName(a);
        
        
        i = 0;
        n = 0;
        index = 0;
        m = 0;
        paracount = 0;
        instcount = 0;
        BBcount = 0; 
        while(1){     
                if(s[i][0] == '1')
                {
                        // for global variable 
                        if(s[i+2][0] == '0')
                        {
                                LLVMValueRef temp = LLVMAddGlobal(mod, LLVMInt32Type(), s[i+1]);
                        }
                        else if(s[i+2][0] == '1')
                        {
                                LLVMValueRef temp = LLVMAddGlobal(mod, LLVMFloatType(), s[i+1]);
                        }
                        strncpy(valName[index],s[i+1],200);
                        index = index + 1;
                        i=i+3; 
                }
                else if(s[i][0] == '2')
                {
                        sscanf(s[i+3], "%d", &paracount);
                        sscanf(s[i+4+paracount+paracount], "%d" , &BBcount);
                        
                        LLVMBuilderRef build[BBcount];
                        LLVMBasicBlockRef BB[BBcount];
                      
                        LLVMTypeRef param_types[paracount];
                        
                        for(j=0;j<paracount;j++)
                        { 
                                param_types[j] = LLVMInt32Type();
                        }
                        
                        if(s[i+2][0] == '3')
                        {
                            LLVMTypeRef ret_type = LLVMFunctionType(LLVMInt32Type(), param_types, 2, 0);
                            LLVMValueRef fun = LLVMAddFunction(mod, s[i+1], ret_type);
                            LLVMValueRef tmp;
                            
                            
                            for(j=0;j<BBcount;j++)
                            {
                                m = 0;
                                strncpy(b[j],s[i+5+paracount+paracount+j],20);
                                BB[j] = LLVMAppendBasicBlock(fun, s[i+5+paracount+paracount+j]);
                                build[j] = LLVMCreateBuilder();
                                LLVMPositionBuilderAtEnd(build[j], BB[j]);
                            }
                            
                            
                            
                            int flag = 0;
                            
                            
                            for(j=0;j<paracount;j++)
                            {
                                    val[index] = LLVMGetParam(fun,j);
                                    strncpy(valName[index],s[i+4+paracount+j],20);
                                    index = index + 1;
                            }
                            
                            LLVMValueRef first, second;
                           
                            for(k=0;k<BBcount;k++)
                            {
                                flag = 0;
                                sscanf(s[i+6+BBcount+paracount+paracount], "%d", &instcount); 
                                for(l=0;l<instcount;l++)
                                {
                                        for(n=0;n<index;n++)
                                        {
                                                if(strcmp(s[i+9+BBcount+paracount+paracount+(l*4)],valName[n])==0)
                                                {
                                                        first = val[n];
                                                }
                                                if(strcmp(s[i+10+BBcount+paracount+paracount+(l*4)],valName[n])==0)
                                                {
                                                        second = val[n];
                                                }
                                        }
                                        if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '3' )
                                        {
                                                val[index] = LLVMBuildAdd(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '4' )
                                        {
                                                val[index] = LLVMBuildSub(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '6' )
                                        {
                                                val[index] = LLVMBuildMul(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '5' )
                                        {
                                                val[index] = LLVMBuildUDiv(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '8')
                                        {
                                                val[index] = LLVMBuildAnd(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '9')
                                        {
                                                val[index] = LLVMBuildOr(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '0')
                                        {
                                                val[index] = LLVMBuildXor(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '2')
                                        {
                                                LLVMBuildStore(build[k], LLVMConstInt(LLVMInt32Type(), atoi(s[i+9+BBcount+paracount+paracount+(l*4)]) , 0), second);
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '1')
                                        {
                                                if(s[i+9+BBcount+paracount+paracount+(l*4)][0] == '0')
                                                {
                                                        val[index] = LLVMBuildAlloca(build[k], LLVMInt32Type() ,s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                }
                                                else
                                                {
                                                        val[index] = LLVMBuildAlloca(build[k], LLVMFloatType() ,s[i+7+BBcount+paracount+paracount+(l*4)]);                                        
                                                }
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }   
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '7' )
                                        {
                                                if(s[i+8+BBcount+paracount+(l*4)][0] == '0')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntEQ, first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '1')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntNE , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '2')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntUGT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '3')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntUGE , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '4')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntULT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '5')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntULE  , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '6')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSGT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '7')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSGE , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '8')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSLT , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSLE , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                        }            
                                        
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='1')
                                {
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],valName[j])==0)
                                                        break;
                                        }     
                                        LLVMBuildRet(build[k],val[j]);
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='2')
                                {     
                                        for(j=0;j<BBcount;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],s[i+5+paracount+paracount+j])==0)
                                                        break;
                                        }
                                        LLVMBuildBr(build[k],BB[j]);
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='3')
                                {       
                                        int firstbb, secondbb;
                                        
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+9+paracount+paracount+BBcount+(instcount*4)],b[j])==0)
                                                        firstbb = j;
                                                if(strcmp(s[i+10+paracount+paracount+BBcount+(instcount*4)],b[j])==0)
                                                        secondbb = j;
                                        }
                                
                                        
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],valName[j])==0)
                                                        break;
                                        }     
                                        LLVMBuildCondBr(build[k],val[j],BB[firstbb],BB[secondbb]);  
                                }
                                
                                if((BBcount-1)!=(k))
                                {
                                        flag = 1;
                                }
                                        
                                LLVMDisposeBuilder(build[k]); 
                                i = i + 4*instcount + 5 + flag;        
                            }
                            
                        }
                        
                        if(s[i+2][0] == 'f')
                        {
                            LLVMTypeRef ret_type = LLVMFunctionType(LLVMFloatType(), param_types, 2, 0);
                            LLVMValueRef fun = LLVMAddFunction(mod, s[i+1], ret_type);
                            LLVMValueRef tmp;
                            
                            
                            for(j=0;j<BBcount;j++)
                            {
                                m = 0;
                                strncpy(b[j],s[i+5+paracount+paracount+j],20);
                                BB[j] = LLVMAppendBasicBlock(fun, s[i+5+paracount+paracount+j]);
                                build[j] = LLVMCreateBuilder();
                                LLVMPositionBuilderAtEnd(build[j], BB[j]);
                            }
                            
                            
                            
                            int flag = 0;
                            
                            
                            for(j=0;j<paracount;j++)
                            {
                                    val[index] = LLVMGetParam(fun,j);
                                    strncpy(valName[index],s[i+4+paracount+j],20);
                                    index = index + 1;
                            }
                            
                            LLVMValueRef first, second;
                           
                            for(k=0;k<BBcount;k++)
                            {
                                flag = 0;
                                sscanf(s[i+6+BBcount+paracount+paracount], "%d", &instcount); 
                                for(l=0;l<instcount;l++)
                                {
                                        for(n=0;n<index;n++)
                                        {
                                                if(strcmp(s[i+9+BBcount+paracount+paracount+(l*4)],valName[n])==0)
                                                {
                                                        first = val[n];
                                                }
                                                if(strcmp(s[i+10+BBcount+paracount+paracount+(l*4)],valName[n])==0)
                                                {
                                                        second = val[n];
                                                }
                                        }
                                        if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '3' )
                                        {
                                                val[index] = LLVMBuildAdd(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '4' )
                                        {
                                                val[index] = LLVMBuildSub(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '6' )
                                        {
                                                val[index] = LLVMBuildMul(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '5' )
                                        {
                                                val[index] = LLVMBuildUDiv(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '8')
                                        {
                                                val[index] = LLVMBuildAnd(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '9')
                                        {
                                                val[index] = LLVMBuildOr(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '0')
                                        {
                                                val[index] = LLVMBuildXor(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '2')
                                        {
                                                LLVMBuildStore(build[k], LLVMConstInt(LLVMInt32Type(), atoi(s[i+9+BBcount+paracount+paracount+(l*4)]) , 0), second);
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '1')
                                        {
                                                if(s[i+9+BBcount+paracount+paracount+(l*4)][0] == '0')
                                                {
                                                        val[index] = LLVMBuildAlloca(build[k], LLVMInt32Type() ,s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                }
                                                else
                                                {
                                                        val[index] = LLVMBuildAlloca(build[k], LLVMFloatType() ,s[i+7+BBcount+paracount+paracount+(l*4)]);                                        
                                                }
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }   
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '7' )
                                        {
                                                if(s[i+8+BBcount+paracount+(l*4)][0] == '0')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntEQ, first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '1')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntNE , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '2')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntUGT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '3')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntUGE , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '4')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntULT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '5')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntULE  , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '6')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSGT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '7')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSGE , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '8')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSLT , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSLE , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                        }            
                                        
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='1')
                                {
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],valName[j])==0)
                                                        break;
                                        }     
                                        LLVMBuildRet(build[k],val[j]);
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='2')
                                {     
                                        for(j=0;j<BBcount;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],s[i+5+paracount+paracount+j])==0)
                                                        break;
                                        }
                                        LLVMBuildBr(build[k],BB[j]);
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='3')
                                {       
                                        int firstbb, secondbb;
                                        
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+9+paracount+paracount+BBcount+(instcount*4)],b[j])==0)
                                                        firstbb = j;
                                                if(strcmp(s[i+10+paracount+paracount+BBcount+(instcount*4)],b[j])==0)
                                                        secondbb = j;
                                        }
                                
                                        
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],valName[j])==0)
                                                        break;
                                        }     
                                        LLVMBuildCondBr(build[k],val[j],BB[firstbb],BB[secondbb]);  
                                }
                                
                                if((BBcount-1)!=(k))
                                {
                                        flag = 1;
                                }
                                        
                                LLVMDisposeBuilder(build[k]); 
                                i = i + 4*instcount + 5 + flag;        
                            }
                            
                        }
                        
                        else if(s[i+2][0] == 'v')
                        {
                            LLVMTypeRef ret_type = LLVMFunctionType(LLVMVoidType(), param_types, 2, 0);
                            LLVMValueRef fun = LLVMAddFunction(mod, s[i+1], ret_type);
                            LLVMValueRef tmp;
                            
                            
                            for(j=0;j<BBcount;j++)
                            {
                                m = 0;
                                strncpy(b[j],s[i+5+paracount+paracount+j],20);
                                BB[j] = LLVMAppendBasicBlock(fun, s[i+5+paracount+paracount+j]);
                                build[j] = LLVMCreateBuilder();
                                LLVMPositionBuilderAtEnd(build[j], BB[j]);
                            }
                            
                            
                            
                            int flag = 0;
                            
                            
                            for(j=0;j<paracount;j++)
                            {
                                    val[index] = LLVMGetParam(fun,j);
                                    strncpy(valName[index],s[i+4+paracount+j],20);
                                    index = index + 1;
                            }
                            
                            LLVMValueRef first, second;
                           
                            for(k=0;k<BBcount;k++)
                            {
                                flag = 0;
                                sscanf(s[i+6+BBcount+paracount+paracount], "%d", &instcount); 
                                for(l=0;l<instcount;l++)
                                {
                                        for(n=0;n<index;n++)
                                        {
                                                if(strcmp(s[i+9+BBcount+paracount+paracount+(l*4)],valName[n])==0)
                                                {
                                                        first = val[n];
                                                }
                                                if(strcmp(s[i+10+BBcount+paracount+paracount+(l*4)],valName[n])==0)
                                                {
                                                        second = val[n];
                                                }
                                        }
                                        if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '3' )
                                        {
                                                val[index] = LLVMBuildAdd(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '4' )
                                        {
                                                val[index] = LLVMBuildSub(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '6' )
                                        {
                                                val[index] = LLVMBuildMul(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '5' )
                                        {
                                                val[index] = LLVMBuildUDiv(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '8')
                                        {
                                                val[index] = LLVMBuildAnd(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '9')
                                        {
                                                val[index] = LLVMBuildOr(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        } 
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '0')
                                        {
                                                val[index] = LLVMBuildXor(build[k], first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '2')
                                        {
                                                LLVMBuildStore(build[k], LLVMConstInt(LLVMInt32Type(), atoi(s[i+9+BBcount+paracount+paracount+(l*4)]) , 0), second);
                                        }
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '1')
                                        {
                                                if(s[i+9+BBcount+paracount+paracount+(l*4)][0] == '0')
                                                {
                                                        val[index] = LLVMBuildAlloca(build[k], LLVMInt32Type() ,s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                }
                                                else
                                                {
                                                        val[index] = LLVMBuildAlloca(build[k], LLVMFloatType() ,s[i+7+BBcount+paracount+paracount+(l*4)]);                                        
                                                }
                                                strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                index = index + 1;
                                        }   
                                        else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '7' )
                                        {
                                                if(s[i+8+BBcount+paracount+(l*4)][0] == '0')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntEQ, first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '1')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntNE , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '2')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntUGT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '3')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntUGE , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '4')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntULT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '5')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntULE  , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '6')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSGT  , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '7')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSGE , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else if(s[i+8+BBcount+paracount+paracount+(l*4)][0] == '8')
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSLT , first,second, s[i+7+BBcount+paracount+paracount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                                else
                                                {
                                                        val[index] = LLVMBuildICmp (build[k], LLVMIntSLE , first,second, s[i+7+paracount+paracount+BBcount+(l*4)]);
                                                        strncpy(valName[index],s[i+7+BBcount+paracount+paracount+(l*4)],20);
                                                        index = index + 1;
                                                }
                                        }            
                                        
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='1')
                                {
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],valName[j])==0)
                                                        break;
                                        }     
                                        LLVMBuildRet(build[k],val[j]);
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='2')
                                {     
                                        for(j=0;j<BBcount;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],s[i+5+paracount+paracount+j])==0)
                                                        break;
                                        }
                                        LLVMBuildBr(build[k],BB[j]);
                                }
                                if(s[i+7+paracount+paracount+BBcount+(instcount*4)][0]=='3')
                                {       
                                        int firstbb, secondbb;
                                        
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+9+paracount+paracount+BBcount+(instcount*4)],b[j])==0)
                                                        firstbb = j;
                                                if(strcmp(s[i+10+paracount+paracount+BBcount+(instcount*4)],b[j])==0)
                                                        secondbb = j;
                                        }
                                
                                        
                                        for(j=0;j<index;j++)
                                        {
                                                if(strcmp(s[i+8+paracount+paracount+BBcount+(instcount*4)],valName[j])==0)
                                                        break;
                                        }     
                                        LLVMBuildCondBr(build[k],val[j],BB[firstbb],BB[secondbb]);  
                                }
                                
                                if((BBcount-1)!=(k))
                                {
                                        flag = 1;
                                }
                                        
                                LLVMDisposeBuilder(build[k]); 
                                i = i + 4*instcount + 5 + flag;        
                            }
                        }
                        i = i+6+BBcount+paracount+paracount;
                        LLVMConstAdd(LLVMConstIntOfString(LLVMInt32Type(),"2",0),LLVMConstIntOfString(LLVMInt32Type(),"2",0)); 
                        
                }
                else if(s[i][0] == '-' && s[i][1] =='1')
                        break;
        }
            
        
        flag = convert( mod );   // calling function to convert
        
        if( flag==0 )
        {
                printf("error\n");        // condition if error
        }
        else
        {
                printf("success\n");     // condition if success
        }
        LLVMDisposeModule(mod);
}
