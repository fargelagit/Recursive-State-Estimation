package body funcs is

   --initialisation procedure
   procedure Initialise is
   begin
      setDoor;
   end Initialise;

   procedure setDoor is
      G : Generator;
      dChance : Uniformly_Distributed;

   begin
      --various inputs
      Put_Line("Input p(z = sense_open | x = is_open)");
      Ada.Float_Text_IO.Get(zOpenOpen);
      zClosedOpen := 1.0 - zOpenOpen;
      Put_Line("Input p(z = sense_closed | x = is_closed)");
      Ada.Float_Text_IO.Get(zOpenClosed);
      zClosedClosed := 1.0 - zOpenClosed;

      Put_Line("Input initial belief");
      Ada.Float_Text_IO.Get(belOpen(0));
      belClosed(0) := 1.0 - belOpen(0);

      Reset(G);
      dChance := Random(G);
      Door := (dChance < belOpen(0));	--sets the actual state of the door
   end setDoor;

   function openDoor return Boolean is
      G : Generator;
   begin
      Reset(G);
      if (Random(G) < zClosedClosed) then
         --if successful
         if(Door) then
            --and door open
            --do nothing
            return false;
         else
            --and door closed
            --open door
            Door := True;
            return true;
         end if;
      else
         --do nothing
         return false;
      end if;
   end openDoor;

   -- getProbability = p(Xn | Un, Xn-1)
   function getProbability(chance : doorState;
                           action : doorAction;
                           state : doorState) return Uniformly_Distributed is
   begin
      case action is
         when TRY =>
            --getProbability = p(Xn | TRY, Xn-1)
            case chance is
               when OPEN =>
                  --getProbability = p(OPEN | TRY, Xn-1)
                  if (state = OPEN) then
                     --getProbability = p(OPEN | TRY, OPEN)
                     return 1.0;
                  else
                     --getProbability = p(OPEN | TRY, CLOSED)
                     return zOpenClosed;
                  end if;
               when CLOSED =>
                  --getProbability = p(CLOSED | TRY, Xn-1)
                  if (state = OPEN) then
                     --getProbability = p(CLOSED | TRY, OPEN)
                     return 0.0;
                  else
                     --getProbability = p(CLOSED | TRY, CLOSED)
                     return zClosedClosed;
                  end if;
               when others =>
                  --catch case
                  return 0.0;
            end case;
         when DONT =>
            --getProbability = p(Xn | DONT, Xn-1)
            case chance is
               when OPEN =>
                  --getProbability = p(OPEN | DONT, Xn-1)
                  if (state = OPEN) then
                     --getProbability = p(OPEN | DONT, OPEN)
                     return 1.0;
                  else
                     --getProbability = p(OPEN | DONT, CLOSED)
                     return 0.0;
                  end if;
               when CLOSED =>
                  --getProbability = p(CLOSED | DONT, Xn-1)
                  if (state = OPEN) then
                     --getProbability = p(CLOSED | DONT, OPEN)
                     return 0.0;
                  else
                     --getProbability = p(CLOSED | DONT, CLOSED)
                     return 1.0;
                  end if;
               when others =>
                  --catch case
                  return 0.0;
            end case;
         when others =>
            --catch case
            return 0.0;
      end case;
   end getProbability;

   procedure updateBelief(n : Natural; action : doorAction) is
      postBelOpen,
      postBelClosed : Uniformly_Distributed;	--posterior beliefs
      normaliser : Float;
      temp : Boolean;
   begin
      --TRY TO OPEN DOOR
      --CALLED IN bayes PROCEDURE
      if (action = TRY) then
         temp := openDoor;	--Tries to OPEN DOOR

         --Posterior belief of door being open (eq. 2.46 in the book)
         postBelOpen := (getProbability(OPEN, TRY, OPEN) * belOpen(n-1))
           + (getProbability(OPEN, TRY, CLOSED) * belClosed(n-1));

         --Posterior belief of door being closed (eq. 2.47)
         postBelClosed := (getProbability(CLOSED, TRY, OPEN) * belOpen(n-1))
           + (getProbability(CLOSED, TRY, CLOSED) * belClosed(n-1));

         --normaliser (eq. 2.49, 2.50, 2.51 combined)
         normaliser := 1.0 / ((zOpenOpen * postBelOpen) + (zClosedClosed * postBelClosed));

         --New belief of door state is assigned according to eq. 2.48
         belOpen(n)   := normaliser * zOpenOpen * postBelOpen;
         belClosed(n) := normaliser * zClosedClosed * postBelClosed;
      else

         --Posterior belief of door being open (eq. 2.46 in the book)
         postBelOpen := (getProbability(OPEN, DONT, OPEN) * belOpen(n-1)) --	___
           + (getProbability(OPEN, DONT, CLOSED) * belClosed(n-1));	--	bel(Xn = is_open)

         --Posterior belief of door being closed (eq. 2.47)
         postBelClosed := (getProbability(CLOSED, DONT, OPEN) * belOpen(n-1)) --___
           + (getProbability(CLOSED, DONT, CLOSED) * belClosed(n-1));   --	bel(Xn = is_closed)

         --normaliser (eq. 2.49, 2.50, 2.51 combined)
         normaliser := 1.0 / ((zOpenOpen * postBelOpen) + (zClosedClosed * postBelClosed));

         --New belief of door state is assigned according to eq. 2.48
         belOpen(n)   := normaliser * zOpenOpen * postBelOpen;
         belClosed(n) := normaliser * zClosedClosed * postBelClosed;
      end if;
   end updateBelief;

   --returns the current bel(Xn = is_open)
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
