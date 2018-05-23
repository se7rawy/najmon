/*
 * Copyright (c) 2009, Wayne Meissner
 * Copyright (C) 2009 Andrea Fazzi <andrea.fazzi@alcacoop.it>
 * Copyright (c) 2008-2013, Ruby FFI project contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Ruby FFI project nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _MSC_VER
# include <sys/param.h>
#endif
#include <sys/types.h>
#include <stdio.h>

#ifndef _MSC_VER
# include <stdint.h>
# include <stdbool.h>
#else
# include "win32/stdbool.h"
#endif

#include <errno.h>
#include <ruby.h>

#include <ffi.h>
#include "rbffi.h"
#include "compat.h"

#include "AbstractMemory.h"
#include "Types.h"
#include "Type.h"
#include "StructByValue.h"
#include "Function.h"

static VALUE fntype_allocate(VALUE klass);
static VALUE fntype_initialize(int argc, VALUE* argv, VALUE self);
static void fntype_mark(FunctionType*);
static void fntype_free(FunctionType *);

VALUE rbffi_FunctionTypeClass = Qnil;

static VALUE
fntype_allocate(VALUE klass)
{
    FunctionType* fnInfo;
    VALUE obj = Data_Make_Struct(klass, FunctionType, fntype_mark, fntype_free, fnInfo);

    fnInfo->type.ffiType = &ffi_type_pointer;
    fnInfo->type.nativeType = NATIVE_FUNCTION;
    fnInfo->rbReturnType = Qnil;
    fnInfo->rbParameterTypes = Qnil;
    fnInfo->rbEnums = Qnil;
    fnInfo->invoke = rbffi_CallFunction;

    return obj;
}

static void
fntype_mark(FunctionType* fnInfo)
{
    rb_gc_mark(fnInfo->rbReturnType);
    rb_gc_mark(fnInfo->rbParameterTypes);
    rb_gc_mark(fnInfo->rbEnums);
    if (fnInfo->callbackCount > 0 && fnInfo->callbackParameters != NULL) {
        rb_gc_mark_locations(&fnInfo->callbackParameters[0], &fnInfo->callbackParameters[fnInfo->callbackCount]);
    }
}

static void
fntype_free(FunctionType* fnInfo)
{
    xfree(fnInfo->parameterTypes);
    xfree(fnInfo->ffiParameterTypes);
    xfree(fnInfo->nativeParameterTypes);
    xfree(fnInfo->callbackParameters);
    xfree(fnInfo);
}

/*
 * call-seq: initialize(return_type, param_types, options={})
 * @param [Type, Symbol] return_type return type for the function
 * @param [Array<Type, Symbol>] param_types array of parameters types
 * @param [Hash] options
 * @option options [Boolean] :blocking set to true if the C function is a blocking call
 * @option options [Symbol] :convention calling convention see {FFI::Library#calling_convention}
 * @option options [FFI::Enums] :enums
 * @return [self]
 * A new FunctionType instance.
 */
static VALUE
fntype_initialize(int argc, VALUE* argv, VALUE self)
{
    FunctionType *fnInfo;
    ffi_status status;
    VALUE rbReturnType = Qnil, rbParamTypes = Qnil, rbOptions = Qnil;
    VALUE rbEnums = Qnil, rbConvention = Qnil, rbBlocking = Qnil;
#if defined(X86_WIN32)
    VALUE rbConventionStr;
#endif
    int i, nargs;

    nargs = rb_scan_args(argc, argv, "21", &rbReturnType, &rbParamTypes, &rbOptions);
    if (nargs >= 3 && rbOptions != Qnil) {
        rbConvention = rb_hash_aref(rbOptions, ID2SYM(rb_intern("convention")));
        rbEnums = rb_hash_aref(rbOptions, ID2SYM(rb_intern("enums")));
        rbBlocking = rb_hash_aref(rbOptions, ID2SYM(rb_intern("blocking")));
    }

    Check_Type(rbParamTypes, T_ARRAY);

    Data_Get_Struct(self, FunctionType, fnInfo);
    fnInfo->parameterCount = (int) RARRAY_LEN(rbParamTypes);
    fnInfo->parameterTypes = xcalloc(fnInfo->parameterCount, sizeof(*fnInfo->parameterTypes));
    fnInfo->ffiParameterTypes = xcalloc(fnInfo->parameterCount, sizeof(ffi_type *));
    fnInfo->nativeParameterTypes = xcalloc(fnInfo->parameterCount, sizeof(*fnInfo->nativeParameterTypes));
    fnInfo->rbParameterTypes = rb_ary_new2(fnInfo->parameterCount);
    fnInfo->rbEnums = rbEnums;
    fnInfo->blocking = RTEST(rbBlocking);
    fnInfo->hasStruct = false;

    for (i = 0; i < fnInfo->parameterCount; ++i) {
        VALUE entry = rb_ary_entry(rbParamTypes, i);
        VALUE type = rbffi_Type_Lookup(entry);

        if (!RTEST(type)) {
            VALUE typeName = rb_funcall2(entry, rb_intern("inspect"), 0, NULL);
            rb_raise(rb_eTypeError, "Invalid parameter type (%s)", RSTRING_PTR(typeName));
        }

        if (rb_obj_is_kind_of(type, rbffi_FunctionTypeClass)) {
            REALLOC_N(fnInfo->callbackParameters, VALUE, fnInfo->callbackCount + 1);
            fnInfo->callbackParameters[fnInfo->callbackCount++] = type;
        }

        if (rb_obj_is_kind_of(type, rbffi_StructByValueClass)) {
            fnInfo->hasStruct = true;
        }

        rb_ary_push(fnInfo->rbParameterTypes, type);
        Data_Get_Struct(type, Type, fnInfo->parameterTypes[i]);
        fnInfo->ffiParameterTypes[i] = fnInfo->parameterTypes[i]->ffiType;
        fnInfo->nativeParameterTypes[i] = fnInfo->parameterTypes[i]->nativeType;
    }

    fnInfo->rbReturnType = rbffi_Type_Lookup(rbReturnType);
    if (!RTEST(fnInfo->rbReturnType)) {
        VALUE typeName = rb_funcall2(rbReturnType, rb_intern("inspect"), 0, NULL);
        rb_raise(rb_eTypeError, "Invalid return type (%s)", RSTRING_PTR(typeName));
    }
    
    if (rb_obj_is_kind_of(fnInfo->rbReturnType, rbffi_StructByValueClass)) {
        fnInfo->hasStruct = true;
    }

    Data_Get_Struct(fnInfo->rbReturnType, Type, fnInfo->returnType);
    fnInfo->ffiReturnType = fnInfo->returnType->ffiType;


#if defined(X86_WIN32)
    rbConventionStr = (rbConvention != Qnil) ? rb_funcall2(rbConvention, rb_intern("to_s"), 0, NULL) : Qnil;
    fnInfo->abi = (rbConventionStr != Qnil && strcmp(StringValueCStr(rbConventionStr), "stdcall") == 0)
            ? FFI_STDCALL : FFI_DEFAULT_ABI;
#else
    fnInfo->abi = FFI_DEFAULT_ABI;
#endif

    status = ffi_prep_cif(&fnInfo->ffi_cif, fnInfo->abi, fnInfo->parameterCount,
            fnInfo->ffiReturnType, fnInfo->ffiParameterTypes);
    switch (status) {
        case FFI_BAD_ABI:
            rb_raise(rb_eArgError, "Invalid ABI specified");
        case FFI_BAD_TYPEDEF:
            rb_raise(rb_eArgError, "Invalid argument type specified");
        case FFI_OK:
            break;
        default:
            rb_raise(rb_eArgError, "Unknown FFI error");
    }

    fnInfo->invoke = rbffi_GetInvoker(fnInfo);

    return self;
}

/*
 * call-seq: result_type
 * @return [Type]
 * Get the return type of the function type
 */
static VALUE
fntype_result_type(VALUE self)
{
    FunctionType* ft;

    Data_Get_Struct(self, FunctionType, ft);

    return ft->rbReturnType;
}

/*
 * call-seq: param_types
 * @return [Array<Type>]
 * Get parameters types.
 */
static VALUE
fntype_param_types(VALUE self)
{
    FunctionType* ft;

    Data_Get_Struct(self, FunctionType, ft);

    return rb_ary_dup(ft->rbParameterTypes);
}

void
rbffi_FunctionInfo_Init(VALUE moduleFFI)
{
    VALUE ffi_Type;

    ffi_Type = rbffi_TypeClass;

    /*
     * Document-class: FFI::FunctionType < FFI::Type
     */
    rbffi_FunctionTypeClass = rb_define_class_under(moduleFFI, "FunctionType",ffi_Type);
    rb_global_variable(&rbffi_FunctionTypeClass);
    /*
     * Document-const: FFI::CallbackInfo = FFI::FunctionType
     */
    rb_define_const(moduleFFI, "CallbackInfo", rbffi_FunctionTypeClass);
    /*
     * Document-const: FFI::FunctionInfo = FFI::FunctionType
     */
    rb_define_const(moduleFFI, "FunctionInfo", rbffi_FunctionTypeClass);
    /*
     * Document-const: FFI::Type::Function = FFI::FunctionType
     */
    rb_define_const(ffi_Type, "Function", rbffi_FunctionTypeClass);

    rb_define_alloc_func(rbffi_FunctionTypeClass, fntype_allocate);
    rb_define_method(rbffi_FunctionTypeClass, "initialize", fntype_initialize, -1);
    rb_define_method(rbffi_FunctionTypeClass, "result_type", fntype_result_type, 0);
    rb_define_method(rbffi_FunctionTypeClass, "param_types", fntype_param_types, 0);

}

