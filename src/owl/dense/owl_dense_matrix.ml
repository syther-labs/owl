(*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2022 Liang Wang <liang@ocaml.xyz>
 *)

(** Matrix: module aliases *)

module Operator = struct
  include Owl_operator.Make_Basic (Owl_dense_matrix_generic)
  include Owl_operator.Make_Extend (Owl_dense_matrix_generic)
  include Owl_operator.Make_Matrix (Owl_dense_matrix_generic)
  include Owl_operator.Make_Linalg (Owl_linalg_generic)
end

module Generic = struct
  include Owl_dense_matrix_generic
  include Operator

  (* inject function aliases *)

  let inv = Owl_linalg_generic.inv

  let mpow = Owl_linalg_generic.mpow
end

module S = struct
  include Owl_dense_matrix_s
  include Operator

  (* inject function aliases *)

  let inv = Owl_linalg_s.inv

  let mpow = Owl_linalg_s.mpow

  let diag ?(k = 0) x = Owl_dense_ndarray_generic.diag ~k x
end

module D = struct
  include Owl_dense_matrix_d
  include Operator

  (* inject function aliases *)

  let inv = Owl_linalg_d.inv

  let mpow = Owl_linalg_d.mpow

  let diag ?(k = 0) x = Owl_dense_ndarray_generic.diag ~k x
end

module C = struct
  include Owl_dense_matrix_c
  include Operator

  (* inject function aliases *)

  let inv = Owl_linalg_c.inv

  let mpow = Owl_linalg_c.mpow
end

module Z = struct
  include Owl_dense_matrix_z
  include Operator

  (* inject function aliases *)

  let inv = Owl_linalg_z.inv

  let mpow = Owl_linalg_z.mpow
end
