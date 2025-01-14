(*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2022 Liang Wang <liang@ocaml.xyz>
 *)

(** Operator definition such as add, sub, mul, and div. *)

open Owl_types_operator

(* define basic operators *)

module Make_Basic (M : BasicSig) = struct
  type ('a, 'b) op_t0 = ('a, 'b) M.t

  let ( + ) = M.add

  let ( - ) = M.sub

  let ( * ) = M.mul

  let ( / ) = M.div

  let ( +$ ) = M.add_scalar

  let ( -$ ) = M.sub_scalar

  let ( *$ ) = M.mul_scalar

  let ( /$ ) = M.div_scalar

  let ( $+ ) = M.scalar_add

  let ( $- ) = M.scalar_sub

  let ( $* ) = M.scalar_mul

  let ( $/ ) = M.scalar_div

  let ( = ) = M.equal

  let ( != ) = M.not_equal

  let ( <> ) = M.not_equal

  let ( > ) = M.greater

  let ( < ) = M.less

  let ( >= ) = M.greater_equal

  let ( <= ) = M.less_equal
end [@warning "-34"]

module Make_Extend (M : ExtendSig) = struct
  type ('a, 'b) op_t1 = ('a, 'b) M.t

  let ( =$ ) = M.equal_scalar

  let ( !=$ ) = M.not_equal_scalar

  let ( <>$ ) = M.not_equal_scalar

  let ( <$ ) = M.less_scalar

  let ( >$ ) = M.greater_scalar

  let ( <=$ ) = M.less_equal_scalar

  let ( >=$ ) = M.greater_equal_scalar

  let ( =. ) = M.elt_equal

  let ( !=. ) = M.elt_not_equal

  let ( <>. ) = M.elt_not_equal

  let ( <. ) = M.elt_less

  let ( >. ) = M.elt_greater

  let ( <=. ) = M.elt_less_equal

  let ( >=. ) = M.elt_greater_equal

  let ( =.$ ) = M.elt_equal_scalar

  let ( !=.$ ) = M.elt_not_equal_scalar

  let ( <>.$ ) = M.elt_not_equal_scalar

  let ( <.$ ) = M.elt_less_scalar

  let ( >.$ ) = M.elt_greater_scalar

  let ( <=.$ ) = M.elt_less_equal_scalar

  let ( >=.$ ) = M.elt_greater_equal_scalar

  let ( =~ ) = M.approx_equal

  let ( =~$ ) = M.approx_equal_scalar

  let ( =~. ) = M.approx_elt_equal

  let ( =~.$ ) = M.approx_elt_equal_scalar

  let ( % ) = M.fmod

  let ( %$ ) = M.fmod_scalar

  let ( ** ) = M.pow

  let ( $** ) = M.scalar_pow

  let ( **$ ) = M.pow_scalar

  let ( += ) x y = M.add_ ~out:x x y

  let ( -= ) x y = M.sub_ ~out:x x y

  let ( *= ) x y = M.mul_ ~out:x x y

  let ( /= ) x y = M.div_ ~out:x x y

  let ( +$= ) x a = M.add_scalar_ ~out:x x a

  let ( -$= ) x a = M.sub_scalar_ ~out:x x a

  let ( *$= ) x a = M.mul_scalar_ ~out:x x a

  let ( /$= ) x a = M.div_scalar_ ~out:x x a

  let ( @= ) = M.concat_vertical

  let ( @|| ) = M.concat_horizontal

  let ( .!{;..} ) x s = M.get_fancy_ext s x

  let ( .!{;..}<- ) x s = M.set_fancy_ext s x

  let ( .${} ) x s = M.get_slice_ext [| s |] x

  let ( .${;..} ) x s = M.get_slice_ext s x

  let ( .${}<- ) x s = M.set_slice_ext [| s |] x

  let ( .${;..}<- ) x s = M.set_slice_ext s x
end [@warning "-34"]

module Make_Matrix (M : MatrixSig) = struct
  type ('a, 'b) op_t2 = ('a, 'b) M.t

  let ( .%{} ) x (i1, i2) = M.get x i1 i2

  let ( .%{;..} ) x i =
    if Array.length i = 2
    then M.get x i.(0) i.(1)
    else
      failwith
        (".%{} on matrices requires exactly two indices but I got "
        ^ string_of_int
        @@ Array.length i)


  let ( .%{}<- ) x (i1, i2) = M.set x i1 i2

  let ( .%{;..}<- ) x i =
    if Array.length i = 2
    then M.set x i.(0) i.(1)
    else
      failwith
        (".%{}<- on matrices requires exactly two indices but I got "
        ^ string_of_int
        @@ Array.length i)


  let ( *@ ) a b = M.dot a b
end [@warning "-34"]

module Make_Ndarray (M : NdarraySig) = struct
  type ('a, 'b) op_t3 = ('a, 'b) M.t

  let ( .%{} ) x i = M.get x [| i |]

  let ( .%{;..} ) x i = M.get x i

  let ( .%{}<- ) x i = M.set x [| i |]

  let ( .%{;..}<- ) x i = M.set x i
end [@warning "-34"]

module Make_Linalg (M : LinalgSig) = struct
  type ('a, 'b) op_t4 = ('a, 'b) M.t

  let ( **@ ) x a = M.mpow x a

  let ( /@ ) a b = M.linsolve a b
end [@warning "-34"]

(* ends here *)
