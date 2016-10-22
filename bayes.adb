with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random, funcs;
with Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;

procedure bayes is
   action_char : Character;
   n : Natural := 0;
   belief : funcs.uniDist;

begin

   funcs.Initialise;

   while(True) loop

      belief := funcs.getBelief; --gets current belief

      New_Line; Put_Line("t = " & n'Img);

      Put("Belief of OPEN door is = ");
      Ada.Float_Text_IO.Put(belief(n), 1, 3, 0); New_Line;

      Put_Line("Do you want to OPEN the door? (y / n / q)");
      Get(action_char);

      n := n + 1;		--iteration counter
      case action_char is
         when 'y' =>
            --yes
            --Updates the beliefs AND TRIES to open the door
            funcs.updateBelief(n, funcs.TRY);

         when 'n' =>
            --no
            --Updates the beliefs WITHOUT TRYING to open the door
            funcs.updateBelief(n, funcs.DONT);

         when 'q' =>
            --quit
            --gets and prints the door state
            if(funcs.getDoorStatus) then
               Put_Line("The door was OPEN");
            else
               Put_Line("The door was CLOSED");
            end if;
            exit;

         when others =>
            --catch case if invalid character input
            Put_Line("Invalid action");
            n := n - 1;
      end case;
   end loop;


end bayes;
