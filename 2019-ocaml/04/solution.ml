open Batteries
open Printf

let rec split_conseq (l : int list) : (int list) list =
  match l with
  | [] -> []
  | x :: xs ->
     let res = split_conseq xs in
     match res with
     | [] -> [[x]]
     | (rs :: ress) -> if x + 1 == List.hd rs then (x :: rs) :: ress else [x] :: (rs :: ress)

let is_correct num =
  let str = string_of_int num in
  let pos = List.of_enum (0--(String.length str-2)) in
  let pos_w_neighbor = List.filter (fun i -> str.[i] == str.[i+1]) pos in
  List.exists (fun g -> List.length g == 1) (split_conseq pos_w_neighbor) &&
    List.for_all (fun i -> int_of_char str.[i] <= int_of_char str.[i+1]) pos

let () =
  let range = List.of_enum (271973--785961) in
  range |> List.filter is_correct |> List.length |> printf "%d\n"
