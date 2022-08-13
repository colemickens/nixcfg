{
  title = "Chimera HomeAss";
  views = [
    {
      title = "Main View";
      cards = [
        # {
        #   title = "Automations";
        #   type = "entities";
        #   entities = [
        #     "automation.candle_warmers_schedule_off"
        #     "automation.candle_warmers_schedule_on"
        #     "automation.cleo_lamp_on_20_30"
        #     "automation.cleo_lamp_off_8_30"
        #     "automation.nanoleaf_on_8_30"
        #     "automation.nanoleaf_bed_21_00"
        #     "automation.nanoleaf_off_22_00"
        #   ];
        # }
        # {
        #   title = "Plant Shelves";
        #   type = "entities";
        #   entities = [
        #     {
        #       name = "Candle (plants)";
        #       entity = "switch.wp6_sw107_relay";
        #     }
        #     {
        #       name = "Dab Rig";
        #       entity = "switch.wp6_sw104_relay";
        #     }
        #   ];
        # }
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
              name = "Sony Bravia 55";
              entity = "media_player.braviatv";
            }
          ];
        }
        {
          title = "Living Room";
          type = "entities";
          entities = [
            {
              name = "LG C1 65";
              entity = "media_player.livingroom_lg_c1";
            }

            {
              name = "PC - slywin";
              entity = "switch.slywin";
            }

            {
              name = "Denon AVR1913";
              entity = "media_player.denon";
            }
          ];
        }
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
            # {
            #   name = "Candle (bedroom)";
            #   entity = "switch.wp6_sw108_relay";
            # }
            {
              name = "Nanoleaf △  Lights";
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
        #   entities = [
        #     {
        #       name = "Candle (den-bathroom)";
        #       entity = "switch.wp6_sw105_relay";
        #     }
        #   ];
        # }
        # {
        #   title = "Bathroom";
        #   type = "entities";
        #   entities = [
        #     {
        #       name = "Candle (bathroom)";
        #       entity = "switch.wp6_sw109_relay";
        #     }
        #   ];
        # }
        {
          title = "Projects";
          type = "entities";
          entities = [
            {
              name = "rpi-powerstrip";
              entity = "switch.wp6_sw106_relay";
            }
            {
              name = "visionfive";
              entity = "switch.wp6_sw103_relay";
            }
          ];
        }
        {
          title = "Candles";
          type = "entities";
          entities = [
            { name = "Bathroom-Den"; entity = "switch.wp6_sw105_relay"; }
            { name = "Plant Shelf";  entity = "switch.wp6_sw107_relay"; }
            { name = "Bedroom";      entity = "switch.wp6_sw108_relay"; }
            { name = "Bathroom";     entity = "switch.wp6_sw109_relay"; }
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
