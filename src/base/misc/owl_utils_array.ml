(*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2022 Liang Wang <liang@ocaml.xyz>
 *)

(* An extended version of OCaml's array for Owl's internal use. *)

include Array

(* concatenate two arrays *)
let ( @ ) a b = Array.append a b

(* pretty-print an array to string *)
let to_string ?(prefix = "") ?(suffix = "") ?(sep = ",") elt_to_str x =
  let s = Array.to_list x |> List.map elt_to_str |> String.concat sep in
  Printf.sprintf "%s%s%s" prefix s suffix


(* set multiple elements to the same value a in x *)
let set_n x idx a = Array.iter (fun i -> x.(i) <- a) idx

(* Generate an array of continuous integers *)
let range a b =
  let r = Array.make (b - a + 1) 0 in
  for i = a to b do
    r.(i - a) <- i
  done;
  r


(* flatten an array array to array *)
let flatten x =
  let r = Owl_utils_stack.make () in
  iter (fun y -> iter (fun z -> Owl_utils_stack.push r z) y) x;
  Owl_utils_stack.to_array r


(* count the number of occurrence of a in x *)
let count x a =
  let c = ref 0 in
  Array.iter (fun b -> if a = b then c := !c + 1) x;
  !c


(* insert an array y into x starting at the position pos in x *)
let insert x y pos =
  let n = Array.length x in
  let error () =
    let s =
      Printf.sprintf "insert requires 0 <= pos < n, but pos = %i and n = %i" pos n
    in
    Owl_exception.INVALID_ARGUMENT s
  in
  Owl_exception.verify (pos >= 0 && pos < n) error;
  Array.(sub x 0 pos @ y @ sub x pos (n - pos))


(* remove the element at position pos *)
let remove x pos =
  let n = Array.length x in
  let error () =
    let s =
      Printf.sprintf "remove requires 0 <= pos < n, but pos = %i and n = %i" pos n
    in
    Owl_exception.INVALID_ARGUMENT s
  in
  Owl_exception.verify (pos >= 0 && pos < n) error;
  let x0 = Array.sub x 0 pos in
  let x1 = Array.sub x (pos + 1) (n - pos - 1) in
  x0 @ x1


(* replace a subarray starting from ofs of length len in x with y *)
let replace ofs len x y =
  let n = Array.length x in
  let error () =
    let s =
      Printf.sprintf
        "replaec requires ofs + len <= n, but ofs = %i, len = %i, and n = %i"
        ofs
        len
        n
    in
    Owl_exception.INVALID_ARGUMENT s
  in
  Owl_exception.verify (ofs + len <= n) error;
  let x0 = Array.sub x 0 ofs in
  let x1 = Array.sub x (ofs + len) (n - ofs - len) in
  x0 @ y @ x1


(* filter array, f : int -> 'a -> bool * 'b *)
let filteri_v f x =
  let r = Owl_utils_stack.make () in
  iteri
    (fun i a ->
      let y, z = f i a in
      if y = true then Owl_utils_stack.push r z)
    x;
  Owl_utils_stack.to_array r


(* filter array, f : 'a -> bool * 'b *)
let filter_v f x = filteri_v (fun _ y -> f y) x

(* filter array, f : int -> 'a -> bool *)
let filteri f x =
  if Array.length x = 0
  then [||]
  else (
    let r = Owl_utils_stack.make () in
    iteri (fun i a -> if f i a then Owl_utils_stack.push r a) x;
    Owl_utils_stack.to_array r)


(* filter array, f : 'a -> bool *)
let filter f x = filteri (fun _ y -> f y) x

let mapi f x =
  let n = Array.length x in
  if n = 0
  then [||]
  else (
    let r = Owl_utils_stack.make () in
    iteri (fun i a -> Owl_utils_stack.push r (f i a)) x;
    Owl_utils_stack.to_array r)


let map f x = mapi (fun _ y -> f y) x

(* deal with the issue: OCaml 4.02.3 does not have Array.iter2
  eventually we need to move to OCaml 4.03.0 *)
let iter2 f x y =
  let c = min (Array.length x) (Array.length y) in
  for i = 0 to c - 1 do
    f x.(i) y.(i)
  done


let iter2i f x y =
  let c = min (Array.length x) (Array.length y) in
  for i = 0 to c - 1 do
    f i x.(i) y.(i)
  done


let iter3 f x y z =
  let c = min (Array.length x) (Array.length y) |> min (Array.length z) in
  for i = 0 to c - 1 do
    f x.(i) y.(i) z.(i)
  done


let iter3i f x y z =
  let c = min (Array.length x) (Array.length y) |> min (Array.length z) in
  for i = 0 to c - 1 do
    f i x.(i) y.(i) z.(i)
  done


let iter4i f w x y z =
  let nw = Array.length w in
  let nx = Array.length x in
  let ny = Array.length y in
  let nz = Array.length z in
  assert (nw = nx && nx = ny && ny = nz);
  for i = 0 to nw - 1 do
    f i w.(i) x.(i) y.(i) z.(i)
  done


let iter4 f w x y z = iter4i (fun _ a b c d -> f a b c d) w x y z

let map2i f x y =
  let c = min (Array.length x) (Array.length y) in
  Array.init c (fun i -> f i x.(i) y.(i))


(* map two arrays, and split into two arrays, f returns 2-tuple *)
let map2i_split2 f x y =
  let c = min (Array.length x) (Array.length y) in
  match c with
  | 0 -> [||], [||]
  | _ ->
    let z0 = Owl_utils_stack.make () in
    let z1 = Owl_utils_stack.make () in
    for i = 1 to c - 1 do
      let a, b = f i x.(i) y.(i) in
      Owl_utils_stack.push z0 a;
      Owl_utils_stack.push z1 b
    done;
    Owl_utils_stack.(to_array z0, to_array z1)


let filter2i f x y =
  let x_len = Array.length x in
  let y_len = Array.length y in
  let exn = Owl_exception.DIFFERENT_SIZE (x_len, y_len) in
  Owl_exception.check (x_len = y_len) exn;
  if x_len = 0
  then [||]
  else (
    let r = Owl_utils_stack.make () in
    iter2i (fun i a b -> if f i a b then Owl_utils_stack.push r (a, b)) x y;
    Owl_utils_stack.to_array r)


let filter2 f x y = filter2i (fun _ a b -> f a b) x y

let filter2i_i f x y =
  let len_x = Array.length x in
  let len_y = Array.length y in
  let exn = Owl_exception.DIFFERENT_SIZE (len_x, len_y) in
  Owl_exception.check (len_x = len_y) exn;
  if len_x = 0
  then [||]
  else (
    let r = Owl_utils_stack.make () in
    iter2i (fun i a b -> if f i a b then Owl_utils_stack.push r i) x y;
    Owl_utils_stack.to_array r)


let filter2_i f x y = filter2i_i (fun _ a b -> f a b) x y

let filter2_split f x y =
  let z = filter2 f x y in
  Array.(map fst z, map snd z)


let resize ?(head = true) v n x =
  let m = Array.length x in
  if n < m
  then Array.(sub x 0 n |> copy)
  else if n > m
  then (
    let y = Array.make n v in
    if head = true then Array.blit x 0 y 0 m else Array.blit x 0 y (n - m) m;
    y)
  else Array.copy x


let map3i f x y z =
  let nx = Array.length x in
  let ny = Array.length y in
  let nz = Array.length z in
  assert (nx = ny && ny = nz);
  Array.init nx (fun i -> f i x.(i) y.(i) z.(i))


let map3 f x y z = map3i (fun _ a b c -> f a b c) x y z

let map4i f w x y z =
  let nw = Array.length w in
  let nx = Array.length x in
  let ny = Array.length y in
  let nz = Array.length z in
  assert (nw = nx && nx = ny && ny = nz);
  Array.init nx (fun i -> f i w.(i) x.(i) y.(i) z.(i))


let map4 f w x y z = map4i (fun _ a b c d -> f a b c d) w x y z

let fold2 f a x y =
  let acc = ref a in
  iter2 (fun u v -> acc := f !acc u v) x y;
  !acc


(* pad n value of v to the left/right of array x *)
let pad s v n x =
  let l = Array.length x in
  let y = Array.make (l + n) v in
  let _ =
    match s with
    | `Left  -> Array.blit x 0 y n l
    | `Right -> Array.blit x 0 y 0 l
  in
  y


let align s v x y =
  let len_x = Array.length x in
  let len_y = Array.length y in
  if len_x < len_y
  then pad s v (len_y - len_x) x, Array.copy y
  else if len_x > len_y
  then Array.copy x, pad s v (len_x - len_y) y
  else Array.copy x, Array.copy y


let align3 s v x y z =
  let len_x = Array.length x in
  let len_y = Array.length y in
  let len_z = Array.length z in
  let len = max len_x (max len_y len_z) in
  let x = if len_x < len then pad s v (len - len_x) x else Array.copy x in
  let y = if len_y < len then pad s v (len - len_y) y else Array.copy y in
  let z = if len_z < len then pad s v (len - len_z) z else Array.copy z in
  x, y, z


(* [x] is greater or equal than [y] elementwise *)
let greater_eqaul x y =
  let la = Array.length x in
  let lb = Array.length y in
  assert (la = lb);
  let b = ref true in
  (try
     for i = 0 to la - 1 do
       if x.(i) < y.(i) then failwith "found"
     done
   with
  | _ -> b := false);
  !b


(* swap the ith and jth element in an array *)
let swap x i j =
  let a = x.(i) in
  x.(i) <- x.(j);
  x.(j) <- a


(* permute an array x based on the permutation array p, such that y.(i) = x.(p.(i)) *)
let permute p x =
  let n = Array.length x in
  Array.init n (fun i -> x.(p.(i)))


let get_slice slice x =
  assert (Array.length slice = 3);
  let n = Array.length x in
  let start = if slice.(0) < 0 then n + slice.(0) else slice.(0) in
  let stop = if slice.(1) < 0 then n + slice.(1) else slice.(1) in
  let step = slice.(2) in
  assert (abs step <= n && start < n && stop < n);
  let m = abs (stop - start) / abs step in
  let stack = Owl_utils_stack.make () in
  let idx = ref start in
  for _i = 0 to m do
    Owl_utils_stack.push stack x.(!idx);
    idx := !idx + step
  done;
  Owl_utils_stack.to_array stack


let set_slice slice x y =
  assert (Array.length slice = 3);
  let n = Array.length x in
  let start = if slice.(0) < 0 then n + slice.(0) else slice.(0) in
  let stop = if slice.(1) < 0 then n + slice.(1) else slice.(1) in
  let step = slice.(2) in
  assert (abs step <= n && start < n && stop < n);
  let idx = ref start in
  for i = 0 to Array.length y - 1 do
    assert (!idx < n);
    x.(!idx) <- y.(i);
    idx := !idx + step
  done


(* convert a list of tuples into array *)
let of_tuples x =
  let s = Owl_utils_stack.make () in
  Array.iter
    (fun (i, j) ->
      Owl_utils_stack.push s i;
      Owl_utils_stack.push s j)
    x;
  Owl_utils_stack.to_array s


(* given set x and y, return complement of y, i.e. x \ y *)
let complement x y =
  let h = Hashtbl.create 64 in
  Array.iter (fun a -> Hashtbl.add h a a) x;
  Array.iter (fun a -> Hashtbl.remove h a) y;
  let s = Owl_utils_stack.make () in
  Hashtbl.iter (fun a _ -> Owl_utils_stack.push s a) h;
  Owl_utils_stack.to_array s


let balance_last mass x =
  let k = Array.length x - 1 in
  let q = ref mass in
  Array.mapi
    (fun i a ->
      assert (!q >= 0.);
      if i < k
      then (
        q := !q -. a;
        a)
      else !q)
    x


let index_of x a =
  let pos = ref (-1) in
  let r =
    try
      iteri
        (fun i b ->
          if a = b
          then (
            pos := i;
            raise Owl_exception.FOUND))
        x;
      !pos
    with
    | _ -> !pos
  in
  if r < 0 then raise Owl_exception.NOT_FOUND else r


(* Binary search. Adapted from CCArray.bsearch in containers.
 * Bin edges are taken as left-inclusive, right-exclusive *)
let bsearch ~cmp k bin_edges =
  let rec aux i j =
    if i > j
    then j
    else (
      let middle = i + ((j - i) / 2) in
      (* avoid overflow *)
      match cmp k bin_edges.(middle) with
      | 0 -> middle
      | n when n < 0 -> aux i (middle - 1)
      | _ -> aux (middle + 1) j)
  in
  let n = Array.length bin_edges - 1 in
  if n < 0
  then failwith "empty array"
  else (
    match cmp bin_edges.(0) k, cmp bin_edges.(n) k with
    | c, _ when c > 0 -> -1
    | _, c when c <= 0 -> n
    | _ -> aux 0 n)


(* remove the duplicates in the array *)
let unique x =
  let htbl = Hashtbl.create (Array.length x) in
  filter
    (fun a ->
      let not_found = not (Hashtbl.mem htbl a) in
      if not_found then Hashtbl.add htbl a None;
      not_found)
    x


(* merge two arrays, duplicates will be removed *)
let merge x y = Array.append x y |> unique

let reverse x =
  let n = Array.length x - 1 in
  let m = (Array.length x / 2) - 1 in
  for i = 0 to m do
    let t = x.(n - i) in
    x.(n - i) <- x.(i);
    x.(i) <- t
  done


(* sort then fill the holes *)
let sort_fill ?min ?max ?fill x =
  let x = copy x in
  Array.sort Stdlib.compare x;
  let n = Array.length x in
  let min =
    match min with
    | Some a -> a
    | None   -> x.(0)
  in
  let max =
    match max with
    | Some a -> a
    | None   -> x.(n - 1)
  in
  let fill =
    match fill with
    | Some a -> a
    | None   -> 0
  in
  assert (min <= x.(0) && max >= x.(n - 1));
  let y = Array.make (max - min + 1) fill in
  Array.iter (fun i -> y.(i - min) <- i) x;
  y


let argsort ?(cmp = Stdlib.compare) x =
  let cmp_fun a b = cmp (fst a) (fst b) in
  let n = Array.length x in
  let y = Array.init n (fun i -> x.(i), i) in
  Array.sort cmp_fun y;
  Array.map snd y


let min_i ?(cmp = Stdlib.compare) x =
  assert (Array.length x > 0);
  let idx = ref 0 in
  let acc = ref x.(0) in
  Array.iteri
    (fun i a ->
      if cmp a !acc = -1
      then (
        idx := i;
        acc := a))
    x;
  !idx


let max_i ?(cmp = Stdlib.compare) x =
  assert (Array.length x > 0);
  let idx = ref 0 in
  let acc = ref x.(0) in
  Array.iteri
    (fun i a ->
      if cmp a !acc = 1
      then (
        idx := i;
        acc := a))
    x;
  !idx

(* ends here *)
