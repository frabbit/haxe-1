open Meta
open Type
open Error

let has_direct_to ab pl b =
	List.exists (unify_to ab pl ~allow_transitive_cast:false b) ab.a_to

let has_direct_from ab pl a b =
	List.exists (unify_from ab pl a ~allow_transitive_cast:false b) ab.a_from

let find_field_to ab pl b =
	List.find (unify_to_field ab pl b) ab.a_to_field

let find_field_from ab pl a b =
	List.find (unify_from_field ab pl a b) ab.a_from_field

let find_to_from f ab_left tl_left ab_right tl_right tleft tright =
	if has_direct_to ab_right tl_right tleft || has_direct_from ab_left tl_left tright tleft then
		raise Not_found
	else
		try f ab_right tl_right (fun () -> find_field_to ab_right tl_right tleft)
		with Not_found -> f ab_left tl_left (fun () -> find_field_from ab_left tl_left tright tleft)

let find_to ab pl b =
	if follow b == t_dynamic then
		List.find (fun (t,_) -> follow t == t_dynamic) ab.a_to_field
	else if has_direct_to ab pl b then
		raise Not_found (* legacy compatibility *)
	else
		find_field_to ab pl b

let find_from ab pl a b =
	if follow a == t_dynamic then
		List.find (fun (t,_) -> follow t == t_dynamic) ab.a_from_field
	else if has_direct_from ab pl a b then
		raise Not_found (* legacy compatibility *)
	else
		find_field_from ab pl a b

let underlying_type_stack = ref []

let rec get_underlying_type a pl =
	let maybe_recurse t =
		if is_of_type t || is_of_type (follow t) then
			t_dynamic
		else begin
			underlying_type_stack := (TAbstract(a,pl)) :: !underlying_type_stack;
			let rec loop t = match t with
				| TMono r ->
					(match !r with
					| Some t -> loop t
					| _ -> t)
				| TLazy f ->
					loop (lazy_type f)
				| TAbstract({a_path=([],"Null")} as a,[t1]) ->
					TAbstract(a,[loop t1])
				| TType (t,tl) ->
					loop (apply_params t.t_params tl t.t_type)
				| TAbstract(a,tl) when not (Meta.has Meta.CoreType a.a_meta) ->
					if List.exists (fast_eq t) !underlying_type_stack then begin
						let pctx = print_context() in
						let s = String.concat " -> " (List.map (fun t -> s_type pctx t) (List.rev (t :: !underlying_type_stack))) in
						underlying_type_stack := [];
						error ("Abstract chain detected: " ^ s) a.a_pos
					end;
					get_underlying_type a tl
				| _ ->
					t
			in
			let t = loop t in
			underlying_type_stack := List.tl !underlying_type_stack;
			t
		end
	in
	try
		if not (Meta.has Meta.MultiType a.a_meta) then raise Not_found;
		let m = mk_mono() in
		let _ = find_to a pl m in
		maybe_recurse (follow m)
	with Not_found ->
		if Meta.has Meta.CoreType a.a_meta then
			t_dynamic
		else match a.a_path,pl with
				| ([],"-Of"),[tm;ta] ->
					(*match tm with
					| TInst({ cl_kind = KGenericInstance(_,_)},[]) ->
						t_dynamic
					| _ ->

						(try
							let x = unapply_in1 tm (reduce_of ta) in
							if is_of_type x then t_dynamic else follow x
						with _ -> t_dynamic)*)
					(*let st = s_type (print_context()) in
					Printf.printf "1: %s\n" (st (mk_of tm ta));*)
					begin match try_reduce_of (mk_of tm ta) with
					| Some (TAbstract({ a_path=([],"-Of")},[tm;_]) as t) ->
						(*let st = s_type (print_context()) in
						Printf.printf "2: %s\n" (st t);*)
						begin match follow tm with
						| TInst({ cl_kind = KGenericInstance(_,_)},[]) ->
							t_dynamic
						| _ -> t_dynamic
						end
					| Some t ->
						begin match follow t with
						| TInst({ cl_kind = KGenericInstance(_,tl)},[]) as t ->
							t_dynamic
							(*if List.exists (fun t -> is_in_type t) tl then
								t_dynamic
							else
								t_dynamic*)

						| _ ->
							(*let st = s_type (print_context()) in
							Printf.printf "3: %s\n" (st t);*)
							follow t
						end
					| None -> t_dynamic
					end

					(*let x, applied = unapply_in tm (reduce_of ta) in
					if applied then
						follow x
					else
						(* not reducible Of type like Of<M, Int> or Of<Of<M, A>, B>, fall
						   back to dynamic *)
						t_dynamic*)
				| _ ->
					maybe_recurse (apply_params a.a_params pl a.a_this)


let rec follow_with_abstracts t = match follow t with
	| TAbstract(a,tl) when not (Meta.has Meta.CoreType a.a_meta) ->
		follow_with_abstracts (get_underlying_type a tl)
	| t ->
		t