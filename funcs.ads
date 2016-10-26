with Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random, Ada.Float_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO, Ada.Numerics.Float_Random;

package funcs is

   type doorState is (OPEN, CLOSED);
   type doorAction is (TRY, DONT);
   type uniDist is array (0..99) of Uniformly_Distributed;
   type doorStates is array (0..1) of doorState;
   type stateArr is array (0..99) of doorStates;


   procedure Initialise;

   procedure updateBelief(n : Natural;
                          action : doorAction);


   function getMeasurement(n : Natural) return Boolean;

   function updateMeasurement return doorState;


   function getProbability(chance : doorState;
                            action : doorAction;
                            state : doorState) return Uniformly_Distributed;

   function openDoor return Boolean;

   function getBelief (n : Natural) return Uniformly_Distributed;

   function getDoorStatus return Boolean;



private

   zOpenOpen, 					--probability of door being OPEN when MEASURED OPEN
   zClosedOpen,					--probability of door being OPEN when MEASURED CLOSED
   zClosedClosed,				--probability of door CLOSED when MEASURED CLOSED
   zOpenClosed : Uniformly_Distributed;		--probability of door CLOSED when MEASURED CLOSED

   doorOpenChance : Uniformly_Distributed;	--Chance of successfully opening door

   Measurement : Uniformly_Distributed;		--Measurement of door state 1 = OPEN, 0 = CLOSED

   belOpen, belClosed : uniDist;
   pastMStates : stateArr;

   Door : Boolean;

end funcs;
