{
  title = "Chimera HomeAss";
  views = [{
    title = "Main View";
    cards = [
      {
        title = "Living Room";
        type = "entities";
        entities = [
          {
            name = "Television";
            entity = "media_player.braviatv";
          }
          {
            name = "Fireplace";
            entity = "switch.ge_14291_in_wall_smart_switch_switch";
          }
          {
            name = "Fireplace Christmas Lights";
            entity = "switch.wp6_sw102_relay";
          }
          {
            name = "Receiver";
            entity = "media_player.denonavr";
          }
        ];
      }
      {
        title = "Kitchen";
        type = "entities";
        entities = [
          {
            name = "Kitchen Lights Switch";
            entity = "switch.gosundsw120_relay";
          }
          {
            name = "Barry's Lamp";
            entity = "switch.wp6_sw105_relay";
          }
        ];
      }
      {
        title = "Den";
        type = "entities";
        entities = [{
          name = "Light Strip";
          entity = "light.mh_led101";
        }];
      }
      {
        title = "Buddie's Desk";
        type = "entities";
        entities = [
          {
            name = "Desk Lamp";
            entity = "switch.wp6_sw104_relay";
          }
          {
            name = "Emerald Lamp";
            entity = "switch.wp6_sw109_relay";
          }
        ];
      }
      {
        title = "Bed Room";
        type = "entities";
        entities = [{
          name = "Bedside Lamp";
          entity = "switch.wp6_sw103_relay";
        }];
      }
      {
        title = "Bathroom";
        type = "entities";
        entities = [
          { name = "Fan + Heat Lamp";
            entity = "switch.gosundsw121_relay"; }
          { name = "Vanity Light";
            entity = "switch.gosundsw122_relay"; }
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
