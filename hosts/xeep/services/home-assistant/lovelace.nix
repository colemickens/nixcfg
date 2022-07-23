{
  title = "Chimera HomeAss";
  views = [
    {
      title = "Main View";
      cards = [
        {
          title = "Plant Shelves";
          type = "entities";
          entities = [
            {
              name = "Candle Warmer (plants)";
              entity = "switch.wp6_sw107_relay";
            }
            {
              name = "Dab Rig";
              entity = "switch.wp6_sw104_relay";
            }
          ];
        }
        {
          title = "Air Conditioner";
          type = "thermostat";
          entity = "climate.ac";
        }
        {
          title = "Kitchen Table";
          type = "entities";
          entities = [
            {
              name = "TV - Sony 55 [KDL55W800B]";
              entity = "media_player.braviatv";
            }
          ];
        }
        {
          title = "Living Room";
          type = "entities";
          entities = [
            {
              name = "TV - LG 65 [OLED65C1PUB]";
              entity = "media_player.livingroom_lg_c1";
            }

            {
              name = "[slywin] WoL";
              entity = "switch.slywin";
            }

            {
              name = "Receiver - Denon AVR1913";
              entity = "media_player.denon";
            }
          ];
        }
        # {
        #   title = "Desk";
        #   type = "entities";
        #   entities = [
        #     # {
        #     #   name = "Wall Outlet 1";
        #     #   entity = "switch.wp6_sw106_relay";
        #     # }
        #     # {
        #     #   name = "Wall Outlet 2";
        #     #   entity = "switch.wp6_sw107_relay";
        #     # }
        #   ];
        # }
        {
          title = "Bedroom";
          type = "entities";
          entities = [
            # {
            #   name = "[pelinore] WoL";
            #   entity = "switch.pelinore";
            # }
            # {
            #   name = "Desk Motor";
            #   entity = "switch.wp6_sw102_relay";
            # }
            # {
            #   name = "Flower Lamp";
            #   entity = "switch.wp6_sw103_relay";
            # }
            {
              name = "Candle Warmer (bedroom)";
              entity = "switch.wp6_sw108_relay";
            }
            {
              name = "Nanoleaf";
              entity = "light.nanoleaf_light_panels_5b_38_ef";
            }
          ];
        }
        # {
        #   title = "Kitchen";
        #   type = "entities";
        #   entities = [
        #   ];
        # }
        # {
        #   title = "Den";
        #   type = "entities";
        #   entities = [{
        #     name = "Light Strip";
        #     entity = "light.mh_led101";
        #   }];
        # }
        # {
        #   title = "Buddie's Desk";
        #   type = "entities";
        #   entities = [
        #     {
        #       name = "Desk Lamp";
        #       entity = "switch.wp6_sw104_relay";
        #     }
        #     {
        #       name = "Emerald Lamp";
        #       entity = "switch.wp6_sw109_relay";
        #     }
        #   ];
        # }
        # {
        #   title = "Bed Room";
        #   type = "entities";
        #   entities = [{
        #     name = "Bedside Lamp";
        #     entity = "switch.wp6_sw103_relay";
        #   }];
        # }
        {
          title = "Bathroom";
          type = "entities";
          entities = [
            {
              name = "Candle Warmer (bathroom)";
              entity = "switch.wp6_sw109_relay";
            }
          ];
        }
      ];
    }
    {
      title = "Raspberry Pis";
      cards = [
        {
          title = "Stripper";
          type = "entities";
          entities = [
            {
              name = "rpi-powerstrip";
              entity = "switch.wp6_sw106_relay";
            }
          ];
        }
      ];
    }
    # (let mkSensor = title: entity:
    #   {
    #     title = title; entity = entity;
    #     type = "sensor"; graph = "line";
    #   };
    # in
    #   {
    #     title = "Energy View";
    #     cards = [
    #       {
    #         title = "Energy Cards";
    #         type = "entities";
    #         entities = [
    #           (mkSensor "CT1 Watts"   "sensor.6c_ct1_watts")
    #           (mkSensor "CT2 Watts"   "sensor.6c_ct2_watts")
    #           (mkSensor "CT3 Watts"   "sensor.6c_ct3_watts")
    #           (mkSensor "CT4 Watts"   "sensor.6c_ct4_watts")
    #           (mkSensor "CT5 Watts"   "sensor.6c_ct5_watts")
    #           (mkSensor "CT6 Watts"   "sensor.6c_ct6_watts")
    #           (mkSensor "Total Watts" "sensor.6c_total_watts")
    #         ];
    #       }
    #     ];
    #   }
    # )
  ];
}
