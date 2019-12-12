open Batteries
open Printf

type moon = int*int*int*int*int*int

let rec gcd a b = if b = 0 then a else gcd b (a mod b)
let lcm a b = a * b / gcd a b

let sign x =
  match x with
  | 0 -> 0
  | _ -> x / abs x

let rec apply_n (f : 'a -> 'a) (n : int) (x : 'a) =
  match n with
  | 0 -> x
  | n -> apply_n f (n-1) (f x)

(* Note that this is injetive in the first argument, i.e.,
   (apply_gravity m1 m2 == apply_gravity m1' m2) -> m1 == m1'. *)
let apply_gravity_one ((x1, y1, z1, dx1, dy1, dz1) : moon) ((x2, y2, z2, _, _, _) : moon) : moon =
  (x1, y1, z1, dx1 + sign (x2 - x1), dy1 + sign (y2 - y1), dz1 + sign (z2 - z1))

(* This is therefore also injective, i.e.,
   (apply_gravity_all ms == apply_gravity_all ms') -> ms == ms'. *)
let apply_gravity_all (moons : moon list) : moon list =
  List.map (fun moon -> List.fold_left apply_gravity_one moon moons) moons

(* Clearly injective. *)
let apply_velocity_all (moons : moon list) : moon list =
  List.map (fun (x,y,z,dx,dy,dz) -> (x+dx,y+dy,z+dz,dx,dy,dz)) moons

(* Finally, this is also injective, since it is a composition of
   injective functions. This will be important in the second part of
   the assignment. *)
let step (moons : moon list) : moon list =
  moons |> apply_gravity_all |> apply_velocity_all

let get_energy (moons : moon list) = List.sum (List.map (fun (x,y,z,dx,dy,dz) -> (abs x + abs y + abs z) * (abs dx + abs dy + abs dz)) moons)

let part1 (positions : moon list) =
  positions
  |> apply_n step 1000
  |> get_energy
  |> printf "Total energy: %d\n"

let solve (positions : moon list) =
  (* Rationale: Since the function step is injective, the first
     repeating state will be the initial one. It is therefore
     sufficient to compare the current state with the initial one. *)
  let initx = List.map (fun (x,_,_,dx,_,_) -> (x,dx)) positions in
  let inity = List.map (fun (_,y,_,_,dy,_) -> (y,dy)) positions in
  let initz = List.map (fun (_,_,z,_,_,dz) -> (z,dz)) positions in
  let (firstx, firsty, firstz) = (ref 0, ref 0, ref 0) in
  let current = ref positions in
  let steps = ref 0 in
  while !firstx = 0 || !firsty = 0 || !firstz = 0 do
    current := step !current;
    steps := !steps + 1;
    if !firstx = 0 && initx = List.map (fun (x,_,_,dx,_,_) -> (x,dx)) !current then (firstx := !steps; printf "X: %d\n" !steps);
    if !firsty = 0 && inity = List.map (fun (_,y,_,_,dy,_) -> (y,dy)) !current then (firsty := !steps; printf "Y: %d\n" !steps);
    if !firstz = 0 && initz = List.map (fun (_,_,z,_,_,dz) -> (z,dz)) !current then (firstz := !steps; printf "Z: %d\n" !steps);
  done;
  printf "Result: %d\n" (lcm (lcm !firstx !firsty) !firstz)

let () = let filelines = File.lines_of "input" in
         filelines
         |> Enum.map (fun line ->
                line |> String.split_on_char ','
                |> List.map (String.split_on_char '=') |> List.concat
                |> List.map (String.split_on_char ',') |> List.concat
                |> List.map (String.split_on_char '>') |> List.concat
              )
         |> Enum.map (fun line -> (int_of_string (List.nth line 1),
                                   int_of_string (List.nth line 3),
                                   int_of_string (List.nth line 5), 0, 0, 0))
         |> List.of_enum
         |> solve
