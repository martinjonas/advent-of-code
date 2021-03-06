open Batteries
open Printf

module IntMap = Map.Make(Int)

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

let picture = ref IntMap.empty
let get_picture_pos x y = IntMap.find_default '.' y (IntMap.find_default IntMap.empty x !picture)
let set_picture_pos x y v =
  picture := IntMap.modify_def IntMap.empty x (IntMap.modify_def 'x' y (fun _ -> v)) !picture

type orientation = U | R | D | L

let turn_left ori =
  match ori with
  | U -> L
  | L -> D
  | D -> R
  | R -> U

let turn_right ori = ori |> turn_left |> turn_left |> turn_left

let painted_positions () =
  !picture
  |> IntMap.values
  |> Enum.map IntMap.values
  |> Enum.concat
  |> Enum.count

let solve (input : string) : unit =
  let init_memory =
    String.split_on_char ',' input
    |> List.map (fun s -> int_of_string s)
    |> List.fold_lefti (fun map i v -> IntMap.add i v map) IntMap.empty in
  let pc = new intcode_interpreter init_memory [] in
  let pos = ref (0,0) in
  let dir = ref U in
  set_picture_pos 0 0 '#';
  while not pc#is_done do
    let (x,y) = !pos in
    pc#add_input (if get_picture_pos x y == '.' then 0 else 1);

    (match pc#get_output with
    | 0 -> set_picture_pos x y '.'
    | 1 -> set_picture_pos x y '#'
    | -1 -> ()
    | n -> printf "unexpected output %d\n" n);

    if not pc#is_done then
    (match pc#get_output with
    | 0 -> dir := turn_left !dir
    | 1 -> dir := turn_right !dir
    | n -> printf "unexpected output %d\n" n);
    (match !dir with
    | U -> pos := (x, y-1)
    | L -> pos := (x-1, y)
    | D -> pos := (x, y+1)
    | R -> pos := (x+1, y))
  done;
  printf "Picture size: %d\n" (painted_positions ());
  for y = 0 to 10 do
    for x = 0 to 40 do
      printf "%c" (get_picture_pos x y)
    done;
    printf "\n"
  done

let () = File.lines_of "input" |> Enum.peek |> Option.get |> solve
