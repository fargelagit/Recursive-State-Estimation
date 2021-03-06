with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random, funcs;
with Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;



procedure bayes is
   type actArr is array (0..99) of Natural;
   type doorArr is array (0..99) of Boolean;
   action_char : Character;
   n : Natural := 0;
   belief : funcs.uniDist;
   actions : actArr;
   doorStates : doorArr;

begin

   funcs.Initialise;
   doorStates(0) := funcs.getDoorStatus;

   while(TRUE) loop

      belief(n) := funcs.getBelief(n); --gets belief vector

      New_Line; Put_Line("t = " & n'Img);

      Put("Belief of OPEN door is = ");
      Ada.Float_Text_IO.Put(belief(n), 1, 3, 0); New_Line;
      if (funcs.getMeasurement(n)) then
         Put_Line("And the door was measured to be OPEN");
      else
         Put_Line("And the door was measured to be CLOSED");
      end if;

      Put_Line("Do you want to OPEN the door? (y / n / q)");
      Get(action_char);

      n := n + 1;		--iteration counter

      case action_char is
         when 'y' =>
            --yes
            --Updates the beliefs AND TRIES to open the door
            funcs.updateBelief(n, funcs.TRY);
            actions(n-1) := 1;

         when 'n' =>
            --no
            --Updates the beliefs WITHOUT TRYING to open the door
            funcs.updateBelief(n, funcs.DONT);
            actions(n-1) := 0;

         when 'q' =>
            --quit
            actions(n-1) := 2;
            --exits the loop
            exit;

         when others =>
            --catch case if invalid character input
            Put_Line("Invalid action");
            n := n - 1;
      end case;

      --get true door state
      doorStates(n) := funcs.getDoorStatus;
   end loop;

   New_Line;
   Put_Line("| Time  |      Belief      |     Measured      | Actual  | Action |");

   for I in 0..(n-1) loop
      Put("t = " & I'Img & "  -  ");
      Put("BelOpen: ");
      Ada.Float_Text_IO.Put(belief(I), 1, 3 ,0);
      Put("  -  Measured: ");
      if(funcs.getMeasurement(I)) then
         Put("OPEN  ");
      else
         Put("CLOSED");
      end if;
      if(doorStates(I)) then
         Put(" | OPEN  ");
      else
         Put(" | CLOSED");
      end if;

      if(actions(I) = 1) then
         Put("  -  A: Try");
      elsif(actions(I) = 0) then
         Put("  -  A: Dont");
      else
         Put("  -  A: Quit");
      end if;
      New_Line;
   end loop;

end bayes;
