open Batteries

(* Fuel required to launch a given module is based on its mass.
   Specifically, to find the fuel required for a module, take its
   mass, divide by three, round down, and subtract 2. *)
let compute_fuel mass = mass / 3 - 2

let compute_fuel_rec mass =
  (Enum.seq mass compute_fuel ((<) 0)) |>
  Enum.skip 1 |>
  Enum.sum

let () = let filelines = File.lines_of "input" in
         filelines |> Enum.map int_of_string |> Enum.map compute_fuel_rec |> Enum.sum |> print_int;
         print_newline ()
