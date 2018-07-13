(*
	The Haxe Compiler
	Copyright (C) 2005-2018  Haxe Foundation

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 *)

open Ast
open Globals

type path = string list * string

type field_kind =
	| Var of var_kind
	| Method of method_kind

and var_kind = {
	v_read : var_access;
	v_write : var_access;
}

and var_access =
	| AccNormal
	| AccNo             (* can't be accessed outside of the class itself and its subclasses *)
	| AccNever          (* can't be accessed, even in subclasses *)
	| AccCtor           (* can only be accessed from the constructor *)
	| AccResolve        (* call resolve("field") when accessed *)
	| AccCall           (* perform a method call when accessed *)
	| AccInline         (* similar to Normal but inline when accessed *)
	| AccRequire of string * string option (* set when @:require(cond) fails *)

and method_kind =
	| MethNormal
	| MethInline
	| MethDynamic
	| MethMacro

type module_check_policy =
	| NoCheckFileTimeModification
	| CheckFileContentModification
	| NoCheckDependencies
	| NoCheckShadowing


type t =
	| TMono of t option ref
	| TEnum of tenum * tparams
	| TInst of tclass * tparams
	| TType of tdef * tparams
	| TFun of tsignature
	| TAnon of tanon
	| TDynamic of t
	| TLazy of tlazy ref
	| TAbstract of tabstract * tparams

and tlazy =
	| LAvailable of t
	| LProcessing of (unit -> t)
	| LWait of (unit -> t)

and tsignature = (string * bool * t) list * t

and tparams = t list

and type_params = (string * t) list

and tconstant =
	| TInt of int32
	| TFloat of string
	| TString of string
	| TBool of bool
	| TNull
	| TThis
	| TSuper

and tvar_extra = (type_params * texpr option) option

and tvar = {
	mutable v_id : int;
	mutable v_name : string;
	mutable v_type : t;
	mutable v_capture : bool;
	mutable v_extra : tvar_extra;
	mutable v_meta : metadata;
	v_pos : pos;
}

and tfunc = {
	tf_args : (tvar * tconstant option) list;
	tf_type : t;
	tf_expr : texpr;
}

and anon_status =
	| Closed
	| Opened
	| Const
	| Extend of t list
	| Statics of tclass
	| EnumStatics of tenum
	| AbstractStatics of tabstract

and tanon = {
	mutable a_fields : (string, tclass_field) PMap.t;
	a_status : anon_status ref;
}

and texpr_expr =
	| TConst of tconstant
	| TLocal of tvar
	| TArray of texpr * texpr
	| TBinop of Ast.binop * texpr * texpr
	| TField of texpr * tfield_access
	| TTypeExpr of module_type
	| TParenthesis of texpr
	| TObjectDecl of ((string * pos * quote_status) * texpr) list
	| TArrayDecl of texpr list
	| TCall of texpr * texpr list
	| TNew of tclass * tparams * texpr list
	| TUnop of Ast.unop * Ast.unop_flag * texpr
	| TFunction of tfunc
	| TVar of tvar * texpr option
	| TBlock of texpr list
	| TFor of tvar * texpr * texpr
	| TIf of texpr * texpr * texpr option
	| TWhile of texpr * texpr * Ast.while_flag
	| TSwitch of texpr * (texpr list * texpr) list * texpr option
	| TTry of texpr * (tvar * texpr) list
	| TReturn of texpr option
	| TBreak
	| TContinue
	| TThrow of texpr
	| TCast of texpr * module_type option
	| TMeta of metadata_entry * texpr
	| TEnumParameter of texpr * tenum_field * int
	| TEnumIndex of texpr
	| TIdent of string

and tfield_access =
	| FInstance of tclass * tparams * tclass_field
	| FStatic of tclass * tclass_field
	| FAnon of tclass_field
	| FDynamic of string
	| FClosure of (tclass * tparams) option * tclass_field (* None class = TAnon *)
	| FEnum of tenum * tenum_field

and texpr = {
	eexpr : texpr_expr;
	etype : t;
	epos : pos;
}

and tclass_field = {
	mutable cf_name : string;
	mutable cf_type : t;
	mutable cf_public : bool;
	cf_pos : pos;
	cf_name_pos : pos;
	mutable cf_doc : Ast.documentation;
	mutable cf_meta : metadata;
	mutable cf_kind : field_kind;
	mutable cf_params : type_params;
	mutable cf_expr : texpr option;
	mutable cf_expr_unoptimized : tfunc option;
	mutable cf_overloads : tclass_field list;
}

and tclass_kind =
	| KNormal
	| KTypeParameter of t list
	| KExpr of Ast.expr
	| KGeneric
	| KGenericInstance of tclass * tparams
	| KMacroType
	| KGenericBuild of class_field list
	| KAbstractImpl of tabstract

and metadata = Ast.metadata

and tinfos = {
	mt_path : path;
	mt_module : module_def;
	mt_pos : pos;
	mt_name_pos : pos;
	mt_private : bool;
	mt_doc : Ast.documentation;
	mutable mt_meta : metadata;
	mt_params : type_params;
}

and tclass = {
	mutable cl_path : path;
	mutable cl_module : module_def;
	mutable cl_pos : pos;
	mutable cl_name_pos : pos;
	mutable cl_private : bool;
	mutable cl_doc : Ast.documentation;
	mutable cl_meta : metadata;
	mutable cl_params : type_params;
	(* do not insert any fields above *)
	mutable cl_kind : tclass_kind;
	mutable cl_extern : bool;
	mutable cl_interface : bool;
	mutable cl_super : (tclass * tparams) option;
	mutable cl_implements : (tclass * tparams) list;
	mutable cl_fields : (string, tclass_field) PMap.t;
	mutable cl_statics : (string, tclass_field) PMap.t;
	mutable cl_ordered_statics : tclass_field list;
	mutable cl_ordered_fields : tclass_field list;
	mutable cl_dynamic : t option;
	mutable cl_array_access : t option;
	mutable cl_constructor : tclass_field option;
	mutable cl_init : texpr option;
	mutable cl_overrides : tclass_field list;

	mutable cl_build : unit -> build_state;
	mutable cl_restore : unit -> unit;
	(*
		These are classes which directly extend or directly implement this class.
		Populated automatically in post-processing step (Filters.run)
	*)
	mutable cl_descendants : tclass list;
}

and tenum_field = {
	ef_name : string;
	mutable ef_type : t;
	ef_pos : pos;
	ef_name_pos : pos;
	ef_doc : Ast.documentation;
	ef_index : int;
	mutable ef_params : type_params;
	mutable ef_meta : metadata;
}

and tenum = {
	mutable e_path : path;
	e_module : module_def;
	e_pos : pos;
	e_name_pos : pos;
	e_private : bool;
	e_doc : Ast.documentation;
	mutable e_meta : metadata;
	mutable e_params : type_params;
	(* do not insert any fields above *)
	e_type : tdef;
	mutable e_extern : bool;
	mutable e_constrs : (string , tenum_field) PMap.t;
	mutable e_names : string list;
}

and tdef = {
	t_path : path;
	t_module : module_def;
	t_pos : pos;
	t_name_pos : pos;
	t_private : bool;
	t_doc : Ast.documentation;
	mutable t_meta : metadata;
	mutable t_params : type_params;
	(* do not insert any fields above *)
	mutable t_type : t;
}

and tabstract = {
	mutable a_path : path;
	a_module : module_def;
	a_pos : pos;
	a_name_pos : pos;
	a_private : bool;
	a_doc : Ast.documentation;
	mutable a_meta : metadata;
	mutable a_params : type_params;
	(* do not insert any fields above *)
	mutable a_ops : (Ast.binop * tclass_field) list;
	mutable a_unops : (Ast.unop * unop_flag * tclass_field) list;
	mutable a_impl : tclass option;
	mutable a_this : t;
	mutable a_from : t list;
	mutable a_from_field : (t * tclass_field) list;
	mutable a_from_nothing : tclass_field option;
	mutable a_to : t list;
	mutable a_to_field : (t * tclass_field) list;
	mutable a_array : tclass_field list;
	mutable a_resolve : tclass_field option;
}

and module_type =
	| TClassDecl of tclass
	| TEnumDecl of tenum
	| TTypeDecl of tdef
	| TAbstractDecl of tabstract

and module_def = {
	m_id : int;
	m_path : path;
	mutable m_types : module_type list;
	m_extra : module_def_extra;
}

and module_def_extra = {
	m_file : string;
	m_sign : string;
	mutable m_check_policy : module_check_policy list;
	mutable m_time : float;
	mutable m_dirty : module_def option;
	mutable m_added : int;
	mutable m_mark : int;
	mutable m_deps : (int,module_def) PMap.t;
	mutable m_processed : int;
	mutable m_kind : module_kind;
	mutable m_binded_res : (string, string) PMap.t;
	mutable m_reuse_macro_calls : string list;
	mutable m_if_feature : (string *(tclass * tclass_field * bool)) list;
	mutable m_features : (string,bool) Hashtbl.t;
}

and module_kind =
	| MCode
	| MMacro
	| MFake
	| MExtern
	| MImport

and build_state =
	| Built
	| Building of tclass list
	| BuildMacro of (unit -> unit) list ref

and lifted_type =
	| LTNested of t * (lifted_type list)
	| LTFunc of t * (lifted_type list) * (lifted_type option)
	| LTLeaf of t
	| LTNestedMono of t * (lifted_type list)

type basic_types = {
	mutable tvoid : t;
	mutable tint : t;
	mutable tfloat : t;
	mutable tbool : t;
	mutable tnull : t -> t;
	mutable tstring : t;
	mutable tarray : t -> t;
}

(* ======= General utility ======= *)

let log_enabled = ref false

let log_type_ref = ref (fun t -> "")

let log_lifted_type_ref = ref (fun t -> "")

let log_normalized_type_ref = ref (fun t -> "")

let log_pad s =
	(let r = ref s in
	(while String.length (!r) < 20 do
		r := (!r) ^ " ";
	done;
	(!r)))

let log_code_red = "\027[31m"
let log_code_light_red = "\027[91m"
let log_code_light_green = "\027[92m"
let log_code_light_blue = "\027[94m"
let log_code_green = "\027[32m"
let log_code_blue = "\027[34m"
let log_code_cyan = "\027[36m"
let log_code_reset = "\027[39m"

let log_code_inverse = "\027[7"
let log_code_inverse_reset = "\027[27"

let log_type prefix t =
	let enabled = !log_enabled in
	let st = !log_type_ref in
	if enabled then
		Printf.printf ("%s: %s%s%s\n")
		(log_pad prefix)
		log_code_green (st t) log_code_reset;
	()

let log_normalized_type prefix t =
	let enabled = !log_enabled in
	let st = !log_normalized_type_ref in
	if enabled then
		Printf.printf ("%s: %s%s%s\n")
		(log_pad prefix)
		log_code_light_blue (st t) log_code_reset;
	()

let log_lifted_type prefix lt =
	let enabled = !log_enabled in
	let st = !log_lifted_type_ref in
	if enabled then
		Printf.printf ("%s: %s%s%s\n")
		(log_pad prefix)
		log_code_cyan (st lt) log_code_reset;
	()


let alloc_var =
	let uid = ref 0 in
	(fun n t p -> incr uid; { v_name = n; v_type = t; v_id = !uid; v_capture = false; v_extra = None; v_meta = []; v_pos = p })

let alloc_mid =
	let mid = ref 0 in
	(fun() -> incr mid; !mid)

let mk e t p = { eexpr = e; etype = t; epos = p }

let mk_block e =
	match e.eexpr with
	| TBlock _ -> e
	| _ -> mk (TBlock [e]) e.etype e.epos

let mk_cast e t p = mk (TCast(e,None)) t p

let null t p = mk (TConst TNull) t p

let mk_mono() = TMono (ref None)

let rec t_dynamic = TDynamic t_dynamic

let mk_anon fl = TAnon { a_fields = fl; a_status = ref Closed; }

(* We use this for display purposes because otherwise we never see the Dynamic type that
   is defined in StdTypes.hx. This is set each time a typer is created, but this is fine
   because Dynamic is the same in all contexts. If this ever changes we'll have to review
   how we handle this. *)
let t_dynamic_def = ref t_dynamic

let tfun pl r = TFun (List.map (fun t -> "",false,t) pl,r)

let fun_args l = List.map (fun (a,c,t) -> a, c <> None, t) l

let mk_class m path pos name_pos =
	{
		cl_path = path;
		cl_module = m;
		cl_pos = pos;
		cl_name_pos = name_pos;
		cl_doc = None;
		cl_meta = [];
		cl_private = false;
		cl_kind = KNormal;
		cl_extern = false;
		cl_interface = false;
		cl_params = [];
		cl_super = None;
		cl_implements = [];
		cl_fields = PMap.empty;
		cl_ordered_statics = [];
		cl_ordered_fields = [];
		cl_statics = PMap.empty;
		cl_dynamic = None;
		cl_array_access = None;
		cl_constructor = None;
		cl_init = None;
		cl_overrides = [];
		cl_build = (fun() -> Built);
		cl_restore = (fun() -> ());
		cl_descendants = [];
	}

let module_extra file sign time kind policy =
	{
		m_file = file;
		m_sign = sign;
		m_dirty = None;
		m_added = 0;
		m_mark = 0;
		m_time = time;
		m_processed = 0;
		m_deps = PMap.empty;
		m_kind = kind;
		m_binded_res = PMap.empty;
		m_reuse_macro_calls = [];
		m_if_feature = [];
		m_features = Hashtbl.create 0;
		m_check_policy = policy;
	}


let mk_field name t p name_pos = {
	cf_name = name;
	cf_type = t;
	cf_pos = p;
	cf_name_pos = name_pos;
	cf_doc = None;
	cf_meta = [];
	cf_public = true;
	cf_kind = Var { v_read = AccNormal; v_write = AccNormal };
	cf_expr = None;
	cf_expr_unoptimized = None;
	cf_params = [];
	cf_overloads = [];
}

let null_module = {
		m_id = alloc_mid();
		m_path = [] , "";
		m_types = [];
		m_extra = module_extra "" "" 0. MFake [];
	}

let null_class =
	let c = mk_class null_module ([],"") null_pos null_pos in
	c.cl_private <- true;
	c

let null_field = mk_field "" t_dynamic null_pos null_pos

let null_abstract = {
	a_path = ([],"");
	a_module = null_module;
	a_pos = null_pos;
	a_name_pos = null_pos;
	a_private = true;
	a_doc = None;
	a_meta = [];
	a_params = [];
	a_ops = [];
	a_unops = [];
	a_impl = None;
	a_this = t_dynamic;
	a_from = [];
	a_from_field = [];
	a_from_nothing = None;
	a_to = [];
	a_to_field = [];
	a_array = [];
	a_resolve = None;
}

let of_type =
	let mk_tp x =
		let c = { null_class with
			cl_kind = KTypeParameter [];
			cl_path = (["-Of"],x);
		} in
		x, TInst (c, [])
	in
	let a_path = ([], "-Of") in
	let a_params = [mk_tp "M"; mk_tp "A"] in
	{ null_abstract with a_path = a_path; a_params = a_params; a_private = false }

let add_dependency m mdep =
	if m != null_module && m != mdep then m.m_extra.m_deps <- PMap.add mdep.m_id mdep m.m_extra.m_deps

let arg_name (a,_) = a.v_name

let t_infos t : tinfos =
	match t with
	| TClassDecl c -> Obj.magic c
	| TEnumDecl e -> Obj.magic e
	| TTypeDecl t -> Obj.magic t
	| TAbstractDecl a -> Obj.magic a

let t_path t = (t_infos t).mt_path

let rec is_parent csup c =
	if c == csup || List.exists (fun (i,_) -> is_parent csup i) c.cl_implements then
		true
	else match c.cl_super with
		| None -> false
		| Some (c,_) -> is_parent csup c

let add_descendant c descendant =
	c.cl_descendants <- descendant :: c.cl_descendants

let lazy_type f =
	match !f with
	| LAvailable t -> t
	| LProcessing f | LWait f -> f()

let lazy_available t = LAvailable t
let lazy_processing f = LProcessing f
let lazy_wait f = LWait f

let map loop t =
	match t with
	| TMono r ->
		(match !r with
		| None -> t
		| Some t -> loop t) (* erase*)
	| TEnum (_,[]) | TInst (_,[]) | TType (_,[]) ->
		t
	| TEnum (e,tl) ->
		TEnum (e, List.map loop tl)
	| TInst (c,tl) ->
		TInst (c, List.map loop tl)
	| TType (t2,tl) ->
		TType (t2,List.map loop tl)
	| TAbstract (a,tl) ->
		TAbstract (a,List.map loop tl)
	| TFun (tl,r) ->
		TFun (List.map (fun (s,o,t) -> s, o, loop t) tl,loop r)
	| TAnon a ->
		let fields = PMap.map (fun f -> { f with cf_type = loop f.cf_type }) a.a_fields in
		begin match !(a.a_status) with
			| Opened ->
				a.a_fields <- fields;
				t
			| _ ->
				TAnon {
					a_fields = fields;
					a_status = a.a_status;
				}
		end
	| TLazy f ->
		let ft = lazy_type f in
		let ft2 = loop ft in
		if ft == ft2 then t else ft2
	| TDynamic t2 ->
		if t == t2 then	t else TDynamic (loop t2)

let dup t =
	let monos = ref [] in
	let rec loop t =
		match t with
		| TMono ({ contents = None } as r) ->
			(try
				List.assq r !monos
			with Not_found ->
				let m = mk_mono() in
				monos := (r,m) :: !monos;
				m)
		| _ ->
			map loop t
	in
	loop t

(* substitute parameters with other types *)
let apply_params cparams params t =
	match cparams with
	| [] -> t
	| _ ->
	let rec loop l1 l2 =
		match l1, l2 with
		| [] , [] -> []
		| (x,TLazy f) :: l1, _ -> loop ((x,lazy_type f) :: l1) l2
		| (_,t1) :: l1 , t2 :: l2 -> (t1,t2) :: loop l1 l2
		| _ -> assert false
	in
	let subst = loop cparams params in
	let rec loop t =
		try
			List.assq t subst
		with Not_found ->
		match t with
		| TMono r ->
			(match !r with
			| None -> t
			| Some t -> loop t)
		| TEnum (e,tl) ->
			(match tl with
			| [] -> t
			| _ -> TEnum (e,List.map loop tl))
		| TType (t2,tl) ->
			(match tl with
			| [] -> t
			| _ -> TType (t2,List.map loop tl))
		| TAbstract (a,tl) ->
			(match tl with
			| [] -> t
			| _ -> TAbstract (a,List.map loop tl))
		| TInst (c,tl) ->
			(match tl with
			| [] ->
				t
			| [TMono r] ->
				(match !r with
				| Some tt when t == tt ->
					(* for dynamic *)
					let pt = mk_mono() in
					let t = TInst (c,[pt]) in
					(match pt with TMono r -> r := Some t | _ -> assert false);
					t
				| _ -> TInst (c,List.map loop tl))
			| _ ->
				TInst (c,List.map loop tl))
		| TFun (tl,r) ->
			TFun (List.map (fun (s,o,t) -> s, o, loop t) tl,loop r)
		| TAnon a ->
			let fields = PMap.map (fun f -> { f with cf_type = loop f.cf_type }) a.a_fields in
			begin match !(a.a_status) with
				| Opened ->
					a.a_fields <- fields;
					t
				| _ ->
					TAnon {
						a_fields = fields;
						a_status = a.a_status;
					}
			end
		| TLazy f ->
			let ft = lazy_type f in
			let ft2 = loop ft in
			if ft == ft2 then
				t
			else
				ft2
		| TDynamic t2 ->
			if t == t2 then
				t
			else
				TDynamic (loop t2)
	in
	loop t

let monomorphs eparams t =
	apply_params eparams (List.map (fun _ -> mk_mono()) eparams) t

let rec follow t =
	match t with
	| TMono r ->
		(match !r with
		| Some t -> follow t
		| _ -> t)
	| TAbstract({a_path=[],"-Of"},[_;_]) ->

			reduce_of t

		(*if is_of_type t then t else follow t*)
	| TLazy f ->
		follow (lazy_type f)
	| TType (t,tl) ->
		follow (apply_params t.t_params tl t.t_type)
	| TAbstract({a_path = [],"Null"},[t]) ->
		follow t
	| _ -> t

and follow1 t =
	match t with
	| TMono r ->
		(match !r with
		| Some t -> follow1 t
		| _ -> t)
	| TLazy f ->
		follow1 (lazy_type f)
	| TType (t,tl) as t1 ->
		begin match (apply_params t.t_params tl t.t_type) with
		| TAnon(_) -> t1
		| t -> follow1 t
		end
	| TAbstract({a_path = [],"Null"},[t]) ->
		follow1 t
	| _ -> t

and t_in_abstract =
	let a_path = ([], "-In") in
	let a_params = [] in
	TAbstract ({ null_abstract with a_path = a_path; a_params = a_params; a_private = false }, [])

and t_in = ref t_in_abstract



and is_in_type t = match follow1 t with
	| TLazy f -> is_in_type (lazy_type f)
	| TAbstract({a_path=[],"-In"},_) -> true
	| TInst({ cl_kind = KGenericInstance({cl_path=[],"-In"}, [])},[]) ->
		true
	| TInst({cl_path=[],"-In"},_) -> true (* Parameters of Type Parameters like M<In> are currently not mapped *)
	| TMono r ->
		(match !r with
		| Some t -> is_in_type t
		| _ -> false)
	| t when t == !t_in -> true
	| t -> false

and is_of_type t = match t with
	| TAbstract({ a_path = [], "-Of"},_) -> true
	| TLazy f -> is_of_type (lazy_type f)
	| TMono r ->
		(match !r with
		| Some t -> is_of_type t
		| _ -> false)
	| t -> false

(* tries to unapply the leftmost In type of t with ta and unapplies nested Ofs recursively.
   It returns a tuple (t,a) where t is the resulting type and a indicates that a
   replacement of In actually happened. if In cannot be replaced t is left untouched.
   If the reversible flag is true the In type is only unapplied for types which met the following critera:

   1) Types with only one In type which is also the topmost right type parameter like:
   	  A->In, A->B->In, Either<A,In>, Array<In>

   	  but not types like: In->A, In->B

   2) Types with multiple In parameters but only if all of them located on the right like:
   	  A->In->In, Multi<X, Y, In, In>

   	  but not types like In->A->In etc.

   Examples:
   unapply_in A->In B 				false|true 	=> A->B, true
   unapply_in In->In B 				false|true 	=> B->In, true
   unapply_in In->A B 				true 		=> In->A, false (this fails because the application is ambiguous and thus not reversible)
   unapply_in In->A B 				false 		=> B->A, true (it gets only replaced if reversible is false)
   unapply_in Of<In->In>,A> B 		false|true 	=> A->B, true
   unapply_in Of<Map<In,In>, A> B 	false|true 	=> Map<A,B>, true
   unapply_in Map<Int, String> A 	false|true 	=> String, false

*)

and unapply_in t ta =

	(* replaces/unnapplies the leftmost In type and returns the unapplied list and a flag which
	   indicates if an In type was really replaced
	 *)
	let unapply_left tl =
		let rec loop r = match r with
			| t :: [] when is_in_type t -> true, ta::[]
			| t :: tl when is_in_type t ->
				if not (List.for_all is_in_type tl) then
					false, r
				else
					true, ta::tl
			| t :: tl when not (is_in_type t) ->
				(let d, tl = loop tl in
				d, t::tl)
			| [] -> false, []
			| _ -> assert false
		in
		let d, r = loop ( tl) in
		d,  r
	in
	let rec loop t = match t with
		| TInst(c,tl) ->
			(match unapply_left tl with
			| true, x -> TInst(c,x), true
			| _ -> t, false)
		| TEnum(en,tl) ->
			(match unapply_left tl with
			| true, x -> TEnum(en,x), true
			| _ -> t, false)
		| TType(tt,tl) ->
			(match unapply_left tl with
			| true, x -> TType(tt,x), true
			| _ -> t, false)
		(* Allow G<F<A>> to unify with T<A> for implementations *)
		| TAbstract({a_path=[],"-Of"} as a,[tm1 ;(TAbstract({a_path=[],"-Of"},[c1;inner]) as tm2)]) ->
			if is_in_type inner then
				reduce_of (TAbstract(a, [tm1; reduce_of (TAbstract(a, [c1; ta]))])), true
			else
				(*(let inner = reduce_of (TAbstract(a, [c1; inner])) in
				let t = reduce_of (TAbstract(a, [tm1; inner])) in
				loop(t))*)
				(match unapply_in inner ta with
				| t, true ->
					reduce_of (TAbstract(a, [tm1; reduce_of (TAbstract(a, [c1; t]))])), true
				| _, false -> t, false)
		(* End Allow G<F<A>> *)
		| TAbstract({a_path=[],"-Of"},[tm;tx]) ->
			(* unapply In types in nested Ofs like Of<Of<In->In>, A, B> *)
			(match unapply_in tm (reduce_of tx) with
			| _, false -> t, false
			| TAbstract({a_path=[],"-Of"},[_;_]), _ -> t, false (* cannot unapply In in this Of type *)
			| x, _ -> unapply_in x ta)
		| TAbstract(a,tl) ->
			let d, x = unapply_left tl in
			if d then TAbstract(a,x), true else t, false
		| TFun(t1,t2) ->
			(* concat all types, call unapply_left (avoids multiple List.rev), combine resulting types to TFun parameters *)
			let p_type (a,b,t) = t in
			let d,tl = unapply_left ((List.map p_type t1)@[t2]) in
			(if d then
				(match List.rev tl with
				| tret :: tparams ->
					let tl = List.map2 (fun (a,b,_) t -> a,b,t) t1 (List.rev tparams) in
					TFun(tl,tret), true
				| [] -> assert false)
			else
				t, false)
		| TMono r ->
			(match !r with
			| Some t -> loop t
			| _ -> t, false)
		| TLazy f ->
			loop (lazy_type f)
		| TDynamic _ | TAnon _ ->
			t, false
	in
	loop t

and unapply_in_constraints tm ta =
	let rec loop t =
		match follow t with
		| TAbstract ({a_path=[],"-Of"},[tm1; ta1]) ->
			loop (unapply_in_constraints tm1 ta1)
		| TInst (c,params) ->
			let new_kind = match c.cl_kind with
			| KTypeParameter tp ->
				let unapply t =
					let t1,applied = unapply_in t (reduce_of ta) in
					if applied then t1 else t
				in
				KTypeParameter (List.map unapply tp)
			| _ -> c.cl_kind
			in
			TInst({c with cl_kind = new_kind}, params)
		| TLazy f -> loop (lazy_type f)
		| t -> t
	in
	loop tm

(*
	try to convert/reduce an Of type to a regular type by replacing all In types,
	if t is not an Of type (e.g. it is a regular type like String) or it contains no In types like Of<M,A>
	t is returned untouched.

	If the reversible flag is true Of types are only reduced when the reduction process doesn't loose the information how they were lifted before.

	e.g.
	reduce_of Of<Of<In->In>, A, B> true|false => A->B
	reduce_of Of<Of<Map<In,In>, A, B> true|false => Map<A,B>
	reduce_of Of<In->A, B> false => B->A
	reduce_of Of<In->A, B> true => Of<In->A, B> 	(this fails because the reduced type B->A is by default lifted to Of<B->In, A>
												 	 which is the regular right-application of the In type (see unify_of)).


	This function does not check if the resulting reduced type is actually valid (important, because it could
	be a nested reduction), e.g.
	reduce_of Of<In->In, A> true|false => A->In
*)

and mk_of tm tp =
	TAbstract(of_type, [tm; tp])

and link e a b =
	(* tell if setting a == b will create a type-loop *)
	let rec loop t =
		if t == a then
			true
		else match t with
		| TMono t -> (match !t with None -> false | Some t -> loop t)
		| TEnum (_,tl) -> List.exists loop tl
		| TInst (_,tl) | TType (_,tl) | TAbstract (_,tl) -> List.exists loop tl
		| TFun (tl,t) -> List.exists (fun (_,_,t) -> loop t) tl || loop t
		| TDynamic t2 ->
			if t == t2 then
				false
			else
				loop t2
		| TLazy f ->
			loop (lazy_type f)
		| TAnon a ->
			try
				PMap.iter (fun _ f -> if loop f.cf_type then raise Exit) a.a_fields;
				false
			with
				Exit -> true
	in
	(* tell is already a ~= b *)
	if loop b then
		(follow b) == a
	else if b == t_dynamic then
		true
	else begin
		e := Some b;
		true
	end

and unapply_in1_right t ta =
	unapply_in1_custom t ta true
and unapply_in1 t ta  =
	unapply_in1_custom t ta false

and unapply_in1_custom t ta right =
	let t_orig = t in
	let unapply_in1 t ta = unapply_in1_custom t ta right in
	(* replaces/unnapplies the leftmost In type and returns the unapplied list and a flag which
	   indicates if an In type was really replaced
	 *)
	let unapply_left tl =
		let rec loop r = match r with
			| t :: [] when is_in_type t -> ta::[]
			| t :: tl when is_in_type t ->
				let only_trailing_ins = List.for_all is_in_type tl in
				if not only_trailing_ins && (not right) then begin
					Printf.printf "%s\n" (s_type (print_context()) t_orig);
					Printf.printf "%s\n" (s_type (print_context()) t);
					Printf.printf "%s\n" (s_type (print_context()) ta);
					assert false
				end else
					ta::tl
			| t :: tl when not (is_in_type t) ->
				(* t could be Option<_> *)
				(*begin try
					let t = unapply_in1 t ta in
					t::tl
				with Not_found ->*)
					let tl = loop tl in
					t::tl
				(*end*)
			| [] ->
				(* maybe we have to create an of type here *)
				let st = s_type (print_context()) in
				(*Printf.printf "WHAT2: %s %s\n" (st t) (st ta);*)
				raise Not_found
			| _ -> assert false
		in
		let r = begin try
			let tl = if right then List.rev tl else tl in
			let tl = loop tl in
			if right then List.rev tl else tl
		with Not_found ->
				raise Not_found
		end
		in
		r
	in
	let rec loop t = match t with
		| TInst({ cl_kind = KGenericInstance(c, tl)} as c1,[]) ->
			TInst({ c1 with cl_kind = KGenericInstance(c, unapply_left tl) },[])
		| TInst(c,tl) ->
			TInst(c, unapply_left tl)
		| TEnum(en,tl) ->
			TEnum(en,unapply_left tl)
		| TType(tt,tl) ->
			TType(tt,unapply_left tl)
		| TAbstract({a_path=[],"-Of"},[tm;tx]) when is_in_type tx ->
			mk_of tm ta
		| TAbstract({a_path=[],"-Of"},[tm;tx]) ->
			loop tm
		| TAbstract(a,tl) ->
			TAbstract(a,unapply_left tl)
		(* TODO: This allows application _ -> Void, not 100% sure if that should be supported *)
		| TFun(t1,(TAbstract({a_path=[],"Void"},_) as tret)) ->
			(* concat all types, call unapply_left (avoids multiple List.rev), combine resulting types to TFun parameters *)
			let p_type (a,b,t) = t in
			let tl = unapply_left (List.map p_type t1) in
			let t1 = List.map2 (fun (a,b,_) t -> a,b,t) t1 tl in
			TFun(t1,tret)
		| TFun(t1,t2) ->
			(* concat all types, call unapply_left (avoids multiple List.rev), combine resulting types to TFun parameters *)
			let p_type (a,b,t) = t in
			let tl = unapply_left ((List.map p_type t1)@[t2]) in
			begin match List.rev tl with
				| tret :: tparams ->
					let tl = List.map2 (fun (a,b,_) t -> a,b,t) t1 (List.rev tparams) in
					TFun(tl,tret)
				| [] -> assert false
			end

		| TMono r ->
			begin match !r with
				| Some t -> loop t
				| _ ->
					raise Not_found
			end
		| TLazy f ->
			loop (lazy_type f)
		| TDynamic _ | TAnon _ ->
			assert false
	in
	loop t

and reduce_lifted_type (t : lifted_type) : t =
	match t with
	| LTNested(t, params) ->
		let params = List.map reduce_lifted_type params in
		begin match follow1 t, params with
			| TInst({ cl_kind = KTypeParameter _}, []) as t, _ ->
				List.fold_left (fun acc p -> mk_of acc p) t params
			| TInst({ cl_kind = KGenericInstance(c, tl)} as c1,[]),_ ->
				TInst({ c1 with cl_kind = KGenericInstance(c, params) },[])
			| TInst(c,_), _ ->
				TInst(c, params)
			| TEnum(e,_), _ ->
				TEnum(e, params)
			| TType(t,_), _ ->
				TType(t, params)
			| TAbstract(e,_), _ ->
				TAbstract(e, params)
			| TMono _ as t, [p] ->
				assert false
				(*mk_of t p*)
			| _ ->
				let st = s_type (print_context()) in
				Printf.printf "WHAT1: %s\n" (st t);
				assert false
				(*let rparams = params in
				let t = List.fold_left (fun acc p -> unapply_in1 acc p) t rparams in
				t*)
		end
	| LTNestedMono(t, tp) ->
		List.fold_left (fun a p -> mk_of a (reduce_lifted_type p)) t tp
	| LTFunc(TFun(args, r), params, None) ->
		let params = List.map reduce_lifted_type params in
		let params = List.fold_left2 (fun acc (s,o,_) b -> (s,o,b)::acc ) [] args params in
		TFun(List.rev params, r)
	| LTFunc(TFun(args, _), params, Some r) ->
		let params = List.map reduce_lifted_type params in
		let r = reduce_lifted_type r in
		let params = List.fold_left2 (fun acc (s,o,_) b -> (s,o,b)::acc ) [] args params in
		TFun(List.rev params, r)
	| LTLeaf(t) ->
		t
	| _ -> assert false


and normalize_of_type t =
	let not_in t = not (is_in_type t) in
	let not_of t = not (is_of_type t) in
	let rec loop t =
		match follow1 t with
		| TAbstract({a_path=[],"-Of"}, [tm; TAbstract({a_path=[],"-Of"}, [tm2; tp])]) ->
			let tm =  mk_of tm tm2 in
			loop (mk_of tm (normalize_of_type tp))
		(*| TAbstract({a_path=[],"-Of"}, [TAbstract({a_path=[],"-Of"}, [tm2;tp2]) as tm; tp]) when not_of tp -> (* tp is not an of type here *)
			let loop1 =

				let tm = tm in
				(try
					loop (unapply_in1_left tm tp)
				with Not_found ->
					mk_of tm tp)
		*)
		| TAbstract({a_path=[],"-Of"}, [tm; tp]) when not_of tp ->
			let rec loop1 t1 tp1 = match follow1 t1 with
			| TAbstract({a_path=[],"-Of"}, [t2; tp2]) ->
				(match tp1 with
				| x::tail ->
					let tp1 = (try
						 (unapply_in1 tp2 x )::tail
					with Not_found ->
						tp2::tp1)
					in
					loop1 t2 tp1
				| _ ->
					loop1 t2 (tp2::tp1))
			| TInst({ cl_kind = KGenericInstance(c, tl)} as c1,[]) ->
				List.fold_left (fun acc p -> unapply_in1 acc p ) t1 tp1
			| TInst(_, []) ->
				raise Not_found
			| TInst(_, _) | TEnum(_, _) | TAbstract(_, _) | TFun(_,_) | TType(_,_) ->
				(*let rec loop2 t1 tp1 = match tp1 with
				| x::y::tail
					let t1 = unapply_in1 y x in
					loop2 (t1::tail)
				| y::[]
					y
				| _ -> assert false
				in
				loop2 List.rev (t1::tp1)*)
				List.fold_left (fun acc p -> unapply_in1 acc p ) t1 tp1
			| TMono t ->
				raise Not_found
			| _ ->
				assert false
			in
			(try
				loop1 tm [tp]
			with Not_found ->
				mk_of tm tp)

			(*begin match follow1 tp with
			(*| TInst(i, [a]) when not_in a ->
				let tp = TInst(i, [!t_in]) in
				let t = mk_of tm (mk_of tp a) in
				normalize_of_type t*)
			| _ ->
				(try
						loop (unapply_in1_right tm tp)
				with Not_found ->
					mk_of tm tp
				)
			end*)
		| t -> t
	in
	let res = loop t in
	(*begin match res with
		| TAbstract({a_path=[],"-Of"}, [tm; tp]) ->
			(match follow1 tm with
			| TEnum(_, _) ->
				(try unapply_in1 tm tp with _ -> assert false);
				()

			| TInst(_, a::tl) ->
				(try unapply_in1 tm tp with _ -> assert false);
				()
			| TAbstract({a_path=[],"-Of"}, _) -> ()
			| TAbstract(_, _) ->
				(try unapply_in1 tm tp
					with _ ->
					let st = s_type (print_context()) in
					Printf.printf "ERROR: %s => %s\n" (st t) (st res);
					assert false);
				()
			| _ -> ())
		| _ -> ()
	end;*)
	res

and validate_lifted t =
	let check_params p params =
		begin
		(if (List.length p) <> (List.length params) then
			(Printf.printf "VALIDATION ERROR!!!!\n";
			raise Exit)
		else
			t);
		List.iter (fun t -> (validate_lifted t; ())) params;
		t
		end
	in
	match t with
	| LTNested(TEnum(_, p), params) ->
		check_params p params
	| LTNested(TInst({ cl_kind = KGenericInstance(_, p)}, []), params) ->
		check_params p params
	| LTNested(TInst(_, p), params) when (List.length p) > 0 ->
		check_params p params
	| LTNested(TAbstract(_, p), params) ->
		check_params p params
	| LTFunc(TFun(args, ret), args2, ret2) ->
		check_params args args2
	| LTNested(t1, params) ->
		(match follow1 t1 with
		| TEnum _ ->
			(Printf.printf "VALIDATION ERROR!!!!\n";
			assert false;
			raise Exit)
		| _ -> t)
	| _ -> t;


and lift_type (t : t) : lifted_type =
		(*let st = s_type (print_context()) in
		Printf.printf "normalize\n%s\n%s\n" (st t) (st (normalize_of_type t));*)
		lift_type1 (normalize_of_type t)
and lift_type1 (t : t) : lifted_type =

	(*let st = s_type (print_context()) in
	Printf.printf "DO Lift: %s\n" (st (follow1 t));*)
	let ft = t in
	let t_in = !t_in in
	let t = (follow1 t) in
	match t with
	(*| TAbstract({a_path=[],"-Of"}, [tm; TAbstract({a_path=[],"-Of"}, [tm2; tp])]) ->
		lift_type (mk_of (mk_of tm tm2) tp)*)
	| TAbstract({a_path=[],"-Of"}, [tm; tp]) ->

		(*let st = s_type (print_context()) in
		Printf.printf "%s\n" (st (follow tm));*)
		let tm = (follow1 tm) in
		begin match tm with
			| TInst({ cl_kind = KGenericInstance(_, _)},[]) when not (is_in_type tp) ->
				(try
					validate_lifted (lift_type1 (unapply_in1_right tm tp))
				with (Not_found as e) ->
					(* raise e *)
					LTNested(tm, [lift_type1 tp])
				)
			| TInst(_, []) as a ->
				validate_lifted (LTNested(tm, [lift_type1 tp]))
			| TEnum(_, _) when not (is_in_type tp) ->
				let st = s_type (print_context()) in
				let before = st t in
				(try

					validate_lifted (lift_type1 (unapply_in1_right tm tp))
				with (Not_found as e) ->

					Printf.printf "enum failed %s\n" before;
					LTNested(tm, [lift_type1 tp])
					(* raise e *)

				)


			| TInst(_, _) when not (is_in_type tp) ->
				(try
					validate_lifted (lift_type1 (unapply_in1_right tm tp))
				with (Not_found as e) ->
					(* raise e *)
					LTNested(tm, [lift_type1 tp])
				)
			| TType(_, _) when not (is_in_type tp) ->
				(try
					validate_lifted (lift_type1 (unapply_in1_right tm tp))
				with (Not_found as e) ->
					(* raise e *)
					LTNested(tm, [lift_type1 tp])
				)
			| TFun(_, _) when not (is_in_type tp) ->
				(try
					validate_lifted (lift_type1 (unapply_in1_right tm tp))
				with (Not_found as e) ->
					(* raise e *)
					assert false
				)
			| TAbstract({a_path=[],"-Of"}, _) when not (is_in_type tp) ->
				begin
				let rec loop t tp =
					match follow1 t with
						(*| TAbstract({a_path=[],"-Of"}, [TMono _ as tm; tp1]) ->
							LTNestedMono ( tm, [lift_type1 tp1] )
							(*loop tm (tp1::tp)*)*)
						| TAbstract({a_path=[],"-Of"}, [tm; tp1]) ->
							loop tm (tp1::tp)

						| TInst({ cl_kind = KGenericInstance(_, _)},[]) ->
							validate_lifted (lift_type1 (List.fold_left (fun acc p -> unapply_in1_right acc p) t tp))
						| TInst(_, []) ->
							let params = tp in
							validate_lifted (LTNested( t, List.map lift_type1 params ))
						| TEnum(_, _) ->
							let t = lift_type1 (List.fold_left (fun acc p -> unapply_in1_right acc p) t tp) in
							validate_lifted t

						| TInst(_, _) ->
							validate_lifted (lift_type1 (List.fold_left (fun acc p -> unapply_in1_right acc p) t tp))
						| TType(_, _) ->
							validate_lifted (lift_type1 (List.fold_left (fun acc p -> unapply_in1_right acc p) t tp))

						| TAbstract(_, _) ->
							validate_lifted (lift_type1 (List.fold_left (fun acc p -> unapply_in1_right acc p) t tp))
						| TFun(_,_) ->
							validate_lifted (lift_type1 (List.fold_left (fun acc p -> unapply_in1_right acc p) t tp))
						| (TMono _) as tx ->
							(*let st = s_type (print_context()) in
							Printf.printf "tp: [%s]\n" (String.concat "," (List.map st tp));
							Printf.printf "tx: %s\n" (st tx);
							let rec loop1 tp = match tp with
								| tx::prev::[] ->
									LTNestedMono(tx, [lift_type1 prev])
								| cur::tail ->
									LTNestedMono(cur, [(loop1 tail)])
								| _ ->
									assert false

							in
							validate_lifted (loop1 (tx::List.rev tp ))*)
							let st = s_type (print_context()) in
							(*Printf.printf "tp: [%s]\n" (String.concat "," (List.map st tp));
							Printf.printf "tx: %s\n" (st tx);*)
							validate_lifted (LTNestedMono(tx, (List.map (fun p -> lift_type1 p) tp)))
						| _ ->
							let st = s_type (print_context()) in
							Printf.printf "%s => %s\n" (st t) (st tm);
							assert false
				in
				loop tm (tp ::[])
				end
			| TAbstract(_, _) as x when not (is_in_type tp) ->
				let st = s_type (print_context()) in
				Printf.printf "%s\n" (st x);
				(try
					validate_lifted (lift_type1 (unapply_in1_right tm tp))
				with (Not_found as e) ->
					raise e
				)
			| (TMono m) as tm ->
				validate_lifted (LTNestedMono(tm, [lift_type1 tp]))
			| _ (*when is_in_type tp*) ->
				validate_lifted (lift_type1 tm)
		end
	| TInst ({ cl_kind = KGenericInstance(c, tl)} as c1,[]) ->
		let tl1 = List.map (fun _ -> t_in) tl in
		let t1 = TInst({c1 with cl_kind = KGenericInstance(c, tl1) }, []) in
		validate_lifted (LTNested(t1, List.map lift_type1 tl))
	| TEnum (_,[]) | TInst (_,[]) | TAbstract (_,[]) | TType (_,[]) -> LTLeaf(t)

	| TAbstract (t1,tl) ->
		let t1 = TAbstract(t1, List.map (fun _ -> t_in) tl ) in
		validate_lifted (LTNested(t1, List.map lift_type1 tl))

	| TEnum (t1,tl) ->
		let st = s_type (print_context()) in
		(*Printf.printf "!!!!!! %s\n" (st t);*)
		let t1 = TEnum(t1, List.map (fun _ -> t_in) tl ) in
		(*Printf.printf "!!!!!! %s\n" (st t1);*)
		validate_lifted (LTNested(t1, List.map lift_type1 tl))

	| TInst (t1,tl) ->
		let t1 = TInst(t1, List.map (fun _ -> t_in) tl ) in
		validate_lifted (LTNested(t1, List.map lift_type1 tl))
	| TType (t1,tl) ->
		let t1 = TType(t1, List.map (fun _ -> t_in) tl ) in
		validate_lifted (LTNested(t1, List.map lift_type1 tl))

	| TFun (tl,r) ->
		let is_void = function
		| TAbstract({a_path=[],"Void"},_) -> true
		| _ -> false
		in
		let nr = if is_void r then r else t_in in
		let ltr = if is_void r then None else Some (lift_type1 r) in
		let t1 = TFun( (List.map (fun (s, o, _) -> s, o, t_in) tl ), nr) in
		validate_lifted (LTFunc(t1, List.map (fun (_,_,t) -> lift_type1 t) tl, ltr))

	| t ->
		LTLeaf(t)


and reduce_of t =
		match follow1 t with
		| TAbstract({a_path=[],"-Of"}, [tm; tp1]) ->
			begin try
				reduce_lifted_type (lift_type t)
			with Not_found ->
				t
			end
		| _ ->
			let st = s_type (print_context()) in
			(*Printf.printf "reduce_of: %s\n" (st t);*)
			t

and reduce_of_rec t =
	let rp = List.map reduce_of_rec in
	let t = match follow t with
	| TInst(c,tl) ->
		TInst(c, rp tl )
	| TEnum(en,tl) ->
		TEnum(en, rp tl)
	| TAbstract(a,tl) ->
		TAbstract( a, rp tl)
	| TType(ta, tl) ->
		TType( ta, rp tl)
	| TFun(p, r) ->
		TFun( List.map (fun (s, b, t) -> (s, b, reduce_of_rec t)) p, reduce_of_rec r )
	| _ ->
		t
	in
	reduce_of t
and try_reduce_of t =
		match follow1 t with
		| TAbstract({a_path=[],"-Of"}, [tm; tp1]) ->
			begin try
				Some(reduce_lifted_type (lift_type t))
			with Not_found ->
				None
			end
		| _ ->
			Some(t)



(*
and reduce_of t =
	match t with
	| TAbstract( ({a_path=[],"-Of"} as a),[tm;(TAbstract({a_path=[],"-Of"}, [tb; tx]))]) ->
		let tm1 = reduce_of (TAbstract(a, [tm; tb])) in
		reduce_of (TAbstract(a, [tm1; reduce_of tx]))
	| TAbstract({a_path=[],"-Of"},[tm;tr]) ->
		let x, applied = unapply_in tm (reduce_of tr) in
		if applied then reduce_of x else t
	| TMono r ->
		(match !r with
		| Some t -> reduce_of t
		| _ -> t)
	| TLazy f ->
		reduce_of (!f())
	| _ -> t
*)
and is_nullable = function
	| TMono r ->
		(match !r with None -> false | Some t -> is_nullable t)
	| TAbstract ({ a_path = ([],"Null") },[_]) ->
		true
	| TLazy f ->
		is_nullable (lazy_type f)
	| TType (t,tl) ->
		is_nullable (apply_params t.t_params tl t.t_type)
	| TFun _ ->
		false
(*
	Type parameters will most of the time be nullable objects, so we don't want to make it hard for users
	to have to specify Null<T> all over the place, so while they could be a basic type, let's assume they will not.

	This will still cause issues with inlining and haxe.rtti.Generic. In that case proper explicit Null<T> is required to
	work correctly with basic types. This could still be fixed by redoing a nullability inference on the typed AST.

	| TInst ({ cl_kind = KTypeParameter },_) -> false
*)
	| TAbstract (a,_) when Meta.has Meta.CoreType a.a_meta ->
		not (Meta.has Meta.NotNull a.a_meta)
	| TAbstract (a,tl) ->
		not (Meta.has Meta.NotNull a.a_meta) && is_nullable (apply_params a.a_params tl a.a_this)
	| _ ->
		true

and is_null ?(no_lazy=false) = function
	| TMono r ->
		(match !r with None -> false | Some t -> is_null t)
	| TAbstract ({ a_path = ([],"Null") },[t]) ->
		not (is_nullable (follow t))
	| TLazy f ->
		if no_lazy then raise Exit else is_null (lazy_type f)
	| TType (t,tl) ->
		is_null (apply_params t.t_params tl t.t_type)
	| _ ->
		false

(* Determines if we have a Null<T>. Unlike is_null, this returns true even if the wrapped type is nullable itself. *)
and is_explicit_null = function
	| TMono r ->
		(match !r with None -> false | Some t -> is_null t)
	| TAbstract ({ a_path = ([],"Null") },[t]) ->
		true
	| TLazy f ->
		is_null (lazy_type f)
	| TType (t,tl) ->
		is_null (apply_params t.t_params tl t.t_type)
	| _ ->
		false

and has_mono t = match t with
	| TMono r ->
		(match !r with None -> true | Some t -> has_mono t)
	| TInst(_,pl) | TEnum(_,pl) | TAbstract(_,pl) | TType(_,pl) ->
		List.exists has_mono pl
	| TDynamic _ ->
		false
	| TFun(args,r) ->
		has_mono r || List.exists (fun (_,_,t) -> has_mono t) args
	| TAnon a ->
		PMap.fold (fun cf b -> has_mono cf.cf_type || b) a.a_fields false
	| TLazy f ->
		has_mono (lazy_type f)

and concat e1 e2 =
	let e = (match e1.eexpr, e2.eexpr with
		| TBlock el1, TBlock el2 -> TBlock (el1@el2)
		| TBlock el, _ -> TBlock (el @ [e2])
		| _, TBlock el -> TBlock (e1 :: el)
		| _ , _ -> TBlock [e1;e2]
	) in
	mk e e2.etype (punion e1.epos e2.epos)

and is_closed a = !(a.a_status) <> Opened

and type_of_module_type = function
	| TClassDecl c -> TInst (c,List.map snd c.cl_params)
	| TEnumDecl e -> TEnum (e,List.map snd e.e_params)
	| TTypeDecl t -> TType (t,List.map snd t.t_params)
	| TAbstractDecl a -> TAbstract (a,List.map snd a.a_params)

and module_type_of_type = function
	| TInst(c,_) -> TClassDecl c
	| TEnum(en,_) -> TEnumDecl en
	| TType(t,_) -> TTypeDecl t
	| TAbstract(a,_) -> TAbstractDecl a
	| TLazy f -> module_type_of_type (lazy_type f)
	| TMono r ->
		(match !r with
		| Some t -> module_type_of_type t
		| _ -> raise Exit)
	| _ ->
		raise Exit

and tconst_to_const = function
	| TInt i -> Int (Int32.to_string i)
	| TFloat s -> Float s
	| TString s -> String s
	| TBool b -> Ident (if b then "true" else "false")
	| TNull -> Ident "null"
	| TThis -> Ident "this"
	| TSuper -> Ident "super"

and has_ctor_constraint c = match c.cl_kind with
	| KTypeParameter tl ->
		List.exists (fun t -> match follow t with
			| TAnon a when PMap.mem "new" a.a_fields -> true
			| TAbstract({a_path=["haxe"],"Constructible"},_) -> true
			| _ -> false
		) tl;
	| _ -> false

(* ======= Field utility ======= *)

and field_name f =
	match f with
	| FAnon f | FInstance (_,_,f) | FStatic (_,f) | FClosure (_,f) -> f.cf_name
	| FEnum (_,f) -> f.ef_name
	| FDynamic n -> n

and extract_field = function
	| FAnon f | FInstance (_,_,f) | FStatic (_,f) | FClosure (_,f) -> Some f
	| _ -> None

and is_physical_var_field f =
	match f.cf_kind with
	| Var { v_read = AccNormal | AccInline | AccNo } | Var { v_write = AccNormal | AccNo } -> true
	| Var _ -> Meta.has Meta.IsVar f.cf_meta
	| _ -> false

and is_physical_field f =
	match f.cf_kind with
	| Method _ -> true
	| _ -> is_physical_var_field f

and field_type f =
	match f.cf_params with
	| [] -> f.cf_type
	| l -> monomorphs l f.cf_type

and raw_class_field build_type c tl i =
	let apply = apply_params c.cl_params tl in
	try
		let f = PMap.find i c.cl_fields in
		Some (c,tl), build_type f , f
	with Not_found -> try (match c.cl_constructor with
		| Some ctor when i = "new" -> Some (c,tl), build_type ctor,ctor
		| _ -> raise Not_found)
	with Not_found -> try
		match c.cl_super with
		| None ->
			raise Not_found
		| Some (c,tl) ->
			let c2 , t , f = raw_class_field build_type c (List.map apply tl) i in
			c2, apply_params c.cl_params tl t , f
	with Not_found ->
		match c.cl_kind with
		| KTypeParameter tl ->
			let rec loop = function
				| [] ->
					raise Not_found
				| t :: ctl ->
					match follow t with
					| TAnon a ->
						(try
							let f = PMap.find i a.a_fields in
							None, build_type f, f
						with
							Not_found -> loop ctl)
					| TInst (c,tl) ->
						(try
							let c2, t , f = raw_class_field build_type c (List.map apply tl) i in
							c2, apply_params c.cl_params tl t, f
						with
							Not_found -> loop ctl)
					| _ ->
						loop ctl
			in
			loop tl
		| _ ->
			if not c.cl_interface then raise Not_found;
			(*
				an interface can implements other interfaces without
				having to redeclare its fields
			*)
			let rec loop = function
				| [] ->
					raise Not_found
				| (c,tl) :: l ->
					try
						let c2, t , f = raw_class_field build_type c (List.map apply tl) i in
						c2, apply_params c.cl_params tl t, f
					with
						Not_found -> loop l
			in
			loop c.cl_implements

and class_field tl i =
	raw_class_field field_type tl i

and quick_field t n =
	match follow t with
	| TInst (c,tl) ->
		let c, _, f = raw_class_field (fun f -> f.cf_type) c tl n in
		(match c with None -> FAnon f | Some (c,tl) -> FInstance (c,tl,f))
	| TAnon a ->
		(match !(a.a_status) with
		| EnumStatics e ->
			let ef = PMap.find n e.e_constrs in
			FEnum(e,ef)
		| Statics c ->
			FStatic (c,PMap.find n c.cl_statics)
		| AbstractStatics a ->
			begin match a.a_impl with
				| Some c ->
					let cf = PMap.find n c.cl_statics in
					FStatic(c,cf) (* is that right? *)
				| _ ->
					raise Not_found
			end
		| _ ->
			FAnon (PMap.find n a.a_fields))
	| TDynamic _ ->
		FDynamic n
	| TEnum _  | TMono _ | TAbstract _ | TFun _ ->
		raise Not_found
	| TLazy _ | TType _ ->
		assert false

and quick_field_dynamic t s =
	try quick_field t s
	with Not_found -> FDynamic s

and get_constructor build_type c =
	match c.cl_constructor, c.cl_super with
	| Some c, _ -> build_type c, c
	| None, None -> raise Not_found
	| None, Some (csup,cparams) ->
		let t, c = get_constructor build_type csup in
		apply_params csup.cl_params cparams t, c

(* ======= Printing ======= *)

and print_context () = ref []

and s_type_kind t =
	let map tl = String.concat ", " (List.map s_type_kind tl) in
	match t with
	| TMono r ->
		begin match !r with
			| None -> "TMono (None)"
			| Some t -> "TMono (Some (" ^ (s_type_kind t) ^ "))"
		end
	| TEnum(en,tl) -> Printf.sprintf "TEnum(%s, [%s])" (s_type_path en.e_path) (map tl)
	| TInst(c,tl) -> Printf.sprintf "TInst(%s, [%s])" (s_type_path c.cl_path) (map tl)
	| TType(t,tl) -> Printf.sprintf "TType(%s, [%s])" (s_type_path t.t_path) (map tl)
	| TAbstract(a,tl) -> Printf.sprintf "TAbstract(%s, [%s])" (s_type_path a.a_path) (map tl)
	| TFun(tl,r) -> Printf.sprintf "TFun([%s], %s)" (String.concat ", " (List.map (fun (n,b,t) -> Printf.sprintf "%s%s:%s" (if b then "?" else "") n (s_type_kind t)) tl)) (s_type_kind r)
	| TAnon an -> "TAnon"
	| TDynamic t2 -> "TDynamic"
	| TLazy _ -> "TLazy"

and s_module_type_kind = function
	| TClassDecl c -> "TClassDecl(" ^ (s_type_path c.cl_path) ^ ")"
	| TEnumDecl en -> "TEnumDecl(" ^ (s_type_path en.e_path) ^ ")"
	| TAbstractDecl a -> "TAbstractDecl(" ^ (s_type_path a.a_path) ^ ")"
	| TTypeDecl t -> "TTypeDecl(" ^ (s_type_path t.t_path) ^ ")"

and s_type ctx t =
	match t with
	| TMono r ->
		(match !r with
		| None -> Printf.sprintf "Unknown<%d>" (try List.assq r (!ctx) with Not_found -> let n = List.length !ctx in ctx := (r,n) :: !ctx; n)
		| Some t -> s_type ctx t)
	| t when is_in_type t ->
		"_"
	| TEnum (e,tl) ->
		s_type_path e.e_path ^ s_type_params ctx tl
	| TInst (c,tl) ->
		(match c.cl_kind with
		| KExpr e -> Ast.s_expr e
		| _ -> s_type_path c.cl_path ^ s_type_params ctx tl)
	| TType (t,tl) ->
		s_type_path t.t_path ^ s_type_params ctx tl
	(* useful for debugging
		| (TAbstract({a_path = [],"-Of"},[tm1;ta1]) as a) ->
		"-Of<" ^ (s_type ctx tm1) ^ "," ^ (s_type ctx ta1) ^ ">"
	*)
	| (TAbstract({a_path = [],"-Of"},[tm1;ta1]) as a) ->
		let r = reduce_of_rec a in
		if (is_of_type r) then
			(s_type ctx tm1) ^ "<" ^ (s_type ctx ta1) ^ ">"
		else (s_type ctx r)
	| TAbstract (a,tl) ->
		s_type_path a.a_path ^ s_type_params ctx tl
	| TFun ([],t) ->
		"Void -> " ^ s_fun ctx t false
	| TFun (l,t) ->
		String.concat " -> " (List.map (fun (s,b,t) ->
			(if b then "?" else "") ^ (if s = "" then "" else s ^ " : ") ^ s_fun ctx t true
		) l) ^ " -> " ^ s_fun ctx t false
	| TAnon a ->
		let fl = PMap.fold (fun f acc -> ((if Meta.has Meta.Optional f.cf_meta then " ?" else " ") ^ f.cf_name ^ " : " ^ s_type ctx f.cf_type) :: acc) a.a_fields [] in
		"{" ^ (if not (is_closed a) then "+" else "") ^  String.concat "," fl ^ " }"
	| TDynamic t2 ->
		"Dynamic" ^ s_type_params ctx (if t == t2 then [] else [t2])
	| TLazy f ->
		s_type ctx (lazy_type f)

and s_type2 ctx t =
	let s_type = s_type2 in
	let s_type_params = s_type_params2 in
	match t with
	| TMono r ->
		(match !r with
		| None -> Printf.sprintf "Unknown"
		| Some t -> s_type ctx t)
	| t when is_in_type t ->
		"_"
	| TEnum (e,tl) ->
		s_type_path e.e_path ^ s_type_params ctx tl
	| TInst (c,tl) ->
		(match c.cl_kind with
		| KExpr e -> Ast.s_expr e
		| _ -> s_type_path c.cl_path ^ s_type_params ctx tl)
	| TType (t,tl) ->
		s_type_path t.t_path ^ s_type_params ctx tl
	(* useful for debugging
		| (TAbstract({a_path = [],"-Of"},[tm1;ta1]) as a) ->
		"-Of<" ^ (s_type ctx tm1) ^ "," ^ (s_type ctx ta1) ^ ">"
	*)
	| (TAbstract({a_path = [],"-Of"},[tm1;ta1]) as a) ->
		let r = reduce_of_rec a in
		if (is_of_type r) then
			(s_type ctx tm1) ^ "<" ^ (s_type ctx ta1) ^ ">"
		else (s_type ctx r)
	| TAbstract (a,tl) ->
		s_type_path a.a_path ^ s_type_params ctx tl
	| TFun ([],t) ->
		"Void -> " ^ s_fun ctx t false
	| TFun (l,t) ->
		String.concat " -> " (List.map (fun (s,b,t) ->
			(if b then "?" else "") ^ (if s = "" then "" else s ^ " : ") ^ s_fun ctx t true
		) l) ^ " -> " ^ s_fun ctx t false
	| TAnon a ->
		begin
			match !(a.a_status) with
			| Statics c -> Printf.sprintf "{ Statics %s }" (s_type_path c.cl_path)
			| EnumStatics e -> Printf.sprintf "{ EnumStatics %s }" (s_type_path e.e_path)
			| AbstractStatics a -> Printf.sprintf "{ AbstractStatics %s }" (s_type_path a.a_path)
			| _ ->
				let fl = PMap.fold (fun f acc -> ((if Meta.has Meta.Optional f.cf_meta then " ?" else " ") ^ f.cf_name ^ " : " ^ s_type ctx f.cf_type) :: acc) a.a_fields [] in
				"{" ^ (if not (is_closed a) then "+" else "") ^  String.concat "," fl ^ " }"
		end
	| TDynamic t2 ->
		"Dynamic" ^ s_type_params ctx (if t == t2 then [] else [t2])
	| TLazy f ->
		s_type ctx (lazy_type f)

and s_fun ctx t void =
	match t with
	| TFun _ ->
		"(" ^ s_type ctx t ^ ")"
	| TAbstract ({ a_path = ([],"Void") },[]) when void ->
		"(" ^ s_type ctx t ^ ")"
	| TMono r ->
		(match !r with
		| None -> s_type ctx t
		| Some t -> s_fun ctx t void)
	| TLazy f ->
		s_fun ctx (lazy_type f) void
	| _ ->
		s_type ctx t

and s_type_params ctx = function
	| [] -> ""
	| l -> "<" ^ String.concat ", " (List.map (s_type ctx) l) ^ ">"
and s_type_params2 ctx = function
	| [] -> ""
	| l -> "<" ^ String.concat ", " (List.map (s_type2 ctx) l) ^ ">"
and s_access is_read = function
	| AccNormal -> "default"
	| AccNo -> "null"
	| AccNever -> "never"
	| AccResolve -> "resolve"
	| AccCall -> if is_read then "get" else "set"
	| AccInline	-> "inline"
	| AccRequire (n,_) -> "require " ^ n
	| AccCtor -> "ctor"

and s_kind = function
	| Var { v_read = AccNormal; v_write = AccNormal } -> "var"
	| Var v -> "(" ^ s_access true v.v_read ^ "," ^ s_access false v.v_write ^ ")"
	| Method m ->
		match m with
		| MethNormal -> "method"
		| MethDynamic -> "dynamic method"
		| MethInline -> "inline method"
		| MethMacro -> "macro method"

and s_expr_kind e =
	match e.eexpr with
	| TConst _ -> "Const"
	| TLocal _ -> "Local"
	| TArray (_,_) -> "Array"
	| TBinop (_,_,_) -> "Binop"
	| TEnumParameter (_,_,_) -> "EnumParameter"
	| TEnumIndex _ -> "EnumIndex"
	| TField (_,_) -> "Field"
	| TTypeExpr _ -> "TypeExpr"
	| TParenthesis _ -> "Parenthesis"
	| TObjectDecl _ -> "ObjectDecl"
	| TArrayDecl _ -> "ArrayDecl"
	| TCall (_,_) -> "Call"
	| TNew (_,_,_) -> "New"
	| TUnop (_,_,_) -> "Unop"
	| TFunction _ -> "Function"
	| TVar _ -> "Vars"
	| TBlock _ -> "Block"
	| TFor (_,_,_) -> "For"
	| TIf (_,_,_) -> "If"
	| TWhile (_,_,_) -> "While"
	| TSwitch (_,_,_) -> "Switch"
	| TTry (_,_) -> "Try"
	| TReturn _ -> "Return"
	| TBreak -> "Break"
	| TContinue -> "Continue"
	| TThrow _ -> "Throw"
	| TCast _ -> "Cast"
	| TMeta _ -> "Meta"
	| TIdent _ -> "Ident"

and s_const = function
	| TInt i -> Int32.to_string i
	| TFloat s -> s
	| TString s -> Printf.sprintf "\"%s\"" (Ast.s_escape s)
	| TBool b -> if b then "true" else "false"
	| TNull -> "null"
	| TThis -> "this"
	| TSuper -> "super"

and s_expr s_type e =
	let sprintf = Printf.sprintf in
	let slist f l = String.concat "," (List.map f l) in
	let loop = s_expr s_type in
	let s_var v = v.v_name ^ ":" ^ string_of_int v.v_id ^ if v.v_capture then "[c]" else "" in
	let str = (match e.eexpr with
	| TConst c ->
		"Const " ^ s_const c
	| TLocal v ->
		"Local " ^ s_var v
	| TArray (e1,e2) ->
		sprintf "%s[%s]" (loop e1) (loop e2)
	| TBinop (op,e1,e2) ->
		sprintf "(%s %s %s)" (loop e1) (s_binop op) (loop e2)
	| TEnumIndex e1 ->
		sprintf "EnumIndex %s" (loop e1)
	| TEnumParameter (e1,_,i) ->
		sprintf "%s[%i]" (loop e1) i
	| TField (e,f) ->
		let fstr = (match f with
			| FStatic (c,f) -> "static(" ^ s_type_path c.cl_path ^ "." ^ f.cf_name ^ ")"
			| FInstance (c,_,f) -> "inst(" ^ s_type_path c.cl_path ^ "." ^ f.cf_name ^ " : " ^ s_type f.cf_type ^ ")"
			| FClosure (c,f) -> "closure(" ^ (match c with None -> f.cf_name | Some (c,_) -> s_type_path c.cl_path ^ "." ^ f.cf_name)  ^ ")"
			| FAnon f -> "anon(" ^ f.cf_name ^ ")"
			| FEnum (en,f) -> "enum(" ^ s_type_path en.e_path ^ "." ^ f.ef_name ^ ")"
			| FDynamic f -> "dynamic(" ^ f ^ ")"
		) in
		sprintf "%s.%s" (loop e) fstr
	| TTypeExpr m ->
		sprintf "TypeExpr %s" (s_type_path (t_path m))
	| TParenthesis e ->
		sprintf "Parenthesis %s" (loop e)
	| TObjectDecl fl ->
		sprintf "ObjectDecl {%s}" (slist (fun ((f,_,qs),e) -> sprintf "%s : %s" (s_object_key_name f qs) (loop e)) fl)
	| TArrayDecl el ->
		sprintf "ArrayDecl [%s]" (slist loop el)
	| TCall (e,el) ->
		sprintf "Call %s(%s)" (loop e) (slist loop el)
	| TNew (c,pl,el) ->
		sprintf "New %s%s(%s)" (s_type_path c.cl_path) (match pl with [] -> "" | l -> sprintf "<%s>" (slist s_type l)) (slist loop el)
	| TUnop (op,f,e) ->
		(match f with
		| Prefix -> sprintf "(%s %s)" (s_unop op) (loop e)
		| Postfix -> sprintf "(%s %s)" (loop e) (s_unop op))
	| TFunction f ->
		let args = slist (fun (v,o) -> sprintf "%s : %s%s" (s_var v) (s_type v.v_type) (match o with None -> "" | Some c -> " = " ^ s_const c)) f.tf_args in
		sprintf "Function(%s) : %s = %s" args (s_type f.tf_type) (loop f.tf_expr)
	| TVar (v,eo) ->
		sprintf "Vars %s" (sprintf "%s : %s%s" (s_var v) (s_type v.v_type) (match eo with None -> "" | Some e -> " = " ^ loop e))
	| TBlock el ->
		sprintf "Block {\n%s}" (String.concat "" (List.map (fun e -> sprintf "%s;\n" (loop e)) el))
	| TFor (v,econd,e) ->
		sprintf "For (%s : %s in %s,%s)" (s_var v) (s_type v.v_type) (loop econd) (loop e)
	| TIf (e,e1,e2) ->
		sprintf "If (%s,%s%s)" (loop e) (loop e1) (match e2 with None -> "" | Some e -> "," ^ loop e)
	| TWhile (econd,e,flag) ->
		(match flag with
		| NormalWhile -> sprintf "While (%s,%s)" (loop econd) (loop e)
		| DoWhile -> sprintf "DoWhile (%s,%s)" (loop e) (loop econd))
	| TSwitch (e,cases,def) ->
		sprintf "Switch (%s,(%s)%s)" (loop e) (slist (fun (cl,e) -> sprintf "case %s: %s" (slist loop cl) (loop e)) cases) (match def with None -> "" | Some e -> "," ^ loop e)
	| TTry (e,cl) ->
		sprintf "Try %s(%s) " (loop e) (slist (fun (v,e) -> sprintf "catch( %s : %s ) %s" (s_var v) (s_type v.v_type) (loop e)) cl)
	| TReturn None ->
		"Return"
	| TReturn (Some e) ->
		sprintf "Return %s" (loop e)
	| TBreak ->
		"Break"
	| TContinue ->
		"Continue"
	| TThrow e ->
		"Throw " ^ (loop e)
	| TCast (e,t) ->
		sprintf "Cast %s%s" (match t with None -> "" | Some t -> s_type_path (t_path t) ^ ": ") (loop e)
	| TMeta ((n,el,_),e) ->
		sprintf "@%s%s %s" (Meta.to_string n) (match el with [] -> "" | _ -> "(" ^ (String.concat ", " (List.map Ast.s_expr el)) ^ ")") (loop e)
	| TIdent s ->
		"Ident " ^ s
	) in
	sprintf "(%s : %s)" str (s_type e.etype)

let rec s_expr_pretty print_var_ids tabs top_level s_type e =
	let sprintf = Printf.sprintf in
	let loop = s_expr_pretty print_var_ids tabs false s_type in
	let slist c f l = String.concat c (List.map f l) in
	let clist f l = slist ", " f l in
	let local v = if print_var_ids then sprintf "%s<%i>" v.v_name v.v_id else v.v_name in
	match e.eexpr with
	| TConst c -> s_const c
	| TLocal v -> local v
	| TArray (e1,e2) -> sprintf "%s[%s]" (loop e1) (loop e2)
	| TBinop (op,e1,e2) -> sprintf "%s %s %s" (loop e1) (s_binop op) (loop e2)
	| TEnumParameter (e1,_,i) -> sprintf "%s[%i]" (loop e1) i
	| TEnumIndex e1 -> sprintf "enumIndex %s" (loop e1)
	| TField (e1,s) -> sprintf "%s.%s" (loop e1) (field_name s)
	| TTypeExpr mt -> (s_type_path (t_path mt))
	| TParenthesis e1 -> sprintf "(%s)" (loop e1)
	| TObjectDecl fl -> sprintf "{%s}" (clist (fun ((f,_,qs),e) -> sprintf "%s : %s" (s_object_key_name f qs) (loop e)) fl)
	| TArrayDecl el -> sprintf "[%s]" (clist loop el)
	| TCall (e1,el) -> sprintf "%s(%s)" (loop e1) (clist loop el)
	| TNew (c,pl,el) ->
		sprintf "new %s(%s)" (s_type_path c.cl_path) (clist loop el)
	| TUnop (op,f,e) ->
		(match f with
		| Prefix -> sprintf "%s %s" (s_unop op) (loop e)
		| Postfix -> sprintf "%s %s" (loop e) (s_unop op))
	| TFunction f ->
		let args = clist (fun (v,o) -> sprintf "%s:%s%s" (local v) (s_type v.v_type) (match o with None -> "" | Some c -> " = " ^ s_const c)) f.tf_args in
		sprintf "%s(%s) %s" (if top_level then "" else "function") args (loop f.tf_expr)
	| TVar (v,eo) ->
		sprintf "var %s" (sprintf "%s%s" (local v) (match eo with None -> "" | Some e -> " = " ^ loop e))
	| TBlock el ->
		let ntabs = tabs ^ "\t" in
		let s = sprintf "{\n%s" (String.concat "" (List.map (fun e -> sprintf "%s%s;\n" ntabs (s_expr_pretty print_var_ids ntabs top_level s_type e)) el)) in
		(match el with
			| [] -> "{}"
			| _ ->  s ^ tabs ^ "}")
	| TFor (v,econd,e) ->
		sprintf "for (%s in %s) %s" (local v) (loop econd) (loop e)
	| TIf (e,e1,e2) ->
		sprintf "if (%s) %s%s" (loop e) (loop e1) (match e2 with None -> "" | Some e -> " else " ^ loop e)
	| TWhile (econd,e,flag) ->
		(match flag with
		| NormalWhile -> sprintf "while (%s) %s" (loop econd) (loop e)
		| DoWhile -> sprintf "do (%s) while(%s)" (loop e) (loop econd))
	| TSwitch (e,cases,def) ->
		let ntabs = tabs ^ "\t" in
		let s = sprintf "switch (%s) {\n%s%s" (loop e) (slist "" (fun (cl,e) -> sprintf "%scase %s: %s;\n" ntabs (clist loop cl) (s_expr_pretty print_var_ids ntabs top_level s_type e)) cases) (match def with None -> "" | Some e -> ntabs ^ "default: " ^ (s_expr_pretty print_var_ids ntabs top_level s_type e) ^ "\n") in
		s ^ tabs ^ "}"
	| TTry (e,cl) ->
		sprintf "try %s%s" (loop e) (clist (fun (v,e) -> sprintf " catch (%s:%s) %s" (local v) (s_type v.v_type) (loop e)) cl)
	| TReturn None ->
		"return"
	| TReturn (Some e) ->
		sprintf "return %s" (loop e)
	| TBreak ->
		"break"
	| TContinue ->
		"continue"
	| TThrow e ->
		"throw " ^ (loop e)
	| TCast (e,None) ->
		sprintf "cast %s" (loop e)
	| TCast (e,Some mt) ->
		sprintf "cast (%s,%s)" (loop e) (s_type_path (t_path mt))
	| TMeta ((n,el,_),e) ->
		sprintf "@%s%s %s" (Meta.to_string n) (match el with [] -> "" | _ -> "(" ^ (String.concat ", " (List.map Ast.s_expr el)) ^ ")") (loop e)
	| TIdent s ->
		s

let rec s_expr_ast print_var_ids tabs s_type e =
	let sprintf = Printf.sprintf in
	let loop ?(extra_tabs="") = s_expr_ast print_var_ids (tabs ^ "\t" ^ extra_tabs) s_type in
	let tag_args tabs sl = match sl with
		| [] -> ""
		| [s] when not (String.contains s '\n') -> " " ^ s
		| _ ->
			let tabs = "\n" ^ tabs ^ "\t" in
			tabs ^ (String.concat tabs sl)
	in
	let tag s ?(t=None) ?(extra_tabs="") sl =
		let st = match t with
			| None -> s_type e.etype
			| Some t -> s_type t
		in
		sprintf "[%s:%s]%s" s st (tag_args (tabs ^ extra_tabs) sl)
	in
	let var_id v = if print_var_ids then v.v_id else 0 in
	let const c t = tag "Const" ~t [s_const c] in
	let local v = sprintf "[Local %s(%i):%s]" v.v_name (var_id v) (s_type v.v_type) in
	let var v sl = sprintf "[Var %s(%i):%s]%s" v.v_name (var_id v) (s_type v.v_type) (tag_args tabs sl) in
	let module_type mt = sprintf "[TypeExpr %s:%s]" (s_type_path (t_path mt)) (s_type e.etype) in
	match e.eexpr with
	| TConst c -> const c (Some e.etype)
	| TLocal v -> local v
	| TArray (e1,e2) -> tag "Array" [loop e1; loop e2]
	| TBinop (op,e1,e2) -> tag "Binop" [loop e1; s_binop op; loop e2]
	| TUnop (op,flag,e1) -> tag "Unop" [s_unop op; if flag = Postfix then "Postfix" else "Prefix"; loop e1]
	| TEnumParameter (e1,ef,i) -> tag "EnumParameter" [loop e1; ef.ef_name; string_of_int i]
	| TEnumIndex e1 -> tag "EnumIndex" [loop e1]
	| TField (e1,fa) ->
		let sfa = match fa with
			| FInstance(c,tl,cf) -> tag "FInstance" ~extra_tabs:"\t" [s_type (TInst(c,tl)); cf.cf_name]
			| FStatic(c,cf) -> tag "FStatic" ~extra_tabs:"\t" [s_type_path c.cl_path; cf.cf_name]
			| FClosure(co,cf) -> tag "FClosure" ~extra_tabs:"\t" [(match co with None -> "None" | Some (c,tl) -> s_type (TInst(c,tl))); cf.cf_name]
			| FAnon cf -> tag "FAnon" ~extra_tabs:"\t" [cf.cf_name]
			| FDynamic s -> tag "FDynamic" ~extra_tabs:"\t" [s]
			| FEnum(en,ef) -> tag "FEnum" ~extra_tabs:"\t" [s_type_path en.e_path; ef.ef_name]
		in
		tag "Field" [loop e1; sfa]
	| TTypeExpr mt -> module_type mt
	| TParenthesis e1 -> tag "Parenthesis" [loop e1]
	| TObjectDecl fl -> tag "ObjectDecl" (List.map (fun ((s,_,qs),e) -> sprintf "%s: %s" (s_object_key_name s qs) (loop e)) fl)
	| TArrayDecl el -> tag "ArrayDecl" (List.map loop el)
	| TCall (e1,el) -> tag "Call" (loop e1 :: (List.map loop el))
	| TNew (c,tl,el) -> tag "New" ((s_type (TInst(c,tl))) :: (List.map loop el))
	| TFunction f ->
		let arg (v,cto) =
			tag "Arg" ~t:(Some v.v_type) ~extra_tabs:"\t" (match cto with None -> [local v] | Some ct -> [local v;const ct None])
		in
		tag "Function" ((List.map arg f.tf_args) @ [loop f.tf_expr])
	| TVar (v,eo) -> var v (match eo with None -> [] | Some e -> [loop e])
	| TBlock el -> tag "Block" (List.map loop el)
	| TIf (e,e1,e2) -> tag "If" (loop e :: (Printf.sprintf "[Then:%s] %s" (s_type e1.etype) (loop e1)) :: (match e2 with None -> [] | Some e -> [Printf.sprintf "[Else:%s] %s" (s_type e.etype) (loop e)]))
	| TCast (e1,None) -> tag "Cast" [loop e1]
	| TCast (e1,Some mt) -> tag "Cast" [loop e1; module_type mt]
	| TThrow e1 -> tag "Throw" [loop e1]
	| TBreak -> tag "Break" []
	| TContinue -> tag "Continue" []
	| TReturn None -> tag "Return" []
	| TReturn (Some e1) -> tag "Return" [loop e1]
	| TWhile (e1,e2,NormalWhile) -> tag "While" [loop e1; loop e2]
	| TWhile (e1,e2,DoWhile) -> tag "Do" [loop e1; loop e2]
	| TFor (v,e1,e2) -> tag "For" [local v; loop e1; loop e2]
	| TTry (e1,catches) ->
		let sl = List.map (fun (v,e) ->
			sprintf "Catch %s%s" (local v) (tag_args (tabs ^ "\t") [loop ~extra_tabs:"\t" e]);
		) catches in
		tag "Try" ((loop e1) :: sl)
	| TSwitch (e1,cases,eo) ->
		let sl = List.map (fun (el,e) ->
			tag "Case" ~t:(Some e.etype) ~extra_tabs:"\t" ((List.map loop el) @ [loop ~extra_tabs:"\t" e])
		) cases in
		let sl = match eo with
			| None -> sl
			| Some e -> sl @ [tag "Default" ~t:(Some e.etype) ~extra_tabs:"\t" [loop ~extra_tabs:"\t" e]]
		in
		tag "Switch" ((loop e1) :: sl)
	| TMeta ((m,el,_),e1) ->
		let s = Meta.to_string m in
		let s = match el with
			| [] -> s
			| _ -> sprintf "%s(%s)" s (String.concat ", " (List.map Ast.s_expr el))
		in
		tag "Meta" [s; loop e1]
	| TIdent s ->
		tag "Ident" [s]

let s_types ?(sep = ", ") tl =
	let pctx = print_context() in
	String.concat sep (List.map (s_type pctx) tl)

let s_class_kind = function
	| KNormal ->
		"KNormal"
	| KTypeParameter tl ->
		Printf.sprintf "KTypeParameter [%s]" (s_types tl)
	| KExpr _ ->
		"KExpr"
	| KGeneric ->
		"KGeneric"
	| KGenericInstance(c,tl) ->
		Printf.sprintf "KGenericInstance %s<%s>" (s_type_path c.cl_path) (s_types tl)
	| KMacroType ->
		"KMacroType"
	| KGenericBuild _ ->
		"KGenericBuild"
	| KAbstractImpl a ->
		Printf.sprintf "KAbstractImpl %s" (s_type_path a.a_path)

module Printer = struct

	let s_type t =
		s_type (print_context()) t

	let s_pair s1 s2 =
		Printf.sprintf "(%s,%s)" s1 s2

	let s_record_field name value =
		Printf.sprintf "%s = %s;" name value

	let s_pos p =
		Printf.sprintf "%s: %i-%i" p.pfile p.pmin p.pmax

	let s_record_fields tabs fields =
		let sl = List.map (fun (name,value) -> s_record_field name value) fields in
		Printf.sprintf "{\n%s\t%s\n%s}" tabs (String.concat ("\n\t" ^ tabs) sl) tabs

	let s_list sep f l =
		"[" ^ (String.concat sep (List.map f l)) ^ "]"

	let s_opt f o = match o with
		| None -> "None"
		| Some v -> f v

	let s_pmap fk fv pm =
		"{" ^ (String.concat ", " (PMap.foldi (fun k v acc -> (Printf.sprintf "%s = %s" (fk k) (fv v)) :: acc) pm [])) ^ "}"

	let s_doc = s_opt (fun s -> s)

	let s_metadata_entry (s,el,_) =
		Printf.sprintf "@%s%s" (Meta.to_string s) (match el with [] -> "" | el -> "(" ^ (String.concat ", " (List.map Ast.s_expr el)) ^ ")")

	let s_metadata metadata =
		s_list " " s_metadata_entry metadata

	let s_type_param (s,t) = match follow t with
		| TInst({cl_kind = KTypeParameter tl1},tl2) ->
			begin match tl1 with
			| [] -> s
			| _ -> Printf.sprintf "%s:%s" s (String.concat ", " (List.map s_type tl1))
			end
		| _ -> assert false

	let s_type_params tl =
		s_list ", " s_type_param tl

	let s_tclass_field tabs cf =
		s_record_fields tabs [
			"cf_name",cf.cf_name;
			"cf_doc",s_doc cf.cf_doc;
			"cf_type",s_type_kind (follow cf.cf_type);
			"cf_public",string_of_bool cf.cf_public;
			"cf_pos",s_pos cf.cf_pos;
			"cf_name_pos",s_pos cf.cf_name_pos;
			"cf_meta",s_metadata cf.cf_meta;
			"cf_kind",s_kind cf.cf_kind;
			"cf_params",s_type_params cf.cf_params;
			"cf_expr",s_opt (s_expr_ast true "\t\t" s_type) cf.cf_expr;
		]

	let s_tclass tabs c =
		s_record_fields tabs [
			"cl_path",s_type_path c.cl_path;
			"cl_module",s_type_path c.cl_module.m_path;
			"cl_pos",s_pos c.cl_pos;
			"cl_name_pos",s_pos c.cl_name_pos;
			"cl_private",string_of_bool c.cl_private;
			"cl_doc",s_doc c.cl_doc;
			"cl_meta",s_metadata c.cl_meta;
			"cl_params",s_type_params c.cl_params;
			"cl_kind",s_class_kind c.cl_kind;
			"cl_extern",string_of_bool c.cl_extern;
			"cl_interface",string_of_bool c.cl_interface;
			"cl_super",s_opt (fun (c,tl) -> s_type (TInst(c,tl))) c.cl_super;
			"cl_implements",s_list ", " (fun (c,tl) -> s_type (TInst(c,tl))) c.cl_implements;
			"cl_dynamic",s_opt s_type c.cl_dynamic;
			"cl_array_access",s_opt s_type c.cl_array_access;
			"cl_overrides",s_list "," (fun cf -> cf.cf_name) c.cl_overrides;
			"cl_init",s_opt (s_expr_ast true "" s_type) c.cl_init;
			"cl_constructor",s_opt (s_tclass_field (tabs ^ "\t")) c.cl_constructor;
			"cl_ordered_fields",s_list "\n\t" (s_tclass_field (tabs ^ "\t")) c.cl_ordered_fields;
			"cl_ordered_statics",s_list "\n\t" (s_tclass_field (tabs ^ "\t")) c.cl_ordered_statics;
		]

	let s_tdef tabs t =
		s_record_fields tabs [
			"t_path",s_type_path t.t_path;
			"t_module",s_type_path t.t_module.m_path;
			"t_pos",s_pos t.t_pos;
			"t_name_pos",s_pos t.t_name_pos;
			"t_private",string_of_bool t.t_private;
			"t_doc",s_doc t.t_doc;
			"t_meta",s_metadata t.t_meta;
			"t_params",s_type_params t.t_params;
			"t_type",s_type_kind t.t_type
		]

	let s_tenum_field tabs ef =
		s_record_fields tabs [
			"ef_name",ef.ef_name;
			"ef_doc",s_doc ef.ef_doc;
			"ef_pos",s_pos ef.ef_pos;
			"ef_name_pos",s_pos ef.ef_name_pos;
			"ef_type",s_type_kind ef.ef_type;
			"ef_index",string_of_int ef.ef_index;
			"ef_params",s_type_params ef.ef_params;
			"ef_meta",s_metadata ef.ef_meta
		]

	let s_tenum tabs en =
		s_record_fields tabs [
			"e_path",s_type_path en.e_path;
			"e_module",s_type_path en.e_module.m_path;
			"e_pos",s_pos en.e_pos;
			"e_name_pos",s_pos en.e_name_pos;
			"e_private",string_of_bool en.e_private;
			"d_doc",s_doc en.e_doc;
			"e_meta",s_metadata en.e_meta;
			"e_params",s_type_params en.e_params;
			"e_type",s_tdef "\t" en.e_type;
			"e_extern",string_of_bool en.e_extern;
			"e_constrs",s_list "\n\t" (s_tenum_field (tabs ^ "\t")) (PMap.fold (fun ef acc -> ef :: acc) en.e_constrs []);
			"e_names",String.concat ", " en.e_names
		]

	let s_tabstract tabs a =
		s_record_fields tabs [
			"a_path",s_type_path a.a_path;
			"a_modules",s_type_path a.a_module.m_path;
			"a_pos",s_pos a.a_pos;
			"a_name_pos",s_pos a.a_name_pos;
			"a_private",string_of_bool a.a_private;
			"a_doc",s_doc a.a_doc;
			"a_meta",s_metadata a.a_meta;
			"a_params",s_type_params a.a_params;
			"a_ops",s_list ", " (fun (op,cf) -> Printf.sprintf "%s: %s" (s_binop op) cf.cf_name) a.a_ops;
			"a_unops",s_list ", " (fun (op,flag,cf) -> Printf.sprintf "%s (%s): %s" (s_unop op) (if flag = Postfix then "postfix" else "prefix") cf.cf_name) a.a_unops;
			"a_impl",s_opt (fun c -> s_type_path c.cl_path) a.a_impl;
			"a_this",s_type_kind a.a_this;
			"a_from",s_list ", " s_type_kind a.a_from;
			"a_to",s_list ", " s_type_kind a.a_to;
			"a_from_field",s_list ", " (fun (t,cf) -> Printf.sprintf "%s: %s" (s_type_kind t) cf.cf_name) a.a_from_field;
			"a_to_field",s_list ", " (fun (t,cf) -> Printf.sprintf "%s: %s" (s_type_kind t) cf.cf_name) a.a_to_field;
			"a_array",s_list ", " (fun cf -> cf.cf_name) a.a_array;
			"a_resolve",s_opt (fun cf -> cf.cf_name) a.a_resolve;
		]

	let s_tvar_extra (tl,eo) =
		Printf.sprintf "Some(%s, %s)" (s_type_params tl) (s_opt (s_expr_ast true "" s_type) eo)

	let s_tvar v =
		s_record_fields "" [
			"v_id",string_of_int v.v_id;
			"v_name",v.v_name;
			"v_type",s_type v.v_type;
			"v_capture",string_of_bool v.v_capture;
			"v_extra",s_opt s_tvar_extra v.v_extra;
			"v_meta",s_metadata v.v_meta;
		]

	let s_module_kind = function
		| MCode -> "MCode"
		| MMacro -> "MMacro"
		| MFake -> "MFake"
		| MExtern -> "MExtern"
		| MImport -> "MImport"

	let s_module_def_extra tabs me =
		s_record_fields tabs [
			"m_file",me.m_file;
			"m_sign",me.m_sign;
			"m_time",string_of_float me.m_time;
			"m_dirty",s_opt (fun m -> s_type_path m.m_path) me.m_dirty;
			"m_added",string_of_int me.m_added;
			"m_mark",string_of_int me.m_mark;
			"m_deps",s_pmap string_of_int (fun m -> snd m.m_path) me.m_deps;
			"m_processed",string_of_int me.m_processed;
			"m_kind",s_module_kind me.m_kind;
			"m_binded_res",""; (* TODO *)
			"m_reuse_macro_calls",String.concat ", " me.m_reuse_macro_calls;
			"m_if_feature",""; (* TODO *)
			"m_features",""; (* TODO *)
		]

	let s_module_def m =
		s_record_fields "" [
			"m_id",string_of_int m.m_id;
			"m_path",s_type_path m.m_path;
			"m_extra",s_module_def_extra "\t" m.m_extra
		]

	let s_type_path tp =
		s_record_fields "" [
			"tpackage",s_list "." (fun s -> s) tp.tpackage;
			"tname",tp.tname;
			"tparams","";
			"tsub",s_opt (fun s -> s) tp.tsub;
		]

	let s_class_flag = function
		| HInterface -> "HInterface"
		| HExtern -> "HExtern"
		| HPrivate -> "HPrivate"
		| HExtends tp -> "HExtends " ^ (s_type_path (fst tp))
		| HImplements tp -> "HImplements " ^ (s_type_path (fst tp))

	let s_placed f (x,p) =
		s_pair (f x) (s_pos p)

	let s_class_field cff =
		s_record_fields "" [
			"cff_name",s_placed (fun s -> s) cff.cff_name;
			"cff_doc",s_opt (fun s -> s) cff.cff_doc;
			"cff_pos",s_pos cff.cff_pos;
			"cff_meta",s_metadata cff.cff_meta;
			"cff_access",s_list ", " Ast.s_access cff.cff_access;
		]
end

(* ======= Unification ======= *)

let link_dynamic a b = match follow a,follow b with
	| TMono r,TDynamic _ -> r := Some b
	| TDynamic _,TMono r -> r := Some a
	| _ -> ()

let rec fast_eq a b =
	if a == b then
		true
	else match a , b with
	| TFun (l1,r1) , TFun (l2,r2) when List.length l1 = List.length l2 ->
		List.for_all2 (fun (_,_,t1) (_,_,t2) -> fast_eq t1 t2) l1 l2 && fast_eq r1 r2
	| TType (t1,l1), TType (t2,l2) ->
		t1 == t2 && List.for_all2 fast_eq l1 l2
	| TEnum (e1,l1), TEnum (e2,l2) ->
		e1 == e2 && List.for_all2 fast_eq l1 l2
	| TInst (c1,l1), TInst (c2,l2) ->
		c1 == c2 && List.for_all2 fast_eq l1 l2
	| TAbstract (a1,l1), TAbstract (a2,l2) ->
		a1 == a2 && List.for_all2 fast_eq l1 l2
	| _ , _ ->
		false

let rec fast_eq_mono ml a b =
	if a == b then
		true
	else match a , b with
	| TFun (l1,r1) , TFun (l2,r2) when List.length l1 = List.length l2 ->
		List.for_all2 (fun (_,_,t1) (_,_,t2) -> fast_eq_mono ml t1 t2) l1 l2 && fast_eq_mono ml r1 r2
	| TType (t1,l1), TType (t2,l2) ->
		t1 == t2 && List.for_all2 (fast_eq_mono ml) l1 l2
	| TEnum (e1,l1), TEnum (e2,l2) ->
		e1 == e2 && List.for_all2 (fast_eq_mono ml) l1 l2
	| TInst (c1,l1), TInst (c2,l2) ->
		c1 == c2 && List.for_all2 (fast_eq_mono ml) l1 l2
	| TAbstract (a1,l1), TAbstract (a2,l2) ->
		a1 == a2 && List.for_all2 (fast_eq_mono ml) l1 l2
	| TMono _, _ ->
		List.memq a ml
	| _ , _ ->
		false

(* perform unification with subtyping.
   the first type is always the most down in the class hierarchy
   it's also the one that is pointed by the position.
   It's actually a typecheck of  A :> B where some mutations can happen *)

type unify_error =
	| Cannot_unify of t * t
	| Invalid_field_type of string
	| Has_no_field of t * string
	| Has_no_runtime_field of t * string
	| Has_extra_field of t * string
	| Invalid_kind of string * field_kind * field_kind
	| Invalid_visibility of string
	| Not_matching_optional of string
	| Cant_force_optional
	| Invariant_parameter of t * t
	| Constraint_failure of string
	| Missing_overload of tclass_field * t
	| Unify_custom of string

exception Unify_error of unify_error list

let cannot_unify a b = Cannot_unify (a,b)
let invalid_field n = Invalid_field_type n
let invalid_kind n a b = Invalid_kind (n,a,b)
let invalid_visibility n = Invalid_visibility n
let has_no_field t n = Has_no_field (t,n)
let has_extra_field t n = Has_extra_field (t,n)
let error l = raise (Unify_error l)
let has_meta m ml = List.exists (fun (m2,_,_) -> m = m2) ml
let get_meta m ml = List.find (fun (m2,_,_) -> m = m2) ml
let no_meta = []

(*
	we can restrict access as soon as both are runtime-compatible
*)
let unify_access a1 a2 =
	a1 = a2 || match a1, a2 with
	| _, AccNo | _, AccNever -> true
	| AccInline, AccNormal -> true
	| _ -> false

let direct_access = function
	| AccNo | AccNever | AccNormal | AccInline | AccRequire _ | AccCtor -> true
	| AccResolve | AccCall -> false

let unify_kind k1 k2 =
	k1 = k2 || match k1, k2 with
		| Var v1, Var v2 -> unify_access v1.v_read v2.v_read && unify_access v1.v_write v2.v_write
		| Var v, Method m ->
			(match v.v_read, v.v_write, m with
			| AccNormal, _, MethNormal -> true
			| AccNormal, AccNormal, MethDynamic -> true
			| _ -> false)
		| Method m, Var v ->
			(match m with
			| MethDynamic -> direct_access v.v_read && direct_access v.v_write
			| MethMacro -> false
			| MethNormal | MethInline ->
				match v.v_read,v.v_write with
				| AccNormal,(AccNo | AccNever) -> true
				| _ -> false)
		| Method m1, Method m2 ->
			match m1,m2 with
			| MethInline, MethNormal
			| MethDynamic, MethNormal -> true
			| _ -> false

let eq_stack = ref []

let rec_stack stack value fcheck frun ferror =
	if not (List.exists fcheck !stack) then begin
		try
			stack := value :: !stack;
			let v = frun() in
			stack := List.tl !stack;
			v
		with
			Unify_error l ->
				stack := List.tl !stack;
				ferror l
			| e ->
				stack := List.tl !stack;
				raise e
	end

let rec_stack_bool stack value fcheck frun =
	if (List.exists fcheck !stack) then false else begin
		try
			stack := value :: !stack;
			frun();
			stack := List.tl !stack;
			true
		with
			Unify_error l ->
				stack := List.tl !stack;
				false
			| e ->
				stack := List.tl !stack;
				raise e
	end

type eq_kind =
	| EqStrict
	| EqCoreType
	| EqRightDynamic
	| EqBothDynamic
	| EqLeftBoth
	| EqDoNotFollowNull (* like EqStrict, but does not follow Null<T> *)

let rec type_eq param a b =
	let can_follow t = match param with
		| EqCoreType -> false
		| EqDoNotFollowNull -> not (is_explicit_null t)
		| _ -> true
	in
	if a == b then
		()
	else match a , b with
	| TLazy f , _ -> type_eq param (lazy_type f) b
	| _ , TLazy f -> type_eq param a (lazy_type f)
	| TMono t , _ ->
		(match !t with
		| None -> if param = EqCoreType || not (link t a b) then error [cannot_unify a b]
		| Some t -> type_eq param t b)
	| _ , TMono t ->
		(match !t with
		| None -> if param = EqCoreType || not (link t b a) then error [cannot_unify a b]
		| Some t -> type_eq param a t)
	| TType (t1,tl1), TType (t2,tl2) when (t1 == t2 || (param = EqCoreType && t1.t_path = t2.t_path)) && List.length tl1 = List.length tl2 ->
		List.iter2 (type_eq param) tl1 tl2
	| TType (t,tl) , _ when can_follow a ->
		type_eq param (apply_params t.t_params tl t.t_type) b
	| _ , TType (t,tl) when can_follow b ->
		rec_stack eq_stack (a,b)
			(fun (a2,b2) -> fast_eq a a2 && fast_eq b b2)
			(fun() -> type_eq param a (apply_params t.t_params tl t.t_type))
			(fun l -> error (cannot_unify a b :: l))
	(*| TAbstract({a_path=[],"-In"},_), b when (param = EqLeftBoth) ->
		()
	| a, TInst({cl_path=[],"-In"},_) when (param = EqLeftBoth) ->
		()*)
	| TEnum (e1,tl1) , TEnum (e2,tl2) ->
		if e1 != e2 && not (param = EqCoreType && e1.e_path = e2.e_path) then error [cannot_unify a b];
		List.iter2 (type_eq param) tl1 tl2
	| TInst (c1,tl1) , TInst (c2,tl2) ->
		if c1 != c2 && not (param = EqCoreType && c1.cl_path = c2.cl_path) && (match c1.cl_kind, c2.cl_kind with KExpr _, KExpr _ -> false | _ -> true) then error [cannot_unify a b];
		List.iter2 (type_eq param) tl1 tl2
	| TFun (l1,r1) , TFun (l2,r2) when List.length l1 = List.length l2 ->
		(try
			type_eq param r1 r2;
			List.iter2 (fun (n,o1,t1) (_,o2,t2) ->
				if o1 <> o2 then error [Not_matching_optional n];
				type_eq param t1 t2
			) l1 l2
		with
			Unify_error l -> error (cannot_unify a b :: l))
	| TDynamic a , TDynamic b ->
		type_eq param a b
	| TAbstract ({a_path=[],"Null"},[t1]),TAbstract ({a_path=[],"Null"},[t2]) ->
		type_eq param t1 t2
	| TAbstract ({a_path=[],"Null"},[t]),_ when param <> EqDoNotFollowNull ->
		type_eq param t b
	| _,TAbstract ({a_path=[],"Null"},[t]) when param <> EqDoNotFollowNull ->
		type_eq param a t
	| TAbstract (a1,tl1) , TAbstract (a2,tl2) ->
		if a1 != a2 && not (param = EqCoreType && a1.a_path = a2.a_path) then error [cannot_unify a b];
		List.iter2 (type_eq param) tl1 tl2
	| TAnon a1, TAnon a2 ->
		(try
			PMap.iter (fun n f1 ->
				try
					let f2 = PMap.find n a2.a_fields in
					if f1.cf_kind <> f2.cf_kind && (param = EqStrict || param = EqCoreType || not (unify_kind f1.cf_kind f2.cf_kind)) then error [invalid_kind n f1.cf_kind f2.cf_kind];
					let a = f1.cf_type and b = f2.cf_type in
					rec_stack eq_stack (a,b)
						(fun (a2,b2) -> fast_eq a a2 && fast_eq b b2)
						(fun() -> type_eq param a b)
						(fun l -> error (invalid_field n :: l))
				with
					Not_found ->
						if is_closed a2 then error [has_no_field b n];
						if not (link (ref None) b f1.cf_type) then error [cannot_unify a b];
						a2.a_fields <- PMap.add n f1 a2.a_fields
			) a1.a_fields;
			PMap.iter (fun n f2 ->
				if not (PMap.mem n a1.a_fields) then begin
					if is_closed a1 then error [has_no_field a n];
					if not (link (ref None) a f2.cf_type) then error [cannot_unify a b];
					a1.a_fields <- PMap.add n f2 a1.a_fields
				end;
			) a2.a_fields;
		with
			Unify_error l -> error (cannot_unify a b :: l))
	| _ , _ ->
		if b == t_dynamic && (param = EqRightDynamic || param = EqBothDynamic) then
			()
		else if a == t_dynamic && (param = EqBothDynamic) then
			()
		else if ((is_in_type a) || (is_in_type b)) && (param = EqLeftBoth) then
			()
		else
			error [cannot_unify a b]

let type_iseq a b =
	try
		type_eq EqStrict a b;
		true
	with
		Unify_error _ -> false

let type_iseq2 a b =
	try
		type_eq EqRightDynamic a b;
		true
	with
		Unify_error _ -> false

let type_iseq_strict a b =
	try
		type_eq EqDoNotFollowNull a b;
		true
	with Unify_error _ ->
		false

let unify_stack = ref []
let abstract_cast_stack = ref []
let unify_new_monos = ref []

let print_stacks() =
	begin
	let ctx = print_context() in
	let st = s_type ctx in
	print_endline "unify_stack";
	List.iter (fun (a,b) -> Printf.printf "\t%s , %s\n" (st a) (st b)) !unify_stack;
	print_endline "monos";
	List.iter (fun m -> print_endline ("\t" ^ st m)) !unify_new_monos;
	print_endline "abstract_cast_stack";
	List.iter (fun (a,b) -> Printf.printf "\t%s , %s\n" (st a) (st b)) !abstract_cast_stack
	end


let isKTypeParameter t =
	match follow1 t with
	| TInst ({ cl_kind = KTypeParameter ctl } as c,pl) -> true
	| _ -> false

let rec unify a b =
	if a == b then
		()
	else match a, b with
	| a, b when is_in_type a -> ()
	| TLazy f , _ -> unify (lazy_type f) b
	| _ , TLazy f -> unify a (lazy_type f)
	| TMono t , _ ->
		(match !t with
		| None -> if not (link t a b) then error [cannot_unify a b]
		| Some t -> unify t b)
	| _ , TMono t ->
		(match !t with
		| None -> if not (link t b a) then error [cannot_unify a b]
		| Some t -> unify a t)
	| TAbstract({a_path = [],"-Of"},_),TAbstract({a_path = [],"-Of"},_) ->
		unify_of a b
	| TAbstract({a_path = [],"-Of"},_),b ->
		unify_of a b
	| a,TAbstract({a_path = [],"-Of"},_) ->
		unify_of a b
	| TType (t,tl) , _ ->
		rec_stack unify_stack (a,b)
			(fun(a2,b2) -> fast_eq a a2 && fast_eq b b2)
			(fun() -> unify (apply_params t.t_params tl t.t_type) b)
			(fun l -> error (cannot_unify a b :: l))
	| _ , TType (t,tl) ->
		rec_stack unify_stack (a,b)
			(fun(a2,b2) -> fast_eq a a2 && fast_eq b b2)
			(fun() -> unify a (apply_params t.t_params tl t.t_type))
			(fun l -> error (cannot_unify a b :: l))

	| TEnum (ea,tl1) , TEnum (eb,tl2) ->
		if ea != eb then error [cannot_unify a b];
		unify_type_params a b tl1 tl2
	| TAbstract ({a_path=[],"Null"},[t]),_ ->
		begin try unify t b
		with Unify_error l -> error (cannot_unify a b :: l) end
	| _,TAbstract ({a_path=[],"Null"},[t]) ->
		begin try unify a t
		with Unify_error l -> error (cannot_unify a b :: l) end
	| TAbstract (a1,tl1) , TAbstract (a2,tl2) when a1 == a2 ->
		begin try
			unify_type_params a b tl1 tl2
		with Unify_error _ as err ->
			(* the type could still have a from/to relation to itself (issue #3494) *)
			begin try
				unify_abstracts a b a1 tl1 a2 tl2
			with Unify_error _ ->
				raise err
			end
		end
	| TAbstract ({a_path=[],"Void"},_) , _
	| _ , TAbstract ({a_path=[],"Void"},_) ->
		error [cannot_unify a b]
	| TAbstract (a1,tl1) , TAbstract (a2,tl2) ->
		unify_abstracts a b a1 tl1 a2 tl2
	(*| TInst( { cl_kind = KGenericInstance(c, tl)}, []), b ->
		unify (TInst(c, tl)) b
	| a, TInst( { cl_kind = KGenericInstance(c, tl)}, []) ->
		unify a (TInst(c, tl))*)
	| TInst (c1,tl1) , TInst (c2,tl2) ->
		let rec loop c tl =
			let default () =
				(match c.cl_super with
						| None -> false
						| Some (cs,tls) ->
							loop cs (List.map (apply_params c.cl_params tl) tls)
					) || List.exists (fun (cs,tls) ->
						loop cs (List.map (apply_params c.cl_params tl) tls)
					) c.cl_implements
					|| (match c.cl_kind with
					| KTypeParameter pl ->
						List.exists (fun t ->
							match follow t with
							| TInst (cs,tls) -> loop cs (List.map (apply_params c.cl_params tl) tls)
							| TAbstract(aa,tl) -> List.exists (unify_to aa tl b) aa.a_to
							| _ -> false
						) pl
					| _ -> false)
			in
			if c == c2 then begin
				unify_type_params a b tl tl2;
				true
			end else (match a, b with
				| TInst({ cl_kind = KGenericInstance(c, tl)},[]), TInst({ cl_kind = KGenericInstance(c2, tl2)},[]) ->
					(if c == c2 then
						(unify_type_params a b tl tl2;
						true)
					else
						false)
				| TInst({ cl_kind = KGenericInstance(c, tl)},[]), _ ->
					(try
						(unify (TInst(c, tl)) b;
						true)
					with
						Unify_error l ->
							default()
					)
				| _, TInst({ cl_kind = KGenericInstance(c, tl)},[]) ->
					(try
						(unify a (TInst(c, tl));
						true)
					with
						Unify_error l ->
							default()
					)
				| _ ->
					default ()
			)

		in
		if not (loop c1 tl1) then error [cannot_unify a b]
	| TFun (l1,r1) , TFun (l2,r2) when List.length l1 = List.length l2 ->
		let i = ref 0 in
		(try
			(match r2 with
			| TAbstract ({a_path=[],"Void"},_) -> incr i
			| _ -> unify r1 r2; incr i);
			List.iter2 (fun (_,o1,t1) (_,o2,t2) ->
				if o1 && not o2 then error [Cant_force_optional];
				unify t1 t2;
				incr i
			) l2 l1 (* contravariance *)
		with
			Unify_error l ->
				let msg = if !i = 0 then "Cannot unify return types" else "Cannot unify argument " ^ (string_of_int !i) in
				error (cannot_unify a b :: Unify_custom msg :: l))
	| TInst (c,tl) , TAnon an ->
		if PMap.is_empty an.a_fields then (match c.cl_kind with
			| KTypeParameter pl ->
				(* one of the constraints must unify with { } *)
				if not (List.exists (fun t -> match follow t with TInst _ | TAnon _ -> true | _ -> false) pl) then error [cannot_unify a b]
			| _ -> ());
		(try
			PMap.iter (fun n f2 ->
				(*
					introducing monomorphs while unifying might create infinite loops - see #2315
					let's store these monomorphs and make sure we reach a fixed point
				*)
				let monos = ref [] in
				let make_type f =
					match f.cf_params with
					| [] -> f.cf_type
					| l ->
						let ml = List.map (fun _ -> mk_mono()) l in
						monos := ml;
						apply_params f.cf_params ml f.cf_type
				in
				let _, ft, f1 = (try raw_class_field make_type c tl n with Not_found -> error [has_no_field a n]) in
				let ft = apply_params c.cl_params tl ft in
				if not (unify_kind f1.cf_kind f2.cf_kind) then error [invalid_kind n f1.cf_kind f2.cf_kind];
				if f2.cf_public && not f1.cf_public then error [invalid_visibility n];

				(match f2.cf_kind with
				| Var { v_read = AccNo } | Var { v_read = AccNever } ->
					(* we will do a recursive unification, so let's check for possible recursion *)
					let old_monos = !unify_new_monos in
					unify_new_monos := !monos @ !unify_new_monos;
					rec_stack unify_stack (ft,f2.cf_type)
						(fun (a2,b2) -> fast_eq b2 f2.cf_type && fast_eq_mono !unify_new_monos ft a2)
						(fun() -> try unify_with_access ft f2 with e -> unify_new_monos := old_monos; raise e)
						(fun l -> error (invalid_field n :: l));
					unify_new_monos := old_monos;
				| Method MethNormal | Method MethInline | Var { v_write = AccNo } | Var { v_write = AccNever } ->
					(* same as before, but unification is reversed (read-only var) *)
					let old_monos = !unify_new_monos in
					unify_new_monos := !monos @ !unify_new_monos;
					rec_stack unify_stack (f2.cf_type,ft)
						(fun(a2,b2) -> fast_eq_mono !unify_new_monos b2 ft && fast_eq f2.cf_type a2)
						(fun() -> try unify_with_access ft f2 with e -> unify_new_monos := old_monos; raise e)
						(fun l -> error (invalid_field n :: l));
					unify_new_monos := old_monos;
				| _ ->
					(* will use fast_eq, which have its own stack *)
					try
						unify_with_access ft f2
					with
						Unify_error l ->
							error (invalid_field n :: l));

				List.iter (fun f2o ->
					if not (List.exists (fun f1o -> type_iseq f1o.cf_type f2o.cf_type) (f1 :: f1.cf_overloads))
					then error [Missing_overload (f1, f2o.cf_type)]
				) f2.cf_overloads;
				(* we mark the field as :?used because it might be used through the structure *)
				if not (Meta.has Meta.MaybeUsed f1.cf_meta) then f1.cf_meta <- (Meta.MaybeUsed,[],f1.cf_pos) :: f1.cf_meta;
				(match f1.cf_kind with
				| Method MethInline ->
					if (c.cl_extern || Meta.has Meta.Extern f1.cf_meta) && not (Meta.has Meta.Runtime f1.cf_meta) then error [Has_no_runtime_field (a,n)];
				| _ -> ());
			) an.a_fields;
			(match !(an.a_status) with
			| Opened -> an.a_status := Closed;
			| Statics _ | EnumStatics _ | AbstractStatics _ -> error []
			| Closed | Extend _ | Const -> ())
		with
			Unify_error l -> error (cannot_unify a b :: l))
	| TAnon a1, TAnon a2 ->
		unify_anons a b a1 a2
	| TAnon an, TAbstract ({ a_path = [],"Class" },[pt]) ->
		(match !(an.a_status) with
		| Statics cl -> unify (TInst (cl,List.map (fun _ -> mk_mono()) cl.cl_params)) pt
		| _ -> error [cannot_unify a b])
	| TAnon an, TAbstract ({ a_path = [],"Enum" },[pt]) ->
		(match !(an.a_status) with
		| EnumStatics e -> unify (TEnum (e,List.map (fun _ -> mk_mono()) e.e_params)) pt
		| _ -> error [cannot_unify a b])
	| TEnum _, TAbstract ({ a_path = [],"EnumValue" },[]) ->
		()
	| TEnum(en,_), TAbstract ({ a_path = ["haxe"],"FlatEnum" },[]) when Meta.has Meta.FlatEnum en.e_meta ->
		()
	| TFun _, TAbstract ({ a_path = ["haxe"],"Function" },[]) ->
		()
	| TInst(c,tl),TAbstract({a_path = ["haxe"],"Constructible"},[t1]) ->
		begin try
			begin match c.cl_kind with
				| KTypeParameter tl ->
					(* type parameters require an equal Constructible constraint *)
					if not (List.exists (fun t -> match follow t with TAbstract({a_path = ["haxe"],"Constructible"},[t2]) -> type_iseq t1 t2 | _ -> false) tl) then error [cannot_unify a b]
				| _ ->
					let _,t,cf = class_field c tl "new" in
					if not cf.cf_public then error [invalid_visibility "new"];
					begin try unify t t1
					with Unify_error l -> error (cannot_unify a b :: l) end
			end
		with Not_found ->
			error [has_no_field a "new"]
		end
	| TDynamic t , _ ->
		if t == a then
			()
		else (match b with
		| TDynamic t2 ->
			if t2 != b then
				(try
					type_eq EqRightDynamic t t2
				with
					Unify_error l -> error (cannot_unify a b :: l));
		| TAbstract(bb,tl) when (List.exists (unify_from bb tl a b) bb.a_from) ->
			()
		| _ ->
			error [cannot_unify a b])
	| _ , TDynamic t ->
		if t == b then
			()
		else (match a with
		| TDynamic t2 ->
			if t2 != a then
				(try
					type_eq EqRightDynamic t t2
				with
					Unify_error l -> error (cannot_unify a b :: l));
		| TAnon an ->
			(try
				(match !(an.a_status) with
				| Statics _ | EnumStatics _ -> error []
				| Opened -> an.a_status := Closed
				| _ -> ());
				PMap.iter (fun _ f ->
					try
						type_eq EqStrict (field_type f) t
					with Unify_error l ->
						error (invalid_field f.cf_name :: l)
				) an.a_fields
			with Unify_error l ->
				error (cannot_unify a b :: l))
		| TAbstract(aa,tl) when (List.exists (unify_to aa tl b) aa.a_to) ->
			()
		| _ ->
			error [cannot_unify a b])
	| TAbstract (aa,tl), _  ->
		if not (List.exists (unify_to aa tl b) aa.a_to) then error [cannot_unify a b];
	| TInst ({ cl_kind = KTypeParameter ctl } as c,pl), TAbstract (bb,tl) ->
		(* one of the constraints must satisfy the abstract *)
		if not (List.exists (fun t ->
			let t = apply_params c.cl_params pl t in
			try unify t b; true with Unify_error _ -> false
		) ctl) && not (List.exists (unify_from bb tl a b) bb.a_from) then error [cannot_unify a b];
	| _, TAbstract (bb,tl) ->
		if not (List.exists (unify_from bb tl a b) bb.a_from) then error [cannot_unify a b]
	| _ , _ ->
		error [cannot_unify a b]

and unify_lifted_types t1 t2 c1 c2 =
		unify_lifted_types1 t1 t2 t1 t2 c1 c2


and s_lifted_type lt =
	let s_type1 = s_type (print_context()) in
	let st_params params = (String.concat ", " (List.map s_lifted_type params)) in
	let s_opt f v = match v with
	| Some x -> "Some(" ^ (f x) ^ ")"
	| None -> "None"
	in

	match validate_lifted lt with
	| LTNestedMono(t, params) -> "LTNestedMono(" ^ (s_type1 t) ^ ",[" ^ (st_params params) ^ "])"
	| LTFunc(t,args,ret) -> "LTFunc(" ^ (s_type1 t) ^ ",[" ^ (st_params args) ^ "]," ^ (s_opt s_lifted_type ret) ^ ")"
	| LTNested(t,params) -> "LTNested(" ^ (s_type1 t) ^ ",[" ^ (st_params params) ^ "])"
	| LTLeaf(t) -> "LTLeaf(" ^ (s_type1 t) ^ ")"


and unify_lifted_types1 t1 t2 o1 o2 c1 c2 =
	let eq_length p1 p2 =
		List.length p1 = List.length p2
	in
	let unify_lifted_types t1 t2 = unify_lifted_types1 t1 t2 o1 o2 c1 c2 in
	let s_type1 = s_type (print_context()) in
	let st = s_lifted_type in
	let unify_lifted_types_params p1 p2 =
		if (List.length p1) == (List.length p2) then
			List.iter2 (fun a b ->
				unify_lifted_types a b
			) p1 p2
		else
			begin
			Printf.printf
				"failed to unify_param\n---------start\n%s\n%s\nin\n%s\n%s\n"
				(st t1) (st t2) (st o1) (st o2);
			(*Printf.printf
				"with\n%s\n%s\nin\n%s\n%s\n"
				 (s_type1 (reduce_lifted_type t1)) (s_type1 (reduce_lifted_type t2)) (s_type1 (reduce_lifted_type o1)) (s_type1 (reduce_lifted_type o1));*)
			Printf.printf
					"with\n%s\n%s\n\n"
					(s_type1 (normalize_of_type c1))
					(s_type1 (normalize_of_type c2));
			Printf.printf "-------------end\n";
			error [Unify_custom ("failed to unify_param" ^ (st t1) ^ " to " ^ (st t2)) ]
			end
	in
	let reduce_mono_params p1 depth =
		let rec loop p1 d =
			match p1,d with
			| _, 0 ->
				p1
			| ((LTNestedMono(_, _) as nm)::z::p1), d ->
				let rec loop1 nm z = match nm with
				| LTNestedMono(TMono _ as a, [LTLeaf(TMono _ as b)]) ->
					LTNestedMono(a, [LTNestedMono(b, [z])])
				| LTNestedMono(TMono _ as a, [LTLeaf(TMono _ as b); LTLeaf(TMono _ as c)]) ->
					LTNestedMono(a, [LTNestedMono(b, [LTNestedMono(c, [z])])])
				| LTNestedMono(TMono _ as a, [LTNestedMono(_,_) as z1]) ->
					loop1 z1 (LTNestedMono(a, [z]))
				(*| LTNestedMono(TMono _ as a, [z1]) ->
					LTNestedMono(a, [z1])*)

				| _ ->
					Printf.printf "UNEXPECTED: %s\n" (s_lifted_type nm);
					assert false
				in
				let nm = loop1 nm z in
				loop (nm::p1) (d-1)
			| (LTLeaf(TMono _ as x)::y::p1), d ->
				let p1 = (LTNestedMono(x, [y])::p1) in
				loop p1 (d-1)
			| _ ->
				assert false
		in
		loop p1 depth
	in
	let reduce_nested_param t2 p2 d =
		let rec loop t2 p2 d =
			match p2,d with
			| _, 0 ->
				t2, p2
			| (x::p2), d ->
				loop (unapply_in1 t2 (reduce_lifted_type x)) p2 (d-1)
			| _ ->
				assert false
		in
		loop t2 p2 d
	in
	let unify_type_constructor t1 t2 =
		let rec loop t1 t2 =
			match t1, t2 with
			| TInst({ cl_kind = KGenericInstance(t, tl)}, []), b ->
				loop (TInst(t, tl)) b
			| a, TInst({ cl_kind = KGenericInstance(t, tl)},[]) ->
				loop a (TInst(t, tl))
			| t1, t2 -> unify t1 t2
		in
		loop t1 t2
	in
	let unify_nested_mono_right t1 p1 t2 p2 =
		let l1 = List.length p1 in
		let l2 = List.length p2 in

		(match List.length p1, List.length p2 with
		| l1, l2 when l1 < l2 ->
			let p2 = reduce_mono_params p2 (l2-l1) in
			unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2
		| l1, l2 when l1 > l2 ->
			let t1, p1 = reduce_nested_param t1 p1 (l1-l2) in
			unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2
		| _ ->
			(unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2))
	in
	let unify_nested_mono_left t1 p1 t2 p2 =
		let l1 = List.length p1 in
		let l2 = List.length p2 in

		(match List.length p1, List.length p2 with
		| l1, l2 when l1 > l2 ->
			let p1 = reduce_mono_params p1 (l1-l2) in
			unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2
		| l1, l2 when l1 < l2 ->
			let t2, p2 = reduce_nested_param t2 p2 (l2-l1) in
			unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2
		| _ ->
			(unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2))
	in
	let unify_nested_both t1 p1 t2 p2 =
		let l1 = List.length p1 in
		let l2 = List.length p2 in

		(match List.length p1, List.length p2 with
		| l1, l2 when l1 > l2 ->
			let t1, p1 = reduce_nested_param t1 p1 (l1-l2) in
			unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2
		| l1, l2 when l1 < l2 ->
			let t2, p2 = reduce_nested_param t2 p2 (l2-l1) in
			unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2
		| _ ->
			(unify_type_constructor t1 t2;
			unify_lifted_types_params p1 p2))
	in
	let unify_with_type_param_right a tp =
		let a = reduce_lifted_type a in
		begin match tp with
		| TInst({ cl_kind = KTypeParameter tps }, []) ->
			List.iter (fun t -> unify a t) tps
		| _ -> assert false
		end
	in
	let unify_with_type_param_left tp b =
		let b = reduce_lifted_type b in
		begin match tp with
		| TInst({ cl_kind = KTypeParameter tps }, []) ->
			List.iter (fun t -> unify b t) tps
		| _ -> assert false
		end
	in
	let lt1 = t1 in
	let lt2 = t2 in
	(match lt1, lt2 with
		| LTFunc(t1, p1, None) as a, LTNestedMono(t2, p2) ->
			unify_nested_mono_right t1 p1 t2 p2
		| LTFunc(t1, p1, Some r), LTNestedMono(t2, p2) ->
			let p1 = p1@[r] in
			unify_nested_mono_right t1 p1 t2 p2
		| LTNestedMono(t1, p1), (LTFunc(t2, p2, None ) as b) ->
			unify_nested_mono_left t1 p1 t2 p2
		| LTNestedMono(t1, p1), (LTFunc(t2, p2, Some r) as b) ->
			let p2 = p2@[r] in
			unify_nested_mono_left t1 p1 t2 p2
		| LTNested(t1, p1) as a, (LTNestedMono(t2, p2) as nm) ->
			unify_nested_mono_right t1 p1 t2 p2
		| LTNestedMono(t1, p1), LTNested(t2, p2) ->
			unify_nested_mono_left t1 p1 t2 p2
		| LTNestedMono(t1, p1), LTNestedMono(t2, p2) ->
			unify t1 t2;
			unify_lifted_types_params p1 p2
		| LTNested(t1, p1), LTNested(t2, p2) ->
			unify_nested_both t1 p1 t2 p2
		| LTFunc(f1, args1, None), LTFunc(f2, args2, None) ->
			unify_nested_both f1 args1 f2 args2
		| LTFunc(f1, args1, Some(ret1)), LTFunc(f2, args2, Some(ret2) ) ->
			unify_nested_both f1 (args1@[ret1]) f2 (args2@[ret2])

		| LTNestedMono(m, _), LTLeaf(t2) when isKTypeParameter t2 ->

			unify_with_type_param_right t1 t2
		| LTNested(_, _), LTLeaf(t2) when isKTypeParameter t2 ->
			unify_with_type_param_right t1 t2
		| LTFunc(_,_,_), LTLeaf(t2) when isKTypeParameter t2 ->
			unify_with_type_param_right t1 t2
		| LTLeaf(t1), LTNested(_, _) when isKTypeParameter t1 ->
			unify_with_type_param_left t1 t2
		| LTLeaf(t1), LTFunc(_,_,None) when isKTypeParameter t1 ->
			unify_with_type_param_left t1 t2
		| LTLeaf(t1), LTFunc(_,_,_) when isKTypeParameter t1 ->
			unify_with_type_param_left t1 t2
		| LTLeaf(t1), LTNestedMono(_,_) when isKTypeParameter t1 ->
			unify_with_type_param_left t1 t2

		| LTNestedMono(ta, _), LTLeaf(t2) when is_in_type t2 ->
			()
		| LTNested(_, _), LTLeaf(t2) when is_in_type t2 ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTFunc(_,_,_), LTLeaf(t2) when is_in_type t2 ->
			()
		| LTLeaf(t1), LTNestedMono(ta, _) when is_in_type t1 ->
			()

		| LTLeaf(t1), LTNested(_, _) when is_in_type t1 ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTLeaf(t1), LTFunc(_,_,None) when is_in_type t1 ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTLeaf(t1), LTFunc(_,_,Some(_)) when is_in_type t1 ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTLeaf(t1), LTLeaf(t2) when is_in_type t1 && is_in_type t2 ->
			()
		| LTLeaf(t1), LTLeaf(t2) when is_in_type t1 ->
			let st = s_type (print_context ()) in
			Printf.printf "%s\n" (st t2);
			Printf.printf "%s\n" (st c2);
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTLeaf(t1), LTLeaf(t2) when is_in_type t2 ->
			let st = s_type (print_context ()) in
			Printf.printf "%s\n" (st t2);
			Printf.printf "%s\n" (st c2);
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTLeaf(t1), LTLeaf(t2) ->
			unify (follow1 t1) (follow1 t2)
		| (LTNestedMono(a, [p]) as nm), LTLeaf((TMono _) as b) ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
			(*unify (reduce_lifted_type nm) b*)
			(*unify a b;
			let nm = unapply_in1_right a (reduce_lifted_type p) in
			let nm = lift_type nm in
			unify_lifted_types nm (lift_type b)*)
		| (LTNestedMono(a, p) as nm), LTLeaf((TMono _) as b) ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTLeaf((TMono _) as a), (LTNestedMono(b, [p]) as nm) ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
			(*unify a b;
			let nm = unapply_in1_right b (reduce_lifted_type p) in
			let nm = lift_type nm in
			unify_lifted_types (lift_type a) nm*)
		| LTLeaf((TMono _) as a), (LTNestedMono(b, p) as nm) ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTNested(_, _), LTLeaf(TMono _) ->
			unify (reduce_lifted_type t1) (reduce_lifted_type t2)
		| LTFunc(_,_,None), LTLeaf(TMono _) ->
			unify (reduce_lifted_type t1) (reduce_lifted_type t2)
		| LTFunc(_,_,_), LTLeaf(TMono _) ->
			unify (reduce_lifted_type t1) (reduce_lifted_type t2)
		| LTLeaf(TMono _), LTNested(_, _) ->
			unify (reduce_lifted_type t1) (reduce_lifted_type t2)
		| LTLeaf(TMono _), LTFunc(_,_,_) ->
			unify (reduce_lifted_type t1) (reduce_lifted_type t2)
		| LTNested(a, p1), LTFunc(b, args, None) ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTNested(a, p1), LTFunc(b, args, Some ret) ->
			unify a b;
			unify_lifted_types_params p1 (args @ [ret]);
		| LTFunc(a, args, None), LTNested(b, p1) ->
			Printf.printf "ASSERT unexpected unify %s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type lt1) (reduce_lifted_type lt2)]
		| LTFunc(a, args, Some ret), LTNested(b, p1) ->
			unify a b;
			unify_lifted_types_params (args @ [ret]) p1;
		| LTLeaf(t), LTNested(_, _) ->
			begin match reduce_lifted_type lt2 with
			| t2 when is_of_type t2 -> error [cannot_unify t t2]
			| t2 -> unify t t2
			end
		| LTNested(_,_), LTLeaf(t) ->
			begin match reduce_lifted_type lt2 with
			| t2 when is_of_type t2 -> error [cannot_unify t2 t]
			| t2 -> unify t2 t
			end
		| LTLeaf(t), LTNestedMono(_,_) ->
			begin match reduce_lifted_type lt2 with
			| t2 when is_of_type t2 -> error [cannot_unify t t2]
			| t2 -> unify t t2
			end
		| _, _ ->
			Printf.printf "%s %s\n" (s_lifted_type lt1) (s_lifted_type lt2);
			error [cannot_unify (reduce_lifted_type t1) (reduce_lifted_type t2)]
			(*Printf.printf "failed to unify3\n--start\n%s\n%s\nin\n%s\n%s\n--end\n" (st t1) (st t2) (st o1) (st o2);
			Printf.printf
				"with\n%s\n%s\nin\n%s\n%s\n--end\n"
				 (s_type1 (reduce_lifted_type t1)) (s_type1 (reduce_lifted_type t2)) (s_type1 (reduce_lifted_type o1)) (s_type1 (reduce_lifted_type o1));
				Printf.printf
					"with\n%s\n%s\n--end\n"
					(s_type1 (normalize_of_type c1))
					(s_type1 (normalize_of_type c2));*)
			(*error [Unify_custom ("failed to unify" ^ (st t1) ^ " to " ^ (st t2)) ]*)
	)

and unify_of a b =
	let err str =
		let st = s_type (print_context ()) in
		error [Unify_custom (str ^ "\ncannot unify " ^ (st a) ^ " with " ^ (st b)) ]
	in
	let st = s_type (print_context ()) in
	let beforeA = st a in
	let beforeB = st b in
	log_type "try unify_of A" a;
	log_type "try unify_of B" b;
	log_normalized_type "try unify_of A" a;
	log_normalized_type "try unify_of B" b;
	log_lifted_type "try unify_of A" (lift_type a);
	log_lifted_type "try unify_of B" (lift_type b);
	log_type "try unify_of A" (reduce_lifted_type (lift_type a));
	log_type "try unify_of B" (reduce_lifted_type (lift_type b));
	log_normalized_type "try unify_of A" (reduce_lifted_type (lift_type a));
	log_normalized_type "try unify_of B" (reduce_lifted_type (lift_type b));
	(*Printf.printf "try unify_of %s => %s\n" (beforeA) (beforeB);
	Printf.printf "try unify_of %s => %s\n" (s_lifted_type (lift_type a)) (s_lifted_type (lift_type b));*)
	(try

		unify_lifted_types (lift_type a) (lift_type b) a b;
		log_type "success unify_of A" a;
		log_type "success unify_of B" b;
		log_normalized_type "success unify_of A" a;
		log_normalized_type "success unify_of B" b;
		log_lifted_type "success unify_of A" (lift_type a);
		log_lifted_type "success unify_of B" (lift_type b);
		(*Printf.printf "success unify_of %s => %s\n" (st a) (st b)*)
	with e ->
		log_type "error unify_of A" a;
		log_type "error unify_of B" b;
		log_normalized_type "error unify_of A" a;
		log_normalized_type "error unify_of B" b;
		log_lifted_type "error unify_of A" (lift_type a);
		log_lifted_type "error unify_of B" (lift_type b);
		(*Printf.printf "error for unify_of %s => %s\n" (st a) (st b);
		Printf.printf "error for unify_of %s => %s\n" (beforeA) (beforeB);*)
		raise e
		(*err "Unify Error"*)
	)

and unify_abstracts a b a1 tl1 a2 tl2 =
	let f1 = unify_to a1 tl1 b in
		let f2 = unify_from a2 tl2 a b in
		if (List.exists (f1 ~allow_transitive_cast:false) a1.a_to)
		|| (List.exists (f2 ~allow_transitive_cast:false) a2.a_from)
		|| (((Meta.has Meta.CoreType a1.a_meta) || (Meta.has Meta.CoreType a2.a_meta))
			&& ((List.exists f1 a1.a_to) || (List.exists f2 a2.a_from))) then
			()
		else
			error [cannot_unify a b]

and unify_anons a b a1 a2 =
	(try
		PMap.iter (fun n f2 ->
		try
			let f1 = PMap.find n a1.a_fields in
			if not (unify_kind f1.cf_kind f2.cf_kind) then
				(match !(a1.a_status), f1.cf_kind, f2.cf_kind with
				| Opened, Var { v_read = AccNormal; v_write = AccNo }, Var { v_read = AccNormal; v_write = AccNormal } ->
					f1.cf_kind <- f2.cf_kind;
				| _ -> error [invalid_kind n f1.cf_kind f2.cf_kind]);
			if f2.cf_public && not f1.cf_public then error [invalid_visibility n];
			try
				unify_with_access (field_type f1) f2;
				(match !(a1.a_status) with
				| Statics c when not (Meta.has Meta.MaybeUsed f1.cf_meta) -> f1.cf_meta <- (Meta.MaybeUsed,[],f1.cf_pos) :: f1.cf_meta
				| _ -> ());
			with
				Unify_error l -> error (invalid_field n :: l)
		with
			Not_found ->
				match !(a1.a_status) with
				| Opened ->
					if not (link (ref None) a f2.cf_type) then error [];
					a1.a_fields <- PMap.add n f2 a1.a_fields
				| Const when Meta.has Meta.Optional f2.cf_meta ->
					()
				| _ ->
					error [has_no_field a n];
		) a2.a_fields;
		(match !(a1.a_status) with
		| Const when not (PMap.is_empty a2.a_fields) ->
			PMap.iter (fun n _ -> if not (PMap.mem n a2.a_fields) then error [has_extra_field a n]) a1.a_fields;
		| Opened ->
			a1.a_status := Closed
		| _ -> ());
		(match !(a2.a_status) with
		| Statics c -> (match !(a1.a_status) with Statics c2 when c == c2 -> () | _ -> error [])
		| EnumStatics e -> (match !(a1.a_status) with EnumStatics e2 when e == e2 -> () | _ -> error [])
		| AbstractStatics a -> (match !(a1.a_status) with AbstractStatics a2 when a == a2 -> () | _ -> error [])
		| Opened -> a2.a_status := Closed
		| Const | Extend _ | Closed -> ())
	with
		Unify_error l -> error (cannot_unify a b :: l))

and unify_from ab tl a b ?(allow_transitive_cast=true) t =
	rec_stack_bool abstract_cast_stack (a,b)
		(fun (a2,b2) -> fast_eq a a2 && fast_eq b b2)
		(fun() ->
			let t = apply_params ab.a_params tl t in
			let unify_func = if allow_transitive_cast then unify else type_eq EqStrict in
			unify_func a t)

and unify_to ab tl b ?(allow_transitive_cast=true) t =
	let t = apply_params ab.a_params tl t in
	let unify_func = if allow_transitive_cast then unify else type_eq EqStrict in
	try
		unify_func t b;
		true
	with Unify_error _ ->
		false

and unify_from_field ab tl a b ?(allow_transitive_cast=true) (t,cf) =
	rec_stack_bool abstract_cast_stack (a,b)
		(fun (a2,b2) -> fast_eq a a2 && fast_eq b b2)
		(fun() ->
			let unify_func = if allow_transitive_cast then unify else type_eq EqStrict in
			match follow cf.cf_type with
			| TFun(_,r) ->
				let monos = List.map (fun _ -> mk_mono()) cf.cf_params in
				let map t = apply_params ab.a_params tl (apply_params cf.cf_params monos t) in
				unify_func a (map t);
				List.iter2 (fun m (name,t) -> match follow t with
					| TInst ({ cl_kind = KTypeParameter constr },_) when constr <> [] ->
						List.iter (fun tc -> match follow m with TMono _ -> raise (Unify_error []) | _ -> unify m (map tc) ) constr
					| _ -> ()
				) monos cf.cf_params;
				unify_func (map r) b;
				true
			| _ -> assert false)

and unify_to_field ab tl b ?(allow_transitive_cast=true) (t,cf) =
	let a = TAbstract(ab,tl) in
	rec_stack_bool abstract_cast_stack (b,a)
		(fun (b2,a2) -> fast_eq a a2 && fast_eq b b2)
		(fun() ->
			let unify_func = if allow_transitive_cast then unify else type_eq EqStrict in
			match follow cf.cf_type with
			| TFun((_,_,ta) :: _,_) ->
				let monos = List.map (fun _ -> mk_mono()) cf.cf_params in
				let map t = apply_params ab.a_params tl (apply_params cf.cf_params monos t) in
				let athis = map ab.a_this in
				(* we cannot allow implicit casts when the this type is not completely known yet *)
				(* if has_mono athis then raise (Unify_error []); *)
				with_variance (type_eq EqStrict) athis (map ta);
				(* immediate constraints checking is ok here because we know there are no monomorphs *)
				List.iter2 (fun m (name,t) -> match follow t with
					| TInst ({ cl_kind = KTypeParameter constr },_) when constr <> [] ->
						List.iter (fun tc -> match follow m with TMono _ -> raise (Unify_error []) | _ -> unify m (map tc) ) constr
					| _ -> ()
				) monos cf.cf_params;
				unify_func (map t) b;
			| _ -> assert false)

and unify_with_variance f t1 t2 =
	let allows_variance_to t tf = type_iseq tf t in
	match follow t1,follow t2 with
	| TInst(c1,tl1),TInst(c2,tl2) when c1 == c2 ->
		List.iter2 f tl1 tl2
	| TEnum(en1,tl1),TEnum(en2,tl2) when en1 == en2 ->
		List.iter2 f tl1 tl2
	| TAbstract(a1,tl1),TAbstract(a2,tl2) when a1 == a2 && Meta.has Meta.CoreType a1.a_meta ->
		List.iter2 f tl1 tl2
	| TAbstract(a1,pl1),TAbstract(a2,pl2) ->
		if (Meta.has Meta.CoreType a1.a_meta) && (Meta.has Meta.CoreType a2.a_meta) then begin
			let ta1 = apply_params a1.a_params pl1 a1.a_this in
			let ta2 = apply_params a2.a_params pl2 a2.a_this in
			type_eq EqStrict ta1 ta2;
		end;
		if not (List.exists (allows_variance_to t2) a1.a_to) && not (List.exists (allows_variance_to t1) a2.a_from) then
			error [cannot_unify t1 t2]
	| TAbstract(a,pl),t ->
		type_eq EqBothDynamic (apply_params a.a_params pl a.a_this) t;
		if not (List.exists (fun t2 -> allows_variance_to t (apply_params a.a_params pl t2)) a.a_to) then error [cannot_unify t1 t2]
	| t,TAbstract(a,pl) ->
		type_eq EqBothDynamic t (apply_params a.a_params pl a.a_this);
		if not (List.exists (fun t2 -> allows_variance_to t (apply_params a.a_params pl t2)) a.a_from) then error [cannot_unify t1 t2]
	| (TAnon a1 as t1), (TAnon a2 as t2) ->
		rec_stack unify_stack (t1,t2)
			(fun (a,b) -> fast_eq a t1 && fast_eq b t2)
			(fun() -> unify_anons t1 t2 a1 a2)
			(fun l -> error l)
	| _ ->
		error [cannot_unify t1 t2]



and unify_type_params a b tl1 tl2 =
	List.iter2 (fun t1 t2 ->
		try
			with_variance (type_eq EqRightDynamic) t1 t2
		with Unify_error l ->
			try
				let rec loop t1 t2 =
					match follow1 t1, follow1 t2 with
					(*| TInst( { cl_kind = KTypeParameter kt1} as c1, p1), TInst( { cl_kind = KTypeParameter kt2} as c2, p2) ->
						if kt1 == kt2 && c1.cl_path == c2.cl_path && p1 == p2 && c1.cl_module == c2.cl_module then
							()
						else
							raise (Unify_error l)*)
					| TInst( { cl_kind = KGenericInstance(c, tl)}, []), b ->
						loop (TInst(c, tl)) b
					| a, TInst( { cl_kind = KGenericInstance(c, tl)}, []) ->
						loop a (TInst(c, tl))
					| a,b when is_in_type a ->
						()
					| a,b when (is_of_type t1) || (is_of_type t2) ->
						(try
								unify_of t1 t2
							with Unify_error l ->
								with_variance (type_eq EqRightDynamic) (reduce_of t1) (reduce_of t2))
					| _ ->
						begin try
							with_variance (type_eq EqRightDynamic) (reduce_of_rec t1) (reduce_of_rec t2)
						with Unify_error l ->
							raise (Unify_error l)
						end
					in
					loop t1 t2
			with Unify_error l ->
				let st = s_type (print_context()) in
				(*Printf.printf "INVARIANT %s => %s | %b => %b | %b\n" (st t1) (st t2) (is_of_type t1) (is_of_type t2) (t1 == t2) ;*)
				let err = cannot_unify a b in
				error (err :: (Invariant_parameter (t1,t2)) :: l)
	) tl1 tl2

and with_variance f t1 t2 =
	try
		f t1 t2
	with Unify_error l -> try
		unify_with_variance (with_variance f) t1 t2
	with Unify_error _ ->
		raise (Unify_error l)

and unify_with_access t1 f2 =
	match f2.cf_kind with
	(* write only *)
	| Var { v_read = AccNo } | Var { v_read = AccNever } -> unify f2.cf_type t1
	(* read only *)
	| Method MethNormal | Method MethInline | Var { v_write = AccNo } | Var { v_write = AccNever } -> unify t1 f2.cf_type
	(* read/write *)
	| _ -> with_variance (type_eq EqBothDynamic) t1 f2.cf_type

(* ======= Mapping and iterating ======= *)

let iter f e =
	match e.eexpr with
	| TConst _
	| TLocal _
	| TBreak
	| TContinue
	| TTypeExpr _
	| TIdent _ ->
		()
	| TArray (e1,e2)
	| TBinop (_,e1,e2)
	| TFor (_,e1,e2)
	| TWhile (e1,e2,_) ->
		f e1;
		f e2;
	| TThrow e
	| TField (e,_)
	| TEnumParameter (e,_,_)
	| TEnumIndex e
	| TParenthesis e
	| TCast (e,_)
	| TUnop (_,_,e)
	| TMeta(_,e) ->
		f e
	| TArrayDecl el
	| TNew (_,_,el)
	| TBlock el ->
		List.iter f el
	| TObjectDecl fl ->
		List.iter (fun (_,e) -> f e) fl
	| TCall (e,el) ->
		f e;
		List.iter f el
	| TVar (v,eo) ->
		(match eo with None -> () | Some e -> f e)
	| TFunction fu ->
		f fu.tf_expr
	| TIf (e,e1,e2) ->
		f e;
		f e1;
		(match e2 with None -> () | Some e -> f e)
	| TSwitch (e,cases,def) ->
		f e;
		List.iter (fun (el,e2) -> List.iter f el; f e2) cases;
		(match def with None -> () | Some e -> f e)
	| TTry (e,catches) ->
		f e;
		List.iter (fun (_,e) -> f e) catches
	| TReturn eo ->
		(match eo with None -> () | Some e -> f e)

let map_expr f e =
	match e.eexpr with
	| TConst _
	| TLocal _
	| TBreak
	| TContinue
	| TTypeExpr _
	| TIdent _ ->
		e
	| TArray (e1,e2) ->
		let e1 = f e1 in
		{ e with eexpr = TArray (e1,f e2) }
	| TBinop (op,e1,e2) ->
		let e1 = f e1 in
		{ e with eexpr = TBinop (op,e1,f e2) }
	| TFor (v,e1,e2) ->
		let e1 = f e1 in
		{ e with eexpr = TFor (v,e1,f e2) }
	| TWhile (e1,e2,flag) ->
		let e1 = f e1 in
		{ e with eexpr = TWhile (e1,f e2,flag) }
	| TThrow e1 ->
		{ e with eexpr = TThrow (f e1) }
	| TEnumParameter (e1,ef,i) ->
		{ e with eexpr = TEnumParameter(f e1,ef,i) }
	| TEnumIndex e1 ->
		{ e with eexpr = TEnumIndex (f e1) }
	| TField (e1,v) ->
		{ e with eexpr = TField (f e1,v) }
	| TParenthesis e1 ->
		{ e with eexpr = TParenthesis (f e1) }
	| TUnop (op,pre,e1) ->
		{ e with eexpr = TUnop (op,pre,f e1) }
	| TArrayDecl el ->
		{ e with eexpr = TArrayDecl (List.map f el) }
	| TNew (t,pl,el) ->
		{ e with eexpr = TNew (t,pl,List.map f el) }
	| TBlock el ->
		{ e with eexpr = TBlock (List.map f el) }
	| TObjectDecl el ->
		{ e with eexpr = TObjectDecl (List.map (fun (v,e) -> v, f e) el) }
	| TCall (e1,el) ->
		let e1 = f e1 in
		{ e with eexpr = TCall (e1, List.map f el) }
	| TVar (v,eo) ->
		{ e with eexpr = TVar (v, match eo with None -> None | Some e -> Some (f e)) }
	| TFunction fu ->
		{ e with eexpr = TFunction { fu with tf_expr = f fu.tf_expr } }
	| TIf (ec,e1,e2) ->
		let ec = f ec in
		let e1 = f e1 in
		{ e with eexpr = TIf (ec,e1,match e2 with None -> None | Some e -> Some (f e)) }
	| TSwitch (e1,cases,def) ->
		let e1 = f e1 in
		let cases = List.map (fun (el,e2) -> List.map f el, f e2) cases in
		{ e with eexpr = TSwitch (e1, cases, match def with None -> None | Some e -> Some (f e)) }
	| TTry (e1,catches) ->
		let e1 = f e1 in
		{ e with eexpr = TTry (e1, List.map (fun (v,e) -> v, f e) catches) }
	| TReturn eo ->
		{ e with eexpr = TReturn (match eo with None -> None | Some e -> Some (f e)) }
	| TCast (e1,t) ->
		{ e with eexpr = TCast (f e1,t) }
	| TMeta (m,e1) ->
		 {e with eexpr = TMeta(m,f e1)}

let map_expr_type f ft fv e =
	match e.eexpr with
	| TConst _
	| TBreak
	| TContinue
	| TTypeExpr _
	| TIdent _ ->
		{ e with etype = ft e.etype }
	| TLocal v ->
		{ e with eexpr = TLocal (fv v); etype = ft e.etype }
	| TArray (e1,e2) ->
		let e1 = f e1 in
		{ e with eexpr = TArray (e1,f e2); etype = ft e.etype }
	| TBinop (op,e1,e2) ->
		let e1 = f e1 in
		{ e with eexpr = TBinop (op,e1,f e2); etype = ft e.etype }
	| TFor (v,e1,e2) ->
		let v = fv v in
		let e1 = f e1 in
		{ e with eexpr = TFor (v,e1,f e2); etype = ft e.etype }
	| TWhile (e1,e2,flag) ->
		let e1 = f e1 in
		{ e with eexpr = TWhile (e1,f e2,flag); etype = ft e.etype }
	| TThrow e1 ->
		{ e with eexpr = TThrow (f e1); etype = ft e.etype }
	| TEnumParameter (e1,ef,i) ->
		{ e with eexpr = TEnumParameter (f e1,ef,i); etype = ft e.etype }
	| TEnumIndex e1 ->
		{ e with eexpr = TEnumIndex (f e1); etype = ft e.etype }
	| TField (e1,v) ->
		let e1 = f e1 in
		let v = try
			let n = match v with
				| FClosure _ -> raise Not_found
				| FAnon f | FInstance (_,_,f) | FStatic (_,f) -> f.cf_name
				| FEnum (_,f) -> f.ef_name
				| FDynamic n -> n
			in
			quick_field e1.etype n
		with Not_found ->
			v
		in
		{ e with eexpr = TField (e1,v); etype = ft e.etype }
	| TParenthesis e1 ->
		{ e with eexpr = TParenthesis (f e1); etype = ft e.etype }
	| TUnop (op,pre,e1) ->
		{ e with eexpr = TUnop (op,pre,f e1); etype = ft e.etype }
	| TArrayDecl el ->
		{ e with eexpr = TArrayDecl (List.map f el); etype = ft e.etype }
	| TNew (c,pl,el) ->
		let et = ft e.etype in
		(* make sure that we use the class corresponding to the replaced type *)
		let t = match c.cl_kind with
			| KTypeParameter _ | KGeneric ->
				et
			| _ ->
				ft (TInst(c,pl))
		in
		let c, pl = (match follow t with TInst (c,pl) -> (c,pl) | TAbstract({a_impl = Some c},pl) -> c,pl | t -> error [has_no_field t "new"]) in
		{ e with eexpr = TNew (c,pl,List.map f el); etype = et }
	| TBlock el ->
		{ e with eexpr = TBlock (List.map f el); etype = ft e.etype }
	| TObjectDecl el ->
		{ e with eexpr = TObjectDecl (List.map (fun (v,e) -> v, f e) el); etype = ft e.etype }
	| TCall (e1,el) ->
		let e1 = f e1 in
		{ e with eexpr = TCall (e1, List.map f el); etype = ft e.etype }
	| TVar (v,eo) ->
		{ e with eexpr = TVar (fv v, match eo with None -> None | Some e -> Some (f e)); etype = ft e.etype }
	| TFunction fu ->
		let fu = {
			tf_expr = f fu.tf_expr;
			tf_args = List.map (fun (v,o) -> fv v, o) fu.tf_args;
			tf_type = ft fu.tf_type;
		} in
		{ e with eexpr = TFunction fu; etype = ft e.etype }
	| TIf (ec,e1,e2) ->
		let ec = f ec in
		let e1 = f e1 in
		{ e with eexpr = TIf (ec,e1,match e2 with None -> None | Some e -> Some (f e)); etype = ft e.etype }
	| TSwitch (e1,cases,def) ->
		let e1 = f e1 in
		let cases = List.map (fun (el,e2) -> List.map f el, f e2) cases in
		{ e with eexpr = TSwitch (e1, cases, match def with None -> None | Some e -> Some (f e)); etype = ft e.etype }
	| TTry (e1,catches) ->
		let e1 = f e1 in
		{ e with eexpr = TTry (e1, List.map (fun (v,e) -> fv v, f e) catches); etype = ft e.etype }
	| TReturn eo ->
		{ e with eexpr = TReturn (match eo with None -> None | Some e -> Some (f e)); etype = ft e.etype }
	| TCast (e1,t) ->
		{ e with eexpr = TCast (f e1,t); etype = ft e.etype }
	| TMeta (m,e1) ->
		{e with eexpr = TMeta(m, f e1); etype = ft e.etype }

let resolve_typedef t =
	match t with
	| TClassDecl _ | TEnumDecl _ | TAbstractDecl _ -> t
	| TTypeDecl td ->
		match follow td.t_type with
		| TEnum (e,_) -> TEnumDecl e
		| TInst (c,_) -> TClassDecl c
		| TAbstract (a,_) -> TAbstractDecl a
		| _ -> t

module TExprToExpr = struct
	let tpath p mp pl =
		if snd mp = snd p then
			CTPath {
				tpackage = fst p;
				tname = snd p;
				tparams = List.map (fun t -> TPType t) pl;
				tsub = None;
			}
		else CTPath {
				tpackage = fst mp;
				tname = snd mp;
				tparams = List.map (fun t -> TPType t) pl;
				tsub = Some (snd p);
			}

	let rec convert_type = function
		| TMono r ->
			(match !r with
			| None -> raise Exit
			| Some t -> convert_type t)
		| TInst ({cl_private = true; cl_path=_,name},tl)
		| TEnum ({e_private = true; e_path=_,name},tl)
		| TType ({t_private = true; t_path=_,name},tl)
		| TAbstract ({a_private = true; a_path=_,name},tl) ->
			CTPath {
				tpackage = [];
				tname = name;
				tparams = List.map (fun t -> TPType (convert_type' t)) tl;
				tsub = None;
			}
		| TEnum (e,pl) ->
			tpath e.e_path e.e_module.m_path (List.map convert_type' pl)
		| TInst({cl_kind = KTypeParameter _} as c,pl) ->
			tpath ([],snd c.cl_path) ([],snd c.cl_path) (List.map convert_type' pl)
		| TInst (c,pl) ->
			tpath c.cl_path c.cl_module.m_path (List.map convert_type' pl)
		| TType (t,pl) as tf ->
			(* recurse on type-type *)
			if (snd t.t_path).[0] = '#' then convert_type (follow tf) else tpath t.t_path t.t_module.m_path (List.map convert_type' pl)
		| TAbstract (a,pl) ->
			tpath a.a_path a.a_module.m_path (List.map convert_type' pl)
		| TFun (args,ret) ->
			CTFunction (List.map (fun (_,_,t) -> convert_type' t) args, (convert_type' ret))
		| TAnon a ->
			begin match !(a.a_status) with
			| Statics c -> tpath ([],"Class") ([],"Class") [tpath c.cl_path c.cl_path [],null_pos]
			| EnumStatics e -> tpath ([],"Enum") ([],"Enum") [tpath e.e_path e.e_path [],null_pos]
			| _ ->
				CTAnonymous (PMap.foldi (fun _ f acc ->
					{
						cff_name = f.cf_name,null_pos;
						cff_kind = FVar (mk_type_hint f.cf_type null_pos,None);
						cff_pos = f.cf_pos;
						cff_doc = f.cf_doc;
						cff_meta = f.cf_meta;
						cff_access = [];
					} :: acc
				) a.a_fields [])
			end
		| (TDynamic t2) as t ->
			tpath ([],"Dynamic") ([],"Dynamic") (if t == t_dynamic then [] else [convert_type' t2])
		| TLazy f ->
			convert_type (lazy_type f)

	and convert_type' t =
		convert_type t,null_pos

	and mk_type_hint t p =
		match follow t with
		| TMono _ -> None
		| _ -> (try Some (convert_type t,p) with Exit -> None)

	let rec convert_expr e =
		let full_type_path t =
			let mp,p = match t with
			| TClassDecl c -> c.cl_module.m_path,c.cl_path
			| TEnumDecl en -> en.e_module.m_path,en.e_path
			| TAbstractDecl a -> a.a_module.m_path,a.a_path
			| TTypeDecl t -> t.t_module.m_path,t.t_path
			in
			if snd mp = snd p then p else (fst mp) @ [snd mp],snd p
		in
		let mk_path = expr_of_type_path in
		let mk_ident = function
			| "`trace" -> Ident "trace"
			| n -> Ident n
		in
		let eopt = function None -> None | Some e -> Some (convert_expr e) in
		((match e.eexpr with
		| TConst c ->
			EConst (tconst_to_const c)
		| TLocal v -> EConst (mk_ident v.v_name)
		| TArray (e1,e2) -> EArray (convert_expr e1,convert_expr e2)
		| TBinop (op,e1,e2) -> EBinop (op, convert_expr e1, convert_expr e2)
		| TField (e,f) -> EField (convert_expr e, field_name f)
		| TTypeExpr t -> fst (mk_path (full_type_path t) e.epos)
		| TParenthesis e -> EParenthesis (convert_expr e)
		| TObjectDecl fl -> EObjectDecl (List.map (fun (k,e) -> k, convert_expr e) fl)
		| TArrayDecl el -> EArrayDecl (List.map convert_expr el)
		| TCall (e,el) -> ECall (convert_expr e,List.map convert_expr el)
		| TNew (c,pl,el) -> ENew ((match (try convert_type (TInst (c,pl)) with Exit -> convert_type (TInst (c,[]))) with CTPath p -> p,null_pos | _ -> assert false),List.map convert_expr el)
		| TUnop (op,p,e) -> EUnop (op,p,convert_expr e)
		| TFunction f ->
			let arg (v,c) = (v.v_name,v.v_pos), false, v.v_meta, mk_type_hint v.v_type null_pos, (match c with None -> None | Some c -> Some (EConst (tconst_to_const c),e.epos)) in
			EFunction (None,{ f_params = []; f_args = List.map arg f.tf_args; f_type = mk_type_hint f.tf_type null_pos; f_expr = Some (convert_expr f.tf_expr) })
		| TVar (v,eo) ->
			EVars ([(v.v_name,v.v_pos), mk_type_hint v.v_type v.v_pos, eopt eo])
		| TBlock el -> EBlock (List.map convert_expr el)
		| TFor (v,it,e) ->
			let ein = (EBinop (OpIn,(EConst (Ident v.v_name),it.epos),convert_expr it),it.epos) in
			EFor (ein,convert_expr e)
		| TIf (e,e1,e2) -> EIf (convert_expr e,convert_expr e1,eopt e2)
		| TWhile (e1,e2,flag) -> EWhile (convert_expr e1, convert_expr e2, flag)
		| TSwitch (e,cases,def) ->
			let cases = List.map (fun (vl,e) ->
				List.map convert_expr vl,None,(match e.eexpr with TBlock [] -> None | _ -> Some (convert_expr e)),e.epos
			) cases in
			let def = match eopt def with None -> None | Some (EBlock [],_) -> Some (None,null_pos) | Some e -> Some (Some e,pos e) in
			ESwitch (convert_expr e,cases,def)
		| TEnumIndex _
		| TEnumParameter _ ->
			(* these are considered complex, so the AST is handled in TMeta(Meta.Ast) *)
			assert false
		| TTry (e,catches) ->
			let e1 = convert_expr e in
			let catches = List.map (fun (v,e) ->
				let ct = try convert_type v.v_type,null_pos with Exit -> assert false in
				let e = convert_expr e in
				(v.v_name,v.v_pos),ct,e,(pos e)
			) catches in
			ETry (e1,catches)
		| TReturn e -> EReturn (eopt e)
		| TBreak -> EBreak
		| TContinue -> EContinue
		| TThrow e -> EThrow (convert_expr e)
		| TCast (e,t) ->
			let t = (match t with
				| None -> None
				| Some t ->
					let t = (match t with TClassDecl c -> TInst (c,[]) | TEnumDecl e -> TEnum (e,[]) | TTypeDecl t -> TType (t,[]) | TAbstractDecl a -> TAbstract (a,[])) in
					Some (try convert_type t,null_pos with Exit -> assert false)
			) in
			ECast (convert_expr e,t)
		| TMeta ((Meta.Ast,[e1,_],_),_) -> e1
		| TMeta (m,e) -> EMeta(m,convert_expr e)
		| TIdent s -> EConst (Ident s))
		,e.epos)

end

module ExtType = struct
	let is_void = function
		| TAbstract({a_path=[],"Void"},_) -> true
		| _ -> false
end

module StringError = struct
	(* Source: http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Levenshtein_distance#OCaml *)
	let levenshtein a b =
		let x = Array.init (String.length a) (fun i -> a.[i]) in
		let y = Array.init (String.length b) (fun i -> b.[i]) in
		let minimum (x:int) y z =
			let m' (a:int) b = if a < b then a else b in
			m' (m' x y) z
		in
		let init_matrix n m =
			let init_col = Array.init m in
				Array.init n (function
				| 0 -> init_col (function j -> j)
				| i -> init_col (function 0 -> i | _ -> 0)
			)
		in
		match Array.length x, Array.length y with
			| 0, n -> n
			| m, 0 -> m
			| m, n ->
				let matrix = init_matrix (m + 1) (n + 1) in
				for i = 1 to m do
					let s = matrix.(i) and t = matrix.(i - 1) in
					for j = 1 to n do
						let cost = abs (compare x.(i - 1) y.(j - 1)) in
						s.(j) <- minimum (t.(j) + 1) (s.(j - 1) + 1) (t.(j - 1) + cost)
					done
				done;
				matrix.(m).(n)

	let filter_similar f cl =
		let rec loop sl = match sl with
			| (x,i) :: sl when f x i -> x :: loop sl
			| _ -> []
		in
		loop cl

	let get_similar s sl =
		if sl = [] then [] else
		let cl = List.map (fun s2 -> s2,levenshtein s s2) sl in
		let cl = List.sort (fun (_,c1) (_,c2) -> compare c1 c2) cl in
		let cl = filter_similar (fun s2 i -> i <= (min (String.length s) (String.length s2)) / 3) cl in
		cl

	let string_error_raise s sl msg =
		if sl = [] then msg else
		let cl = get_similar s sl in
		match cl with
			| [] -> raise Not_found
			| [s] -> Printf.sprintf "%s (Suggestion: %s)" msg s
			| sl -> Printf.sprintf "%s (Suggestions: %s)" msg (String.concat ", " sl)

	let string_error s sl msg =
		try string_error_raise s sl msg
		with Not_found -> msg
end



let class_module_type c = {
	t_path = [],"Class<" ^ (s_type_path c.cl_path) ^ ">" ;
	t_module = c.cl_module;
	t_doc = None;
	t_pos = c.cl_pos;
	t_name_pos = null_pos;
	t_type = TAnon {
		a_fields = c.cl_statics;
		a_status = ref (Statics c);
	};
	t_private = true;
	t_params = [];
	t_meta = no_meta;
}

let enum_module_type m path p  = {
	t_path = [], "Enum<" ^ (s_type_path path) ^ ">";
	t_module = m;
	t_doc = None;
	t_pos = p;
	t_name_pos = null_pos;
	t_type = mk_mono();
	t_private = true;
	t_params = [];
	t_meta = [];
}

let abstract_module_type a tl = {
	t_path = [],Printf.sprintf "Abstract<%s%s>" (s_type_path a.a_path) (s_type_params (ref []) tl);
	t_module = a.a_module;
	t_doc = None;
	t_pos = a.a_pos;
	t_name_pos = null_pos;
	t_type = TAnon {
		a_fields = PMap.empty;
		a_status = ref (AbstractStatics a);
	};
	t_private = true;
	t_params = [];
	t_meta = no_meta;
}

let enable_type_log b =
	(if b then
		let st = s_type (print_context()) in
		(log_type_ref := st;
		log_lifted_type_ref := s_lifted_type;
		log_normalized_type_ref := (fun t -> st (normalize_of_type t));
		log_enabled := true)
	else
		log_enabled := false);