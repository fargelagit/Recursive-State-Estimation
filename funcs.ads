with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random, Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;

package funcs is

   type doorState is (OPEN, CLOSED, PASS);
   type doorAction is (TRY, DONT, PASS);
   type chanceType is (Z, U, PASS);

   type uniDist is array (0..99) of Uniformly_Distributed;


   procedure Initialise;

   function openDoor return Boolean;

   function getProbability(chance : doorState;
                            action : doorAction;
                            state : doorState) return Uniformly_Distributed;

   procedure updateBelief(n : Natural; action : doorAction);

   function getBelief return uniDist;

   function getDoorStatus return Boolean;

private
   procedure setDoor;

   zOpenOpen, 					--probability of door being OPEN when MEASURED OPEN
   zClosedOpen,					--probability of door being OPEN when MEASURED CLOSED
   zOpenClosed,					--probability of door OPENING when TRY
   zClosedClosed : Uniformly_Distributed;	--probability of door NOT OPENING when TRY

   Measurement : Uniformly_Distributed;		--Measurement of door state 1 = OPEN, 0 = CLOSED

   belOpen, belClosed : uniDist;

   Door : Boolean;

end funcs;
