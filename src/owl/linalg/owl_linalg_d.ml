(*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2022 Liang Wang <liang@ocaml.xyz>
 *)

open Bigarray

type elt = float

type mat = Owl_dense_matrix_d.mat

type complex_mat = Owl_dense_matrix_z.mat

type int32_mat = (int32, int32_elt) Owl_dense_matrix_generic.t

include Owl_linalg_generic

let schur = schur ~otyp:complex64

let ordschur = ordschur ~otyp:complex64

let qz = qz ~otyp:complex64

let ordqz = ordqz ~otyp:complex64

let qzvals = qzvals ~otyp:complex64

let eig = eig ~otyp:complex64

let eigvals = eigvals ~otyp:complex64
