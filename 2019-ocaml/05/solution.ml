open Batteries
open Printf

let apply_mode input x mode =
  match mode with
  | '0' -> Array.get input x
  | _   -> x

let apply_op input op a b res modea modeb =
  let get = Array.get input in
  Array.set input (get res) (op (apply_mode input (get a) modea) (apply_mode input (get b) modeb))

let parse_opcode oc =
  let str = string_of_int oc in
  let str_c = String.concat "" [String.make (5 - String.length str) '0'; str] in
  (int_of_string (String.sub str_c 3 2), str_c.[0], str_c.[1], str_c.[2])

let rec run (pos : int) (input : int array) : int array =
  let opcode = parse_opcode (Array.get input pos) in
  (match opcode with
   | (1, _, modeb, modea) -> apply_op input ( + ) (pos+1) (pos+2) (pos+3) modea modeb; run (pos+4) input
   | (2, _, modeb, modea) -> apply_op input ( * ) (pos+1) (pos+2) (pos+3) modea modeb; run (pos+4) input
   | (3, _, _, _) -> Array.set input (Array.get input (pos+1)) (int_of_string (read_line ())); run (pos+2) input
   | (4, _, _, _) -> printf "%d\n" (Array.get input (Array.get input (pos+1))); run (pos+2) input
   | (5, _, modeb, modea) ->
      if apply_mode input (Array.get input (pos+1)) modea != 0
      then run (apply_mode input (Array.get input (pos+2)) modeb) input
      else run (pos+3) input
   | (6, _, modeb, modea) ->
      if apply_mode input (Array.get input (pos+1)) modea == 0
      then run (apply_mode input (Array.get input (pos+2)) modeb) input
      else run (pos+3) input
   | (7, _, modeb, modea) -> apply_op input ( fun x y -> if x < y then 1 else 0 ) (pos+1) (pos+2) (pos+3) modea modeb; run (pos+4) input
   | (8, _, modeb, modea) -> apply_op input ( fun x y -> if x == y then 1 else 0 ) (pos+1) (pos+2) (pos+3) modea modeb; run (pos+4) input
   | (99, _, _, _) -> input
   | _  -> printf "invalid instruction %d\n" (Array.get input pos); input)

let set_inputs input a b  = Array.set input 1 a; Array.set input 2 b; input

let solve (input : string) : unit =
  input
  |> String.split_on_char ','
  |> List.map (int_of_string)
  |> Array.of_list
  |> run 0
  |> fun a -> Array.get a 0
  |> printf "\n Result: %d\n"

let () = File.lines_of "input" |> Enum.peek |> Option.get |> solve
