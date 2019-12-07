open Batteries
open Printf

class intcode_interpreter (init_memory : int array) (init_inputs : int list) =
object (self)
  val mutable memory = Array.copy init_memory
  val mutable inputs = init_inputs
  val mutable pc = 0

  method private parse_opcode oc =
    let str = string_of_int oc in
    let str_c = String.concat "" [String.make (5 - String.length str) '0'; str] in
    (int_of_string (String.sub str_c 3 2), str_c.[1], str_c.[2])

  method private read_mem = Array.get memory
  method private write_mem = Array.set memory

  method private read_with_mode pos mode =
    match mode with
    | '0' -> self#read_mem (self#read_mem pos) (* memory[pos] contains a pointer *)
    | _   -> self#read_mem pos                 (* memory[pos] contains a value *)

  method private apply_binop op modea modeb =
    self#write_mem
      (self#read_mem (pc+3)) (* memory location *)
      (op (self#read_with_mode (pc+1) modea) (self#read_with_mode (pc+2) modeb)) (* value *);
    pc <- pc+4;

  method private cond_jump cond modea modeb =
    if cond (self#read_with_mode (pc+1) modea)
    then pc <- self#read_with_mode (pc+2) modeb
    else pc <- pc+3

  method is_done = pc == -1

  method add_input (input : int) = inputs <- inputs @ [input]

  method get_output =
    let rec step () =
      match self#parse_opcode (self#read_mem pc) with
      | (1, modeb, modea) -> self#apply_binop ( + ) modea modeb; step ()
      | (2, modeb, modea) -> self#apply_binop ( * ) modea modeb; step ()
      | (3, _, _) -> self#write_mem (self#read_mem (pc+1)) (List.hd inputs);
                     inputs <- (List.tl inputs);
                     pc <- pc + 2;
                     step ()
      | (4, _, _) -> let output = self#read_mem (self#read_mem (pc+1)) in
                     pc <- pc + 2; output
      | (5, modeb, modea) -> self#cond_jump ((!=) 0) modea modeb; step ()
      | (6, modeb, modea) -> self#cond_jump ((==) 0) modea modeb; step ()
      | (7, modeb, modea) -> self#apply_binop ( fun x y -> if x < y then 1 else 0 ) modea modeb;
                             step ()
      | (8, modeb, modea) -> self#apply_binop ( fun x y -> if x == y then 1 else 0 ) modea modeb;
                             step ()
      | (99, _, _) -> pc <- (-1); -1
      | _  -> printf "invalid instruction %d\n" (self#read_mem pc); pc <- (-1); -1
    in step ()
end

let run_with_phases (init_memory : int array) (phases : int list) : int =
  let computers = List.map (fun phase -> new intcode_interpreter init_memory [phase]) phases in
  let rec do_loop init_value =
    let result =
      List.fold_left
        (fun input comp -> comp#add_input input; comp#get_output)
        init_value
        computers
    in
    if (List.last computers)#is_done then init_value else do_loop result
  in do_loop 0

let rec permutations = function
  | [] -> []
  | x::[] -> [[x]]
  | l -> List.fold_left (fun acc x -> acc @ List.map (fun p -> x::p) (permutations (List.filter ((<>) x) l))) [] l

let solve (input : string) : unit =
  let init_memory = String.split_on_char ',' input
                    |> List.map (int_of_string)
                    |> Array.of_list
  in
  List.map (run_with_phases init_memory) (permutations [5;6;7;8;9])
  |> List.fold_left max 0
  |> printf "Result: %d\n"

let () = File.lines_of "input" |> Enum.peek |> Option.get |> solve
