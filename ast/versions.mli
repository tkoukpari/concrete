(**************************************************************************)
(*                                                                        *)
(*                         OCaml Migrate Parsetree                        *)
(*                                                                        *)
(*                             Frédéric Bour                              *)
(*                   Jérémie Dimino, Jane Street Europe                   *)
(*                                                                        *)
(*   Copyright 2017 Institut National de Recherche en Informatique et     *)
(*     en Automatique (INRIA).                                            *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(*$ open Ast_cinaps_helpers $*)

(** {1 Abstracting an OCaml frontend} *)

(** Abstract view of a version of an OCaml Ast *)
module type Ast = sig
  (*$ foreach_module (fun m types ->
      printf "  module %s : sig\n" m;
      List.iter types ~f:(printf "    type %s\n");
      printf "  end\n"
    )
  *)
  module Parsetree : sig
    type structure
    type signature
    type toplevel_phrase
    type core_type
    type expression
    type pattern
    type case
    type type_declaration
    type type_extension
    type extension_constructor
    type class_expr
    type class_field
    type class_type
    type class_signature
    type class_type_field
    type module_expr
    type module_type
    type signature_item
    type structure_item
  end
(*$*)
  module Config : sig
    val ast_impl_magic_number : string
    val ast_intf_magic_number : string
  end
end

(* Shortcuts for talking about ast types outside of the module language *)

type 'a _types = 'a constraint 'a
  = <
    (*$ foreach_type (fun _ s -> printf "    %-21s : _;\n" s) *)
    structure             : _;
    signature             : _;
    toplevel_phrase       : _;
    core_type             : _;
    expression            : _;
    pattern               : _;
    case                  : _;
    type_declaration      : _;
    type_extension        : _;
    extension_constructor : _;
    class_expr            : _;
    class_field           : _;
    class_type            : _;
    class_signature       : _;
    class_type_field      : _;
    module_expr           : _;
    module_type           : _;
    signature_item        : _;
    structure_item        : _;
(*$*)
  >
;;

(** A version of the OCaml frontend packs the ast with type witnesses
    so that equalities can be recovered dynamically. *)
type _ witnesses (*IF_AT_LEAST 406 = private ..*)

(** [migration_info] is an opaque type that is used to generate migration
    functions. *)
type _ migration_info

(** An OCaml frontend versions an Ast, version number and some witnesses for
    conversion. *)
module type OCaml_version = sig

  (** Ast definition for this version *)
  module Ast : Ast

  (* Version number as an integer, 402, 403, 404, ... *)
  val version : int

  (* Version number as a user-friendly string *)
  val string_version : string (* 4.02, 4.03, 4.04, ... *)

  (** Shortcut for talking about Ast types *)
  type types = <
    (*$ foreach_type (fun m s -> printf "    %-21s : Ast.%s.%s;\n" s m s) *)
    structure             : Ast.Parsetree.structure;
    signature             : Ast.Parsetree.signature;
    toplevel_phrase       : Ast.Parsetree.toplevel_phrase;
    core_type             : Ast.Parsetree.core_type;
    expression            : Ast.Parsetree.expression;
    pattern               : Ast.Parsetree.pattern;
    case                  : Ast.Parsetree.case;
    type_declaration      : Ast.Parsetree.type_declaration;
    type_extension        : Ast.Parsetree.type_extension;
    extension_constructor : Ast.Parsetree.extension_constructor;
    class_expr            : Ast.Parsetree.class_expr;
    class_field           : Ast.Parsetree.class_field;
    class_type            : Ast.Parsetree.class_type;
    class_signature       : Ast.Parsetree.class_signature;
    class_type_field      : Ast.Parsetree.class_type_field;
    module_expr           : Ast.Parsetree.module_expr;
    module_type           : Ast.Parsetree.module_type;
    signature_item        : Ast.Parsetree.signature_item;
    structure_item        : Ast.Parsetree.structure_item;
(*$*)
  > _types

  (** A construtor for recovering type equalities between two arbitrary
      versions. *)
  type _ witnesses += Version : types witnesses

  (** Information used to derive migration functions, see below *)
  val migration_info : types migration_info
end

(** {1 Concrete frontend instances} *)

(*$foreach_version (fun n _ ->
    printf "module OCaml_%d : OCaml_version with module Ast = Astlib.Ast_%d\n"
      n n
  )*)
module OCaml_408 : OCaml_version with module Ast = Astlib.Ast_408
module OCaml_409 : OCaml_version with module Ast = Astlib.Ast_409
module OCaml_410 : OCaml_version with module Ast = Astlib.Ast_410
module OCaml_411 : OCaml_version with module Ast = Astlib.Ast_411
module OCaml_412 : OCaml_version with module Ast = Astlib.Ast_412
module OCaml_413 : OCaml_version with module Ast = Astlib.Ast_413
module OCaml_414 : OCaml_version with module Ast = Astlib.Ast_414
module OCaml_500 : OCaml_version with module Ast = Astlib.Ast_500
module OCaml_501 : OCaml_version with module Ast = Astlib.Ast_501
module OCaml_502 : OCaml_version with module Ast = Astlib.Ast_502
module OCaml_503 : OCaml_version with module Ast = Astlib.Ast_503
module OCaml_504 : OCaml_version with module Ast = Astlib.Ast_504
(*$*)

(* An alias to the current compiler version *)
module OCaml_current = OCaml_OCAML_VERSION

(* The list of all supported versions *)
val all_versions : (module OCaml_version) list

(** {1 Convenience definitions} *)

(** Module level migration *)
module Convert (A : OCaml_version) (B : OCaml_version) : sig
  (*$ foreach_type (fun m s ->
      let fq = sprintf "%s.%s" m s in
      printf "  val copy_%-21s : A.Ast.%-31s -> B.Ast.%s\n" s fq fq) *)
  val copy_structure             : A.Ast.Parsetree.structure             -> B.Ast.Parsetree.structure
  val copy_signature             : A.Ast.Parsetree.signature             -> B.Ast.Parsetree.signature
  val copy_toplevel_phrase       : A.Ast.Parsetree.toplevel_phrase       -> B.Ast.Parsetree.toplevel_phrase
  val copy_core_type             : A.Ast.Parsetree.core_type             -> B.Ast.Parsetree.core_type
  val copy_expression            : A.Ast.Parsetree.expression            -> B.Ast.Parsetree.expression
  val copy_pattern               : A.Ast.Parsetree.pattern               -> B.Ast.Parsetree.pattern
  val copy_case                  : A.Ast.Parsetree.case                  -> B.Ast.Parsetree.case
  val copy_type_declaration      : A.Ast.Parsetree.type_declaration      -> B.Ast.Parsetree.type_declaration
  val copy_type_extension        : A.Ast.Parsetree.type_extension        -> B.Ast.Parsetree.type_extension
  val copy_extension_constructor : A.Ast.Parsetree.extension_constructor -> B.Ast.Parsetree.extension_constructor
  val copy_class_expr            : A.Ast.Parsetree.class_expr            -> B.Ast.Parsetree.class_expr
  val copy_class_field           : A.Ast.Parsetree.class_field           -> B.Ast.Parsetree.class_field
  val copy_class_type            : A.Ast.Parsetree.class_type            -> B.Ast.Parsetree.class_type
  val copy_class_signature       : A.Ast.Parsetree.class_signature       -> B.Ast.Parsetree.class_signature
  val copy_class_type_field      : A.Ast.Parsetree.class_type_field      -> B.Ast.Parsetree.class_type_field
  val copy_module_expr           : A.Ast.Parsetree.module_expr           -> B.Ast.Parsetree.module_expr
  val copy_module_type           : A.Ast.Parsetree.module_type           -> B.Ast.Parsetree.module_type
  val copy_signature_item        : A.Ast.Parsetree.signature_item        -> B.Ast.Parsetree.signature_item
  val copy_structure_item        : A.Ast.Parsetree.structure_item        -> B.Ast.Parsetree.structure_item
(*$*)
end

(** Helper to find the frontend corresponding to a given magic number *)
module Find_version : sig
  type t = Impl of (module OCaml_version) | Intf of (module OCaml_version) | Unknown

  val from_magic : string -> t
end
