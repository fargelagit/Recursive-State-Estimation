package body funcs is

   --initialisation procedure
   procedure Initialise is
   begin
      setDoor;
   end Initialise;

   function getMeasurement(n : Natural) return Boolean is
   begin
      return (if pastMStates(n)(0) = OPEN
              then TRUE
              else FALSE);
   end getMeasurement;

   function updateMeasurement return doorState is
      G : Generator;
   begin
      --If door is open
      if (Door) then
         --then calculate to see if we successfully measure it open
         return (if Random(G) < zOpenOpen
                 then OPEN
                 else CLOSED);
      else
         --if door not open see if we successfully measure it closed
         return (if Random(G) < zClosedClosed
                 then CLOSED
                 else OPEN);
      end if;
   end;

   procedure setDoor is
      G : Generator;
      dChance : Uniformly_Distributed;
      C : Character;
   begin
      --various inputs
      Put_Line("Use default values? (y, n)");
      Get(C);
      if(C /= 'y') then
         Put_Line("Input p(z = sense_open | x = is_open)");
         Ada.Float_Text_IO.Get(zOpenOpen);
         zClosedOpen := 1.0 - zOpenOpen;
         Put_Line("Input p(z = sense_closed | x = is_closed)");
         Ada.Float_Text_IO.Get(zClosedClosed);
         zOpenClosed := 1.0 - zClosedClosed;

         Put_Line("Input chance of successfully opening door if tried");
         Ada.Float_Text_IO.Get(doorOpenChance);

         Put_Line("Input initial belief");
         Ada.Float_Text_IO.Get(belOpen(0));
         belClosed(0) := 1.0 - belOpen(0);
      else
         zOpenOpen := 0.6;
         zClosedOpen := 0.4;
         zClosedClosed := 0.8;
         zOpenClosed := 0.2;
         doorOpenChance := 0.8;
         belOpen(0) := 0.5;
         belClosed(0) := 0.5;
      end if;

      Reset(G);
      dChance := Random(G);
      Door := (dChance < belOpen(0));	--sets the actual state of the door

      pastMStates(0)(0) := updateMeasurement;
      pastMStates(0)(1) := (if pastMStates(0)(0) = OPEN
                            then CLOSED
                            else OPEN);
   end setDoor;

   function openDoor return Boolean is
      G : Generator;
   begin
      Reset(G);
      if (Random(G) < doorOpenChance) then
         --if successful
         if(Door) then
            --and door open
            --do nothing
            return FALSE;
         else
            --and door closed
            --open door
            Door := TRUE;
            return TRUE;
         end if;
      else
         --do nothing
         return FALSE;
      end if;
   end openDoor;


   -- getProbability = p(Xn | Un, Xn-1)
   function getProbability(chance : doorState;
                           action : doorAction;
                           state : doorState) return Uniformly_Distributed is
   begin
      if (chance = CLOSED and state = CLOSED and action = TRY) then
         return zOpenClosed;   --default 0.2
      elsif (chance = OPEN and state = CLOSED and action = TRY) then
         return zClosedClosed; --default 0.8
      elsif (chance = state) then
         return 1.0;
      else
         return 0.0;
      end if;
   end getProbability;

   procedure updateBelief(n : Natural; action : doorAction) is
      postBelOpen,
      postBelClosed : Uniformly_Distributed;	--posterior beliefs
      normaliser : Float;
      temp : Boolean;
   begin
      pastMStates(n)(0) := updateMeasurement;
      pastMStates(n)(1) := (if pastMStates(n)(0) = OPEN
                            then CLOSED
                            else OPEN);

      if (action = TRY) then
         --Tries to OPEN DOOR
         temp := openDoor;
      end if;

      --Posterior belief of door being open (eq. 2.46 in the book)

      postBelOpen := (
                      (getProbability(
                      pastMStates(n)(0),   --Xn:   Current measured state of door
                      action,
                      pastMStates(n-1)(0)) --Xn-1: Previous measured state of door
                      * (if pastMStates(n)(0) = OPEN
                        then belOpen(n-1)
                        else belClosed(n-1))
                     )
                      + (getProbability(
                        pastMStates(n)(0),   --Xn:   Current measured state of door
                        action,
                        pastMStates(n-1)(1)) --NOT Xn-1: Inverse previous measured state of door
                        * (if pastMStates(n)(1) = OPEN
                          then belOpen(n-1)
                          else belClosed(n-1))
                       )
                     );

      --Posterior belief of door being closed (eq. 2.47)
      postBelClosed := (
                        (getProbability(
                        pastMStates(n)(1),   --NOT Xn: Inverse current measured state of door
                        action,
                        pastMStates(n-1)(0)) --Xn-1: Previous measured state of door
                        * (if pastMStates(n-1)(0) = OPEN
                          then belOpen(n-1)
                          else belClosed(n-1))
                       )
                        + (getProbability(
                          pastMStates(n)(1),   --NOT Xn: Inverse current measured state of door
                          action,
                          pastMStates(n-1)(1)) --NOT Xn-1: Inverse previous measured state of door
                          * (if pastMStates(n)(1) = OPEN
                            then belOpen(n-1)
                            else belClosed(n-1))
                         )
                       );

      --normaliser (eq. 2.49, 2.50, 2.51 combined)
      normaliser := 1.0 / ((zOpenOpen * postBelOpen) + (zOpenClosed * postBelClosed));

      --New belief of door state is assigned according to eq. 2.48
      belOpen(n)   := normaliser * zOpenOpen * postBelOpen;
      belClosed(n) := normaliser * zOpenClosed * postBelClosed;
   end updateBelief;

   --returns the belief vector
   function getBelief return uniDist is
   begin
      return belOpen;
   end getBelief;

   --reutnrs the status of the door (1 = open, 0 = closed)
   function getDoorStatus return Boolean is
   begin
      return Door;
   end getDoorStatus;

end funcs;
