open Batteries
open Printf

let stack_two_layers = List.map2 (fun i1 i2 -> if i1 == 2 then i2 else i1)

let rec split_each (n : int) (input : 'a list) :  'a list list =
  match List.split_at n input with
  | (l, []) -> [l]
  | (l, r) -> l :: split_each n r

let count_members x list = List.length (List.filter ((==) x) list)

let part1 layers =
  let sorted = List.sort (fun l1 l2 -> compare (count_members 0 l1) (count_members 0 l2)) layers in
  let first_layer = List.hd sorted in
  (count_members 1 first_layer) * (count_members 2 first_layer)

let solve (input : string) : unit =
  input
  |> String.to_list
  |> List.map (fun ch -> int_of_char ch - int_of_char '0')
  |> split_each 150
  |> List.reduce stack_two_layers
  |> split_each 25
  |> List.iter (fun line -> List.iter (fun n -> printf (if n == 1 then "X" else " ")) line; printf "\n")

let () = File.lines_of "input" |> Enum.peek |> Option.get |> solve
