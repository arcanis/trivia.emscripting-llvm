#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#include <llvm/ADT/APInt.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/ExecutionEngine/Interpreter.h>
#include <llvm/BasicBlock.h>
#include <llvm/DerivedTypes.h>
#include <llvm/Function.h>
#include <llvm/IRBuilder.h>
#include <llvm/LLVMContext.h>
#include <llvm/Module.h>
#include <llvm/Type.h>
#include <llvm/Value.h>

int main( void )
{
    llvm::LLVMContext llvmContext;
    llvm::IRBuilder< > llvmIRBuilder( llvmContext );
    llvm::Module llvmModule( "@mainModule", llvmContext );

    std::string errorString;
    llvm::ExecutionEngine * llvmExecutionEngine = llvm::EngineBuilder( & llvmModule ).setErrorStr( & errorString ).create( );
    if ( ! llvmExecutionEngine ) throw std::runtime_error( errorString );

    llvm::Type * llvmReturnType = llvm::IntegerType::get( llvmContext, 32 );
    std::vector< llvm::Type * > llvmParameters = { llvm::IntegerType::get( llvmContext, 32 ) };
    llvm::FunctionType * llvmFunctionType = llvm::FunctionType::get( llvmReturnType, llvmParameters, false );
    llvm::Function * llvmFunction = llvm::Function::Create( llvmFunctionType, llvm::Function::ExternalLinkage, "main", & llvmModule );
    llvm::Value * llvmArgument = llvmFunction->arg_begin( );

    llvm::BasicBlock * llvmBasicBlock = llvm::BasicBlock::Create( llvmContext, "", llvmFunction );
    llvmIRBuilder.SetInsertPoint( llvmBasicBlock );
    llvmIRBuilder.CreateRet( llvmArgument );

    std::vector< llvm::GenericValue > arguments( 1 );
    arguments[ 0 ].IntVal = llvm::APInt( 32, 42 );
    llvm::GenericValue result = llvmExecutionEngine->runFunction( llvmFunction, arguments );

    std::cout << result.IntVal.getZExtValue( ) << std::endl;

    return 0;
}
