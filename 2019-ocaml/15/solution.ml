open Batteries
open Printf

module IntInt = struct
  type t = int * int
  let compare = compare
end

module MyTypeMap = Map.Make(IntInt)

module IntMap = Map.Make(Int)
module IntIntSet = Set.Make(IntInt)

type argmode = Position | Immediate  | Relative

let argmode_of_char ch =
  match ch with
  | '0' -> Position
  | '1' -> Immediate
  | '2' -> Relative
  | _   -> raise (Invalid_argument "unsupported arg mode")

class intcode_interpreter init_memory (init_inputs : int list) =
object (self)
  val mutable memory = init_memory
  val mutable inputs = init_inputs
  val mutable pc = 0
  val mutable offset = 0

  method private parse_opcode oc =
    let str = string_of_int oc in
    let str_c = String.concat "" [String.make (5 - String.length str) '0'; str] in
    (int_of_string (String.sub str_c 3 2),
     argmode_of_char str_c.[0],
     argmode_of_char str_c.[1],
     argmode_of_char str_c.[2])

  method private read_mem pos = IntMap.find_default 0 pos memory
  method private write_mem pos v = memory <- IntMap.modify_def 0 pos (fun _ -> v) memory

  method private read_with_mode mode pos =
    match mode with
    | Position -> self#read_mem (self#read_mem pos)
    | Immediate -> self#read_mem pos
    | Relative  -> self#read_mem ((self#read_mem pos) + offset)

  method private write_with_mode mode pos =
    match mode with
    | Position -> self#write_mem (self#read_mem pos)
    | Immediate -> self#write_mem pos
    | Relative  -> self#write_mem ((self#read_mem pos) + offset)

  method private apply_binop op modea modeb modeo =
    self#write_with_mode modeo (pc+3)
      (op (self#read_with_mode modea (pc+1)) (self#read_with_mode modeb (pc+2)));
    pc <- pc+4;

  method private cond_jump cond modea modeb =
    if cond (self#read_with_mode modea (pc+1))
    then pc <- self#read_with_mode modeb (pc+2)
    else pc <- pc+3

  method is_done = pc == -1

  method add_input (input : int) = inputs <- inputs @ [input]

  method get_output =
    let rec step () =
      match self#parse_opcode (self#read_mem pc) with
      | (1, modeo, modeb, modea) -> self#apply_binop ( + ) modea modeb modeo; step ()
      | (2, modeo, modeb, modea) -> self#apply_binop ( * ) modea modeb modeo; step ()
      | (3, _, _, modea) -> self#write_with_mode modea (pc+1) (List.hd inputs);
                            inputs <- (List.tl inputs);
                            pc <- pc + 2;
                            step ()
      | (4, modeo, _, modea) -> let output = self#read_with_mode modea (pc+1) in
                                pc <- pc + 2; output
      | (5, modeo, modeb, modea) -> self#cond_jump ((!=) 0) modea modeb; step ()
      | (6, modeo, modeb, modea) -> self#cond_jump ((==) 0) modea modeb; step ()
      | (7, modeo, modeb, modea) -> self#apply_binop (fun x y -> Bool.to_int (x < y)) modea modeb modeo;
                                    step ()
      | (8, modeo, modeb, modea) -> self#apply_binop (fun x y -> Bool.to_int (x == y)) modea modeb modeo;
                                    step ()
      | (9, _, _, modea) -> offset <- offset + self#read_with_mode modea (pc+1);
                            pc <- pc+2;
                            step ()
      | (99, _, _, _) -> pc <- (-1); -1
      | _  -> printf "invalid instruction %d\n" (self#read_mem pc); pc <- (-1); -1
    in step ()

  method run =
    while not self#is_done do
      let output = self#get_output in
      if not self#is_done then printf "%d\n" output
    done
end

(* all above this is the intcode interpreter *)
(* the actual solution is below*)

let get_successors_pc ((x, y), steps, pc) =
  [ (let newPc = Oo.copy pc in newPc#add_input 1; ((x,y-1), steps+1, newPc)) ;
    (let newPc = Oo.copy pc in newPc#add_input 2; ((x,y+1), steps+1, newPc)) ;
    (let newPc = Oo.copy pc in newPc#add_input 3; ((x-1,y), steps+1, newPc)) ;
    (let newPc = Oo.copy pc in newPc#add_input 4; ((x+1,y), steps+1, newPc)) ]

let find_oxygen pc =
  let queue = Queue.create () in
  let seen = ref IntIntSet.empty in
  let walls = ref IntIntSet.empty in
  let oxypos = ref (0,0) in
  let oxysteps = ref 0 in
  Queue.push ((0,0), 0, pc) queue;
  while (not (Queue.is_empty queue)) do
    let (curpos, curdist, curpc) = Queue.take queue in
    seen := IntIntSet.add curpos !seen;
    get_successors_pc (curpos, curdist, curpc) |>
      List.filter (fun (sucpos, _, _) -> (not (IntIntSet.mem sucpos !seen))) |>
      List.iter (fun (sucpos, sucsteps, sucpc) ->
          match sucpc#get_output with
          | 0 -> walls := IntIntSet.add sucpos !walls
          | 1 -> Queue.push (sucpos, sucsteps, sucpc) queue
          | _ -> oxypos := sucpos;
                 oxysteps := sucsteps;
                 Queue.push (sucpos, sucsteps, sucpc) queue)
  done;
  (!oxypos, !oxysteps, !walls)

let get_successors ((x, y), steps) =
  [ ((x,y-1), steps+1) ;
    ((x,y+1), steps+1) ;
    ((x-1,y), steps+1) ;
    ((x+1,y), steps+1) ]

let fill_with_oxygen oxypos walls =
  let queue = Queue.create () in
  let seen = ref IntIntSet.empty in
  let dist = ref 0 in
  Queue.push (oxypos, 0) queue;
  while (not (Queue.is_empty queue)) do
    let (curpos, curdist) = Queue.take queue in
    seen := IntIntSet.add curpos !seen;
    dist := curdist;
    get_successors (curpos, curdist) |>
      List.filter (fun (sucpos, _) -> not (IntIntSet.mem sucpos walls) && (not (IntIntSet.mem sucpos !seen))) |>
      List.iter (fun suc -> Queue.push suc queue)
  done;
  !dist

let solve (input : string) : unit =
  let init_memory =
    String.split_on_char ',' input
    |> List.map (fun s -> int_of_string s)
    |> List.fold_lefti (fun map i v -> IntMap.add i v map) IntMap.empty in
  let pc = new intcode_interpreter init_memory [] in
  let (oxypos, oxysteps, walls) = find_oxygen pc in
  printf "Found oxygen in %d steps.\n" oxysteps;
  printf "Filled with oxygen after %d minutes.\n" (fill_with_oxygen oxypos walls)

let () = File.lines_of "input" |> Enum.peek |> Option.get |> solve
