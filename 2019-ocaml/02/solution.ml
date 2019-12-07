open Batteries
open Printf

let apply_op input op a b res =
  let get = Array.get input in
  Array.set input (get res) (op (get (get a)) (get (get b)))

let rec run (pos : int) (input : int array) : int array =
  (match Array.get input pos with
   | 1 -> apply_op input ( + ) (pos+1) (pos+2) (pos+3); run (pos+4) input
   | 2 -> apply_op input ( * ) (pos+1) (pos+2) (pos+3); run (pos+4) input
   | _  -> input)

let set_inputs input a b  = Array.set input 1 a; Array.set input 2 b; input

let combinations starting ending =
  let possibilities = List.of_enum (starting--ending) in
  List.map (fun pos1 -> List.map (fun pos2 -> (pos1, pos2)) possibilities) possibilities
  |> List.concat

let find_inputs (output : int) (input : int array)  : int * int =
  combinations 0 100
  |> List.map (fun (a,b) -> (a, b, Array.get (run 0 (set_inputs (Array.copy input) a b)) 0))
  |> List.find (fun (a, b, res) -> res == output)
  |> fun (a, b, res) -> (a,b)

let solve (input : string) : unit =
  input
  |> String.split_on_char ','
  |> List.map (int_of_string)
  |> Array.of_list
  |> find_inputs 19690720
  |> (fun (a,b) -> printf "%d\n" (100*a + b))

let () = File.lines_of "input" |> Enum.peek |> Option.get |> solve
