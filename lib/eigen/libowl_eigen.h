/*
 * OWL - an OCaml numerical library for scientific computing
 * Copyright (c) 2016 Liang Wang <liang.wang@cl.cam.ac.uk>
 */

#ifdef __cplusplus
extern "C"
{
#endif


  /**************************** SparseMatrix_D ****************************/

  struct eigen_spmat_d {};

  struct eigen_spmat_d* c_eigen_spmat_d_new(int rows, int cols);
  void c_eigen_spmat_d_delete(struct eigen_spmat_d *m);
  int c_eigen_spmat_d_rows(struct eigen_spmat_d *m);
  int c_eigen_spmat_d_cols(struct eigen_spmat_d *m);
  double c_eigen_spmat_d_get(struct eigen_spmat_d *m, int i, int j);
  void c_eigen_spmat_d_set(struct eigen_spmat_d *m, int i, int j, double x);
  void c_eigen_spmat_d_reset(struct eigen_spmat_d *m);
  int c_eigen_spmat_d_is_compressed(struct eigen_spmat_d *m);
  void c_eigen_spmat_d_compress(struct eigen_spmat_d *m);
  void c_eigen_spmat_d_uncompress(struct eigen_spmat_d *m);
  void c_eigen_spmat_d_reshape(struct eigen_spmat_d *m, int rows, int cols);
  struct eigen_spmat_d* c_eigen_spmat_d_clone(struct eigen_spmat_d *m);
  void c_eigen_spmat_d_print(struct eigen_spmat_d *m);

#ifdef __cplusplus
} // end extern "C"
#endif
