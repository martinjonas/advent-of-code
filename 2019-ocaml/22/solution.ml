open Batteries
open Printf
open Big_int

(* the following two functions are modified versions of
   https://rosettacode.org/wiki/Modular_inverse#Translation_of:_Haskell *)

let rec gcd_ext a = function
  | 0 -> (1, 0, a)
  | b ->
      let s, t, g = gcd_ext b (a mod b) in
      (t, Int.sub s (Int.mul (Int.div a b) t), g)

let mod_inv a m =
  let mk_pos x = if x < 0 then Int.add x m else x in
  match gcd_ext a m with
  | i, _, 1 -> mk_pos i
  | _ -> failwith "mod_inv"

(* the code below is completely mine *)

let big = Big_int.big_int_of_int

type permutation = { shift : Big_int.big_int;
                     stretch : Big_int.big_int;
                     size : Big_int.big_int }

let apply_shuffle_item { shift; stretch; size } command =
  match command with
  | ["cut"; n] -> { shift = Big_int.modulo (shift - big (int_of_string n) + size) size;
                    stretch = stretch;
                    size }
  | ["deal"; "into"; "new"; "stack"] -> { shift = size - shift - big 1;
                                          stretch = size - stretch;
                                          size }
  | ["deal"; "with"; "increment"; n] -> { shift = Big_int.modulo (shift * big (int_of_string n)) size;
                                          stretch = Big_int.modulo (stretch * big (int_of_string n)) size;
                                          size }
  | _ -> failwith "Unknown shuffle command."

let rec permutation_of_commands size = List.fold_left apply_shuffle_item { shift = big 0; stretch = big 1; size }

let pos_from_permutation { shift; stretch; size } x = Big_int.modulo (shift + stretch*x) size

(* (\x -> shift1 + stretch1*x) . (\x -> shift2 + stretch2*x)
   = \x -> shift1 + stretch1*(shift2 + stretch2*x)
   = \x -> (shift1 + stretch1*shift2) + (stretch1*stretch2)*x *)
let compose_permutations perm1 perm2 =
  assert (perm1.size == perm2.size);
  let size = perm1.size in
  { shift = Big_int.modulo (perm1.shift + perm1.stretch*perm2.shift) size;
    stretch = Big_int.modulo (perm1.stretch * perm2.stretch) size;
    size }

let rec repeat_permutation perm n =
  match n with
  | 0 -> { shift = big 0; stretch = big 1; size = perm.size }
  | n when n mod 2 == 0 -> let halfPerm = repeat_permutation perm (Int.div n 2) in
                           compose_permutations halfPerm halfPerm
  | _ -> let halfPerm = repeat_permutation perm (Int.div n 2) in
         let minusOnePerm = compose_permutations halfPerm halfPerm in
         compose_permutations minusOnePerm perm

let find_in_permutation { shift; stretch; size } pos =
  (* Solve: pos ≡ shift + stretch*x (mod size) *)
  (* i.e., compute (pos - shift)*(stretch^-1) (mod size) *)
  Big_int.modulo ((pos - shift) * big (mod_inv (Big_int.to_int stretch) (Big_int.to_int size))) size

let solve input =
  let commands = List.map (String.split_on_char ' ') input in
  let part1_perm = permutation_of_commands (big 10007) commands in
  printf "Part1: %d\n" (Big_int.to_int (pos_from_permutation part1_perm (big 2019)));

  let single_perm = permutation_of_commands (big 119315717514047) commands in
  let n_perms = repeat_permutation single_perm 101741582076661 in
  let result = (find_in_permutation n_perms (big 2020)) in
  printf "Part2: The position 2020 contains the number %d\n" (Big_int.to_int result);
  printf "Check: The number is on the position %d\n" (Big_int.to_int (pos_from_permutation n_perms result))

let () = File.lines_of "input" |> List.of_enum |> solve
