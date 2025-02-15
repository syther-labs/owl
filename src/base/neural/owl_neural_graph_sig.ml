(*
 * OWL - OCaml Scientific and Engineering Computing
 * Copyright (c) 2016-2022 Liang Wang <liang@ocaml.xyz>
 *)

module type Sig = sig
  module Neuron : Owl_neural_neuron_sig.Sig

  open Neuron
  open Neuron.Optimise
  open Neuron.Optimise.Algodiff

  (** {5 Type definition} *)

  type node =
    { mutable name : string
    ; mutable prev : node array
    ; mutable next : node array
    ; mutable neuron : neuron
    ; mutable output : t option
    ; mutable network : network
    ; mutable train : bool
    }

  and network =
    { mutable nnid : string
    ; mutable size : int
    ; mutable roots : node array
    ; mutable outputs : node array
    ; mutable topo : node array
    }
  (** Type definition of a node and a neural network. *)

  (** {5 Manipulate networks} *)

  val make_network : ?nnid:string -> int -> node array -> node array -> network
  (** Create an empty neural network. *)

  val make_node
    :  ?name:string
    -> ?train:bool
    -> node array
    -> node array
    -> neuron
    -> t option
    -> network
    -> node
  (** Create a node in a neural network. *)

  val get_roots : network -> node array
  (** Get the roots of the neural network. *)

  val get_outputs : network -> node array
  (** Get the outputs of the neural network. *)

  val get_node : network -> string -> node
  (** Get a node in a network with the given name. *)

  val get_network : ?name:string -> node -> network
  (** Get the neural network of a given node associated with. *)

  val outputs : ?name:string -> node array -> network
  (** Get the neural network associated with the given output nodes. *)

  val get_network_name : network -> string
  (** ``get_network_name n`` returns the name of the network ``n``. *)

  val set_network_name : network -> string -> unit
  (** ``set_network_name n s`` sets the name of the network ``n`` to ``s``. *)

  val collect_output : node array -> t array
  (** Collect the output values of given nodes. *)

  val connect_pair : node -> node -> unit
  (** Connect two nodes in a neural network. *)

  val connect_to_parents : node array -> node -> unit
  (** Connect a node to a list of parents. *)

  val add_node : ?act_typ:Activation.typ -> network -> node array -> node -> node
  (** Add a node to the given network. *)

  val input_shape : network -> int array
  (** Get input shape of a network (without batch dimension), i.e. shape of input neuron. *)

  val input_shapes : network -> int array array
  (** Get input shapes of a network (without batch dimension), i.e. shape of input neurons. *)

  (** {5 Interface to optimisation engine} *)

  val init : network -> unit
  (** Initialise the network. *)

  val reset : network -> unit
  (** Reset the network, i.e. all the parameters in the neurons. *)

  val mktag : int -> network -> unit
  (** Tag the neurons, used by ``Algodiff`` module. *)

  val mkpar : network -> t array array
  (** Collect the parameters of neurons, used by ``Optimise`` module. *)

  val mkpri : network -> t array array
  (** Collect the primal values of neurons, used by ``Optimise`` module. *)

  val mkadj : network -> t array array
  (** Collect the adjacent values of neurons, used by ``Optimise`` module. *)

  val update : network -> t array array -> unit
  (** Update the parameters of neurons, used by ``Optimise`` module. *)

  val run : t -> network -> t
  (** Execute the computations in all the neurons in a network with the given input. *)

  val run_inputs : t array -> network -> t array
  (** Execute the computations in all the neurons in a network with the given inputs. *)

  val forward : network -> t -> t * t array array
  (** Run the forward pass of a network. *)

  val forward_inputs : network -> t array -> t array * t array array
  (** Run the forward pass of a network (multi-input/output version). *)

  val backward : network -> t -> t array array * t array array
  (** Run the backward pass of a network. *)

  val copy : network -> network
  (** Make a deep copy of the given network. *)

  val model : network -> A.arr -> A.arr
  (** Make a deep copy of the given network, excluding the neurons marked with ``training = true``. *)

  val model_inputs : network -> A.arr array -> A.arr array
  (** Make a deep copy of the given network, excluding the neurons marked with ``training = true``. *)

  (** {5 Create Neurons} *)

  val input : ?name:string -> int array -> node
  (**
``input shape`` creates an input node for input data. Note that if your network
has multiple inputs, you should use ``inputs`` instead.

Arguments:
  * ``shape``: shape of input data.
  *)

  val inputs : ?names:string array -> int array array -> node array
  (**
``input shapes`` creates an array of input nodes for input data.

Arguments:
  * ``shapes``: array of shapes of input data.
  *)

  val activation : ?name:string -> Activation.typ -> node -> node
  (**
Applies an activation function to an output.

Arguments:
  * ``activation``: name of activation function to use.
  *)

  val linear
    :  ?name:string
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int
    -> node
    -> node
  (**
``linear ?act_typ units node`` adds the regular densely-connected NN node to
``node``.

Arguments:
  * ``units``: Positive integer, dimensionality of the output space.
  * ``act_typ``: Activation function to use.
  *)

  val linear_nobias
    :  ?name:string
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int
    -> node
    -> node
  (**
Similar to ``linear``, but does not use the bias vector.
  *)

  val embedding
    :  ?name:string
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int
    -> int
    -> node
    -> node
  (** Create a node for embedding neuron. *)

  val recurrent
    :  ?name:string
    -> ?init_typ:Init.typ
    -> act_typ:Activation.typ
    -> int
    -> int
    -> node
    -> node
  (** Create a node for recurrent neuron. *)

  val lstm : ?name:string -> ?init_typ:Init.typ -> int -> node -> node
  (**
``lstm units node`` adds a LSTM node on previous ``node``.

Arguments:
  * ``units``: Positive integer, dimensionality of the output space.
  *)

  val gru : ?name:string -> ?init_typ:Init.typ -> int -> node -> node
  (**
``gru units node`` adds a Gated Recurrent Unit node on previous ``node``.

Arguments:
  * ``units``: Positive integer, dimensionality of the output space.
  *)

  val conv1d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``conv1d kernel stride node`` adds a 1D convolution node (e.g. temporal
convolution) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``h, i, o``. ``h`` specifies the dimension of the 1D convolution window. ``i`` and ``o`` are the dimensionalities of the input and output space.
  * ``stride``: int array of 1 integer.
  *)

  val conv2d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``conv2d kernel stride node`` adds a 2D convolution node (e.g. spatial convolution over images) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``w, h, i, o``. ``w`` and ``h`` specify the width and height of the 2D convolution window. ``i`` and ``o`` are the dimensionality of the input and output space.
  * ``stride``: int array of 2 integers.
  *)

  val conv3d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``conv3d kernel stride node`` adds a 3D convolution node (e.g. spatial
convolution over volumes) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``w, h, d, i, o``. ``w``, ``h``, and ``d`` specify the 3 dimensionality of the 3D convolution window. ``i`` and ``o`` are the dimensionality of the input and output space.
  * ``stride``: int array of 3 integers.
  *)

  val dilated_conv1d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> int array
    -> node
    -> node
  (**
``dilated_conv1d kernel stride rate node`` adds a 1D dilated convolution node (e.g. temporal convolution) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``h, i, o``. ``h`` specifies the dimension of the 1D convolution window. ``i`` and ``o`` are the dimensionalities of the input and output space.
  * ``stride``: int array of 1 integer.
  * ``rate``: int array of 1 integer.
  *)

  val dilated_conv2d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> int array
    -> node
    -> node
  (**
``dilated_conv2d kernel stride rate node`` adds a 2D dilated convolution node (e.g. spatial convolution over images) on previous ``node``.

Arguments:
  * ``kernel`: int array consists of ``w, h, i, o``. ``w`` and ``h`` specify the width and height of the 2D convolution window. ``i`` and ``o`` are the dimensionality of the input and output space.
  * ``stride``: int array of 2 integers.
  * ``rate``: int array of 2 integers.
  *)

  val dilated_conv3d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> int array
    -> node
    -> node
  (**
``dilated_conv3d kernel stride rate node`` adds a 3D dilated convolution node (e.g. spatial convolution over volumes) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``w, h, d, i, o``. ``w``, ``h``, and ``d`` specify the 3 dimensionality of the 3D convolution window. ``i`` and ``o`` are the dimensionality of the input and output space.
  * ``stride``: int array of 3 integers.
  * ``rate``: int array of 3 integers.
  *)

  val transpose_conv1d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``transpose_conv1d kernel stride node`` adds a 1D transpose convolution node (e.g. temporal convolution) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``h, i, o``. ``h`` specifies the dimension of the 1D convolution window. ``i`` and ``o`` are the dimensionalities of the input and output space.
  * ``stride``: int array of 1 integer.
  *)

  val transpose_conv2d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``transpose_conv2d kernel stride node`` adds a 2D transpose convolution node on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``w, h, i, o``. ``w`` and ``h`` specify the width and height of the 2D convolution window. ``i`` and ``o`` are the dimensionality of the input and output space.
  * ``stride``: int array of 2 integers.
  *)

  val transpose_conv3d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``transpose_conv3d kernel stride node`` adds a 3D transpose convolution node (e.g. spatial convolution over volumes) on previous ``node``.

Arguments:
  * ``kernel``: int array consists of ``w, h, d, i, o``. ``w``, ``h``, and ``d`` specify the 3 dimensionality of the 3D convolution window. ``i`` and ``o`` are the dimensionality of the input and output space.
  * ``stride``: int array of 3 integers.
  *)

  val fully_connected
    :  ?name:string
    -> ?init_typ:Init.typ
    -> ?act_typ:Activation.typ
    -> int
    -> node
    -> node
  (**
``fully_connected outputs node`` adds a fully connected node to ``node``.

Arguments:
  * ``outputs``: integer, the number of output units in the node.
  *)

  val max_pool1d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``max_pool1d ~padding ~act_typ pool_size stride node`` adds a max pooling
operation for temporal data to ``node``.

Arguments:
  * ``pool_size``: Array of one integer, size of the max pooling windows.
  * ``stride``: Array of one integer, factor by which to downscale.
  *)

  val max_pool2d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``max_pool2d ~padding ~act_typ pool_size stride node`` adds a max pooling
operation for spatial data to ``node``.

Arguments:
  * ``pool_size``: Array of 2 integers, size of the max pooling windows.
  * ``stride``: Array of 2 integers, factor by which to downscale.
  *)

  val avg_pool1d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``avg_pool1d ~padding ~act_typ pool_size stride node`` adds a average pooling
operation for temporal data to ``node``.

Arguments:
  * ``pool_size``: Array of one integer, size of the max pooling windows.
  * ``stride``: Array of one integer, factor by which to downscale.
  *)

  val avg_pool2d
    :  ?name:string
    -> ?padding:Owl_types.padding
    -> ?act_typ:Activation.typ
    -> int array
    -> int array
    -> node
    -> node
  (**
``avg_pool2d ~padding ~act_typ pool_size stride node`` adds a average pooling operation for spatial data to ``node``.

Arguments:
  * ``pool_size``: Array of 2 integers, size of the max pooling windows.
  * ``stride``: Array of 2 integers, factor by which to downscale.
  *)

  val global_max_pool1d : ?name:string -> ?act_typ:Activation.typ -> node -> node
  (**
``global_max_pool1d`` adds global max pooling operation for temporal data.
  *)

  val global_max_pool2d : ?name:string -> ?act_typ:Activation.typ -> node -> node
  (**
``global_max_poo2d`` global max pooling operation for spatial data.
  *)

  val global_avg_pool1d : ?name:string -> ?act_typ:Activation.typ -> node -> node
  (**
``global_avg_pool1d`` adds global average pooling operation for temporal data.
  *)

  val global_avg_pool2d : ?name:string -> ?act_typ:Activation.typ -> node -> node
  (**
``global_avg_poo2d`` global average pooling operation for spatial data.
  *)

  val upsampling2d : ?name:string -> ?act_typ:Activation.typ -> int array -> node -> node
  (**
``upsampling2d ~act_typ size node`` adds a upsampling operation for spatial data to ``node``.

Arguments:
  * ``size``: array of two integers, namely the upsampling factors for columns and rows.
  *)

  val padding2d
    :  ?name:string
    -> ?act_typ:Activation.typ
    -> int array array
    -> node
    -> node
  (**
``padding2d ~act_typ padding node`` adds rows and columns of zeros at the top, bottom, left and right side of an image tensor.

Arguments:
  * ``padding``: array of 2 arrays of 2 integers, interpreted as  [| [|top_pad; bottom_pad|]; [|left_pad; right_pad|]|].
  *)

  val dropout : ?name:string -> float -> node -> node
  (**
``dropout rate node`` applies Dropout to the input to prevent overfitting.

Arguments:
  * ``rate``: float between 0 and 1. Fraction of the input units to drop.
  *)

  val gaussian_noise : ?name:string -> float -> node -> node
  (**
``gaussian_noise stddev node`` applies additive zero-centered Gaussian noise.

Arguments:
  * ``stddev``: float, standard deviation of the noise distribution.
  *)

  val gaussian_dropout : ?name:string -> float -> node -> node
  (**
``gaussian_dropout rate node`` applies multiplicative 1-centered Gaussian noise.
Only active at training time.

Arguments:
  * ``rates``: float, drop probability
  *)

  val alpha_dropout : ?name:string -> float -> node -> node
  (**
``alpha_dropout rate node`` applies Alpha Dropout to the input ``node``.
Only active at training time.

Arguments:
  * ``rates``: float, drop probability
  *)

  val normalisation
    :  ?name:string
    -> ?axis:int
    -> ?training:bool
    -> ?decay:float
    -> ?mu:A.arr
    -> ?var:A.arr
    -> node
    -> node
  (**
``normalisation axis node`` normalise the activations of the previous node at
each batch.

Arguments:
  * ``axis``:  Integer, the axis that should be normalised (typically the features axis). Default value is 0.
  *)

  val reshape : ?name:string -> int array -> node -> node
  (**
``reshape target_shape node`` reshapes an output to a certain shape.

Arguments:
  * ``target_shape``: target shape. Array of integers. Does not include the batch axis.
  *)

  val flatten : ?name:string -> node -> node
  (**
``flatten node`` flattens the input. Does not affect the batch size.
  *)

  val slice : ?name:string -> int list list -> node -> node
  (**
``slice node`` slices the input. Does not affect the batch size.
  *)

  val lambda
    :  ?name:string
    -> ?act_typ:Activation.typ
    -> ?out_shape:int array
    -> (t -> t)
    -> node
    -> node
  (**
``lambda ?target_shape func node`` wraps arbitrary expression as a Node object.

Arguments:
  * ``func``: The function to be evaluated. Takes input tensor as first argument.
  * ``target_shape``: the shape of the tensor returned by ``func``; set to the same as input shape if not specified.
  *)

  val lambda_array
    :  ?name:string
    -> ?act_typ:Activation.typ
    -> int array
    -> (t array -> t)
    -> node array
    -> node
  (**
``lambda_array target_shape func node`` wraps arbitrary expression as a Node object.

Arguments:
  * ``target_shape``: the shape of the tensor returned by ``func``.
  * ``func``: The function to be evaluated. Takes input tensor array as first argument.
  *)

  val add : ?name:string -> ?act_typ:Activation.typ -> node array -> node
  (**
Node that adds a list of inputs.

It takes as input an array of nodes, all of the same shape, and returns a
single node (also of the same shape).
  *)

  val mul : ?name:string -> ?act_typ:Activation.typ -> node array -> node
  (**
Node that multiplies (element-wise) a list of inputs.

It takes as input an array of nodes, all of the same shape, and returns a
single node (also of the same shape).
  *)

  val dot : ?name:string -> ?act_typ:Activation.typ -> node array -> node
  (**
  Node that computes a dot product between samples in two nodes.
  *)

  val max : ?name:string -> ?act_typ:Activation.typ -> node array -> node
  (**
Node that computes the maximum (element-wise) a list of inputs.
  *)

  val average : ?name:string -> ?act_typ:Activation.typ -> node array -> node
  (**
Node that averages a list of inputs.

It takes as input an array of nodes, all of the same shape, and returns a
single node (also of the same shape).
  *)

  val concatenate : ?name:string -> ?act_typ:Activation.typ -> int -> node array -> node
  (**
``concatenate axis nodes`` concatenates a array of ``nodes`` and return as a single node.

Arguments:
  * ``axis``: Axis along which to concatenate.
  *)

  (** {5 Helper functions} *)

  val to_string : network -> string
  (** Convert a neural network to its string representation. *)

  val pp_network : Format.formatter -> network -> unit
    [@@ocaml.toplevel_printer]
  (** Pretty printing function a neural network. *)

  val print : network -> unit
  (** Print the string representation of a neural network to the standard output. *)

  val save : ?unsafe:bool -> network -> string -> unit
  (** Serialise a network and save it to the a file with the given name.
  Set the unsafe flag to true if network contains Lambda layer. *)

  val load : string -> network
  (** Load the neural network from a file with the given name. *)

  val save_weights : network -> string -> unit
  (**
Save all the weights in a neural network to a file. The weights and the name of
their associated neurons are saved as key-value pairs in a hash table.
  *)

  val load_weights : network -> string -> unit
  (**
Load the weights from a file of the given name. Note that the weights and the
name of their associated neurons are saved as key-value pairs in a hash table.
  *)

  val make_subnetwork
    :  ?copy:bool
    -> ?make_inputs:string array
    -> network
    -> string array
    -> network
  (**
   ``get_subnetwork ?copy ?make_inputs network output_names`` constructs a
   subnetwork of nodes on which ``output_names`` depend, replacing nodes with
   names in ``make_inputs`` with input nodes.

   Arguments:
     ``copy``: Whether to copy or reference the original node weights. Defaults to true.
     ``make_inputs``: Names of nodes to use as inputs to the subnetwork. Defaults to [||], which uses the original inputs.
     ``nn``: The neural network from which the subnetwork is constructed.
     ``output_names``: Names of nodes to use as outputs.
   *)

  (** {5 Train Networks} *)

  val train_generic
    :  ?state:Checkpoint.state
    -> ?params:Params.typ
    -> ?init_model:bool
    -> network
    -> t
    -> t
    -> Checkpoint.state
  (** Generic function of training a neural network. *)

  val train
    :  ?state:Checkpoint.state
    -> ?params:Params.typ
    -> ?init_model:bool
    -> network
    -> A.arr
    -> A.arr
    -> Checkpoint.state
  (** Train a neural network with various configurations. *)
end
