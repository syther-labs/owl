/*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2022 Liang Wang <liang@ocaml.xyz>
 */

#ifndef OWL_SLICING_H
#define OWL_SLICING_H


/* Define structure for copying a basic slice from x to y. */

struct slice_pair {
  int64_t dim;          // number of dimensions, x and y must be the same
  int64_t dep;          // the depth of current recursion.
  intnat *n;            // number of iteration in each dimension, i.e. y's shape
  void *x;              // x, source if operation is get, destination if set.
  int64_t posx;         // current offset of x.
  int64_t *ofsx;        // offset of x in each dimension.
  int64_t *incx;        // stride size of x in each dimension.
  void *y;              // y, destination if operation is get, source if set.
  int64_t posy;         // current offset of y.
  int64_t *ofsy;        // offset of y in each dimension.
  int64_t *incy;        // stride size of y in each dimension.
};


/**
 * Define structure for copying a fancy slice from x to y.
 * slice field contains a list of triplet with the format of (a,b,c). If a is
 * non-negative, then (a,b,c) is a normal slice definition, i.e., the same as
 * (start, stop, step).
 *
 * Otherwise, it indicates this dimension in the slice definition is defined by
 * a list of indices, I set this value to (-1) because OCaml code will first
 * re-format the slice definition to make sure both start and stop are greater
 * than zero. In case of a list of indices, the latter two elements b and c is
 * used to specify the starting and ending point of the list and in the index
 * field, inclusive. All the list will be flattened and saved in index before
 * calling any fancy slicing functions.
 *
 * As a result, the fields in ofsx and incx are only meaningful for the
 * dimension defined using normal slice definition.
**/

struct fancy_pair {
  int64_t dim;          // number of dimensions, x and y must be the same
  int64_t dep;          // the depth of current recursion.
  intnat *n;            // number of iteration in each dimension, i.e. y's shape
  int64_t *slice;       // (a,b,c) triplet, if a >= 0 then normal slice.
  int64_t *index;       // combined use with slice, check the details above.
  void *x;              // x, source if operation is get, destination if set.
  int64_t posx;         // current offset of x.
  int64_t *ofsx;        // offset of x in each dimension.
  int64_t *incx;        // stride size of x in each dimension.
  void *y;              // y, destination if operation is get, source if set.
  int64_t posy;         // current offset of y.
  int64_t *ofsy;        // offset of y in each dimension.
  int64_t *incy;        // stride size of y in each dimension.
};


#endif  /* OWL_SLICING_H */
