open Batteries
open Printf

let rec minimum (lst : int list) : int =
  match lst with
  | [] -> 0
  | x :: xs -> List.fold_left min x xs

let rec wire_to_coords x y steps wire =
  match wire with
  | [] -> []
  | (d, n) :: tl ->
     match d with
     | 'U' -> (List.init n (fun diff -> ((x, y+diff), steps+diff))) @ (wire_to_coords x (y+n) (steps+n) tl)
     | 'D' -> (List.init n (fun diff -> ((x, y-diff), steps+diff))) @ (wire_to_coords x (y-n) (steps+n) tl)
     | 'R' -> (List.init n (fun diff -> ((x+diff, y), steps+diff))) @ (wire_to_coords (x+n) y (steps+n) tl)
     | 'L' -> (List.init n (fun diff -> ((x-diff, y), steps+diff))) @ (wire_to_coords (x-n) y (steps+n) tl)
     | _   -> []

let parse_wire (input : string) : (char * int) list =
  String.split_on_char ',' input
  |> List.map (fun item -> (item.[0], int_of_string (String.sub item 1 (String.length item - 1))))

let rec merge_sorted_wires w1 w2 =
  match w1, w2 with
  | _, [] -> []
  | [], _ -> []
  | (pos1, steps1) :: w1, (pos2, steps2) :: w2 ->
     match compare pos1 pos2 with
     | 0 -> (pos1, steps1 + steps2) :: merge_sorted_wires w1 w2
     | n when n < 0 -> merge_sorted_wires w1 ((pos2, steps2) :: w2)
     | _            -> merge_sorted_wires ((pos1, steps1) :: w1) w2

let line_to_sorted_wire (line : string) : ((int*int)*int) list =
  parse_wire line
  |> wire_to_coords 0 0 0
  |> List.tl
  |> List.stable_sort (fun (pos1, _) (pos2, _) -> compare pos1 pos2)

let solve (l1 : string) (l2 : string) : unit =
  let (w1, w2) = (line_to_sorted_wire l1, line_to_sorted_wire l2) in
  merge_sorted_wires w1 w2 |> List.map snd |> minimum |> printf "%d\n"

let () = let lines = File.lines_of "input" in
         let l1 = Enum.get lines |> Option.get in
         let l2 = Enum.get lines |> Option.get in
         solve l1 l2
