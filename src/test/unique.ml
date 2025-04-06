open Adapton
open Collections 

let min_depth = 10
       
module Make
    (ArtLib : ArtLib.S)
    (Name : Name.S)
    (Elt : Data.S)
    (St : SpreadTree.S with type name = Name.t
                        and type elt = Elt.t) = struct  
  module List = St.List
  module Set = Trie.Set.Make(Name)(ArtLib)(Elt)
                            
  (* This code assumes that names and articulation points always come in the
   `Name (_, `Art _) pattern (as the list_map above seems to).
   *)
  let list_unique : (Elt.t * Elt.t) -> List.t -> List.t =
    fun (zero, one) ->
    let loop = List.Art.mk_mfn (Name.of_string "Unique#list_unique")
    (module Types.Tuple3(Name)(List)(Set))
    (fun loop (nm, l, s) -> match l with
    | `Nil -> `Nil
    | `Cons (i, l') -> (
      let nm1, nm2 = Name.fork nm in
      let i', s' =
        if Set.mem s i
        then one, s
        else zero, Set.add nm1 s i
      in
      `Cons (i', loop.List.Art.mfn_data (nm2, l', s'))
    )
    | `Art a -> loop.List.Art.mfn_data (nm, List.Art.force a, s)
    | `Name (nm, l') ->
       let nm1, nm = Name.fork nm in
       let nm2, nm3 = Name.fork nm in
      `Name (nm1, `Art (loop.List.Art.mfn_nart nm2 (nm3, l', s))))
  in
  (fun l -> loop.List.Art.mfn_data (Name.of_string "Unique.list_unique#root_nm", l, Set.empty ~min_depth ?art_ifreq:None))
end
         
                                              (*
From adapton_structures/SpreadTree.ml
 
let list_map 
(op_nm : Name.t)
(op : Elt.t -> Elt.t)
: St.Listx.Data.t -> St.List.Data.t = 
let fnn = Name.pair (Name.of_string "list_map") op_nm in
let mfn = LArt.mk_mfn fnn
      (module St.List.Data)
      (fun r list -> 
        let list_map = r.LArt.mfn_data in
        match list with
        | `Nil -> `Nil
        | `Cons(x, xs) -> `Cons(op x, list_map xs)
        | `Art(a) -> list_map (LArt.force a)
        | `Name(nm, xs) -> 
          let nm1, nm2 = Name.fork nm in
          `Name(nm1, `Art(r.LArt.mfn_nart nm2 xs))
      )
    in
    fun list -> mfn.LArt.mfn_data list
*)

(*
1,2,3,4,2,3
1,1,1,1,0,0

let rec unique xs seen =
match xs with
   | [] -> []
   | x :: ys ->
     if (find seen x) then 0 else 1) ::
     (unique ys (insert x seen))

let rec unique xs seen =
match xs with
   | [] -> []
   | (x, n) :: ys ->
     if (find seen x) then 0 else 1) ::
     (unique ys (insert n x seen))
*)


(*


module OList = List

module ArtLib = Grifola.Default.ArtLib

module ST = SpreadTree.MakeSpreadTree(ArtLib)(Key)(AdaptonTypes.Int)
module List = ST.List
module Set = Trie.Set.Make(Trie.Useful(AdaptonTypes.Int))(Key)(ArtLib)
let min_depth = 4

(* This code assumes that names and articulation points always come in the
   `Name (_, `Art _) pattern (as the list_map above seems to).
 *)
let list_unique : List.Data.t -> List.Data.t =
  let loop = List.Art.mk_mfn (Key.of_string "Unique#list_unique")
    (module AdaptonTypes.Tuple3(Key)(List.Data)(Set))
    (fun loop (nm, l, s) -> match l with
    | `Nil -> `Nil
    | `Cons (i, l') ->
      let nm', nm'' = Key.fork nm in
      let i', s' =
        if Set.mem s i
        then 1, s
        else 0, Set.nadd nm' s i
      in
      `Cons (i', loop.mfn_data (nm'', l', s'))
    | `Art a -> loop.mfn_data (nm, List.Art.force a, s)
    | `Name (nm, l') ->
      let nm', nm'' = Key.fork nm in
      `Name (nm', `Art (loop.mfn_nart nm'' (nm'', l', s))))
  in
  (fun l -> loop.mfn_data (Key.of_string "Unique.list_unique#root_nm", l, Set.empty ~min_depth))

let lthunk : List.Data.t -> List.Art.t =
  let ident = List.Art.mk_mfn (Key.of_string "Unique#lthunk") (module List.Data)
    (fun _ l -> l)
  in
  ident.mfn_art

let _ =
  let name l = `Name (Key.nondet (), `Art (lthunk l)) in
  let al_of_l (l : int list) : List.Data.t =
    OList.fold_right (fun n a -> name (`Cons (n, a))) l `Nil in
  let rec l_of_al : List.Data.t -> int list = function
    |  `Nil        -> []
    | `Cons (i, l) -> i::(l_of_al l)
    |  `Art  a     -> l_of_al (List.Art.force a)
    | `Name (_, l) -> l_of_al l
  in
  let l0 : int list = []
  and a0 : int list = []
  and l1 = [0;1;2;3;4;5;6;7;8;9]
  and a1 = [0;0;0;0;0;0;0;0;0;0]
  and l2 = [0;1;0;2;0;3;0;4;0;5]
  and a2 = [0;0;1;0;1;0;1;0;1;0]
  in
  let test l a =
    let al  = al_of_l l in
    let al' = list_unique al in
    if l_of_al al' = a
    then print_endline "test passed!"
    else print_endline "test failed."
  in
  test l0 a0 ;
  test l1 a1 ;
  test l2 a2
 *)
