open Batteries
open Printf

let pattern n pos v =
  match ((pos+1) / n) mod 4 with
  | 1 -> v
  | 3 -> -v
  | _ -> 0

let rec apply_n n f x =
  match n with
  | 0 -> x
  | _ -> apply_n (n-1) f (f x)

let fft_step (input : int array) =
  for pos = 0 to (Array.length input) - 1 do
    let sum = ref 0 in
    for pos' = pos to (Array.length input) - 1 do
      sum := !sum + (pattern (pos+1) pos' (Array.get input pos'));
    done;
    Array.set input pos (abs !sum mod 10)
  done;
  input

let part1 (input : int list) : unit =
  printf "Part1: ";
  let in_array = Array.of_list input in
  ignore(apply_n 100 fft_step in_array);
  List.init 8 (Array.get in_array) |> List.iter (printf "%d");
  printf "\n"

let part2 input =
  printf "Part2: ";
  let offset = int_of_string (List.fold_left (^) "" (List.map (string_of_int) (List.take 7 input))) in
  let in_len = List.length input in
  (* offset must be after the middle of the sequence, if this approach should work *)
  assert ((2*offset) >= in_len);
  let in_array = input
                 |> List.make (10000 - (offset / in_len))
                 |> List.concat
                 |> List.drop (offset mod in_len)
                 |> Array.of_list in
  for _ = 1 to 100 do
    ignore(Array.fold_righti (fun i v sum -> let res = (sum+v) mod 10 in Array.set in_array i res; res) in_array 0)
  done;
  List.init 8 (Array.get in_array) |> List.iter (printf "%d");
  printf "\n"

let () =
  let input_list = File.lines_of "input"
                   |> Enum.peek |> Option.get
                   |> String.to_list
                   |> List.map (fun ch -> int_of_char ch - int_of_char '0') in
  part1 input_list;
  part2 input_list
