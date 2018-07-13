open Globals
open Ast
open Type
open Genjson

module CompletionModuleKind = struct
	type t =
		| Class
		| Interface
		| Enum
		| Abstract
		| EnumAbstract
		| TypeAlias
		| Struct
		| TypeParameter

	let to_int = function
		| Class -> 0
		| Interface -> 1
		| Enum -> 2
		| Abstract -> 3
		| EnumAbstract -> 4
		| TypeAlias -> 5
		| Struct -> 6
		| TypeParameter -> 7
end

module ImportStatus = struct
	type t =
		| Imported
		| Unimported
		| Shadowed

	let to_int = function
		| Imported -> 0
		| Unimported -> 1
		| Shadowed -> 2
end

module CompletionModuleType = struct
	open CompletionModuleKind

	type t = {
		pack : string list;
		name : string;
		module_name : string;
		pos : pos;
		is_private : bool;
		params : Ast.type_param list;
		meta: metadata;
		doc : documentation;
		is_extern : bool;
		kind : CompletionModuleKind.t;
		import_status : ImportStatus.t;
	}

	let of_type_decl is pack module_name (td,p) = match td with
		| EClass d -> {
				pack = pack;
				name = fst d.d_name;
				module_name = module_name;
				pos = p;
				is_private = List.mem HPrivate d.d_flags;
				params = d.d_params;
				meta = d.d_meta;
				doc = d.d_doc;
				is_extern = List.mem HExtern d.d_flags;
				kind = if List.mem HInterface d.d_flags then Interface else Class;
				import_status = is;
			}
		| EEnum d -> {
				pack = pack;
				name = fst d.d_name;
				module_name = module_name;
				pos = p;
				is_private = List.mem EPrivate d.d_flags;
				params = d.d_params;
				meta = d.d_meta;
				doc = d.d_doc;
				is_extern = List.mem EExtern d.d_flags;
				kind = Enum;
				import_status = is;
			}
		| ETypedef d -> {
				pack = pack;
				name = fst d.d_name;
				module_name = module_name;
				pos = p;
				is_private = List.mem EPrivate d.d_flags;
				params = d.d_params;
				meta = d.d_meta;
				doc = d.d_doc;
				is_extern = List.mem EExtern d.d_flags;
				kind = (match fst d.d_data with CTAnonymous _ -> Struct | _ -> TypeAlias);
				import_status = is;
			}
		| EAbstract d -> {
				pack = pack;
				name = fst d.d_name;
				module_name = module_name;
				pos = p;
				is_private = List.mem AbPrivate d.d_flags;
				params = d.d_params;
				meta = d.d_meta;
				doc = d.d_doc;
				is_extern = List.mem AbExtern d.d_flags;
				kind = if Meta.has Meta.Enum d.d_meta then EnumAbstract else Abstract;
				import_status = is;
			}
		| EImport _ | EUsing _ ->
			raise Exit

	let of_module_type is mt =
		let is_extern,kind = match mt with
			| TClassDecl c ->
				c.cl_extern,if c.cl_interface then Interface else Class
			| TEnumDecl en ->
				en.e_extern,Enum
			| TTypeDecl td ->
				false,(match follow td.t_type with TAnon _ -> Struct | _ -> TypeAlias)
			| TAbstractDecl a ->
				false,(if Meta.has Meta.Enum a.a_meta then EnumAbstract else Abstract)
		in
		let infos = t_infos mt in
		let convert_type_param (s,t) = match follow t with
			| TInst(c,_) -> {
				tp_name = s,null_pos;
				tp_params = [];
				tp_constraints = []; (* TODO? *)
				tp_meta = c.cl_meta
			}
			| _ ->
				assert false
		in
		{
			pack = fst infos.mt_path;
			name = snd infos.mt_path;
			module_name = snd infos.mt_module.m_path;
			pos = infos.mt_pos;
			is_private = infos.mt_private;
			params = List.map convert_type_param infos.mt_params;
			meta = infos.mt_meta;
			doc = infos.mt_doc;
			is_extern = is_extern;
			kind = kind;
			import_status = is;
		}

	let get_path cm = (cm.pack,cm.name)

	let to_json ctx cm =
		let fields =
			("pack",jlist jstring cm.pack) ::
			("name",jstring cm.name) ::
			("moduleName",jstring cm.module_name) ::
			("isPrivate",jbool cm.is_private) ::
			("kind",jint (to_int cm.kind)) ::
			("importStatus",jint (ImportStatus.to_int cm.import_status)) ::
			(match ctx.generation_mode with
			| GMFull | GMWithoutDoc ->
				("pos",generate_pos ctx cm.pos) ::
				("params",jlist (generate_ast_type_param ctx) cm.params) ::
				("meta",generate_metadata ctx cm.meta) ::
				("isExtern",jbool cm.is_extern) ::
				(if ctx.generation_mode = GMFull then ["doc",jopt jstring cm.doc] else [])
			| GMMinimum ->
				[]
			)
		in
		jobject fields

end

open CompletionModuleType

type resolution_mode =
	| RMLocalModule
	| RMImport
	| RMUsing
	| RMTypeParameter
	| RMClassPath
	| RMOtherModule of path

type t =
	| ITLocal of tvar
	| ITClassField of tclass_field * class_field_scope
	| ITEnumField of tenum * tenum_field
	| ITEnumAbstractField of tabstract * tclass_field
	| ITType of CompletionModuleType.t * resolution_mode
	| ITPackage of string
	| ITModule of string
	| ITLiteral of string * Type.t
	| ITTimer of string * string
	| ITMetadata of string * documentation
	| ITKeyword of keyword

let legacy_sort = function
	| ITClassField(cf,_) | ITEnumAbstractField(_,cf) ->
		begin match cf.cf_kind with
		| Var _ -> 0,cf.cf_name
		| Method _ -> 1,cf.cf_name
		end
	| ITEnumField(_,ef) ->
		begin match follow ef.ef_type with
		| TFun _ -> 1,ef.ef_name
		| _ -> 0,ef.ef_name
		end
	| ITType(cm,_) -> 2,cm.name
	| ITModule s -> 3,s
	| ITPackage s -> 4,s
	| ITMetadata(s,_) -> 5,s
	| ITTimer(s,_) -> 6,s
	| ITLocal v -> 7,v.v_name
	| ITLiteral(s,_) -> 9,s
	| ITKeyword kwd -> 10,s_keyword kwd

let get_name = function
	| ITLocal v -> v.v_name
	| ITClassField(cf,_) | ITEnumAbstractField(_,cf) -> cf.cf_name
	| ITEnumField(_,ef) -> ef.ef_name
	| ITType(cm,_) -> cm.name
	| ITPackage s -> s
	| ITModule s -> s
	| ITLiteral(s,_) -> s
	| ITTimer(s,_) -> s
	| ITMetadata(s,_) -> s
	| ITKeyword kwd -> s_keyword kwd

let get_type = function
	| ITLocal v -> v.v_type
	| ITClassField(cf,_) | ITEnumAbstractField(_,cf) -> cf.cf_type
	| ITEnumField(_,ef) -> ef.ef_type
	| ITType(_,_) -> t_dynamic
	| ITPackage _ -> t_dynamic
	| ITModule _ -> t_dynamic
	| ITLiteral(_,t) -> t
	| ITTimer(_,_) -> t_dynamic
	| ITMetadata(_,_) -> t_dynamic
	| ITKeyword _ -> t_dynamic

let to_json ctx ck =
	let kind,data = match ck with
		| ITLocal v -> "Local",generate_tvar ctx v
		| ITClassField(cf,cfs) -> "ClassField",generate_class_field ctx cfs cf
		| ITEnumField(_,ef) -> "EnumField",generate_enum_field ctx ef
		| ITEnumAbstractField(_,cf) -> "EnumAbstractField",generate_class_field ctx CFSMember cf
		| ITType(kind,rm) -> "Type",CompletionModuleType.to_json ctx kind
		| ITPackage s -> "Package",jstring s
		| ITModule s -> "Module",jstring s
		| ITLiteral(s,t) -> "Literal",jobject [
			"name",jstring s;
			"type",generate_type ctx t;
		]
		| ITTimer(s,value) -> "Timer",jobject [
			"name",jstring s;
			"value",jstring value;
		]
		| ITMetadata(s,doc) -> "Metadata",jobject [
			"name",jstring s;
			"doc",jopt jstring doc;
		]
		| ITKeyword kwd ->"Keyword",jobject [
			"name",jstring (s_keyword kwd)
		]
	in
	generate_adt ctx None kind (Some data)