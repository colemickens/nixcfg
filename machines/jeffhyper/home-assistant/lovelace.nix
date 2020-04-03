{
  title = "GoonAssistant";
  views = [
    {
      title = "Security";
      cards = [
        {
          title = "Weather";
          type = "weather-forecast";
          entity = "weather.openweathermap";
        }
        {
          title = "Alarm System";
          type = "alarm-panel";
          entity = "alarm_control_panel.alarm_panel";
        }
        {
          title = "Alarm System";
          type = "history-graph";
          entities = [{
            name = "Alarm Panel";
            entity = "alarm_control_panel.alarm_panel";
          }];
        }
        {
          title = "Alarm System";
          type = "entities";
          entities = [
            {
              name = "Alarm Panel";
              entity = "alarm_control_panel.alarm_panel";
            }
            {
              name = "Alarm Panel";
              entity = "sensor.alarm_panel_display";
            }
            {
              name = "UNKNOWN BINARY SENSOR";
              entity = "binary_sensor.unknown";
            }
          ];
        }
        {
          title = "Motion Sensors";
          type = "history-graph";
          hours_to_show = 1;
          entities = [
            {
              name = "Upstairs";
              entity = "binary_sensor.motion_upstairs";
            }
            {
              name = "Downstairs";
              entity = "binary_sensor.motion_downstairs";
            }
          ];
        }
        {
          title = "Door Sensors";
          type = "history-graph";
          hours_to_show = 1;
          entities = [
            {
              name = "Kitchen";
              entity = "binary_sensor.door_kitchen";
            }
            {
              name = "Front";
              entity = "binary_sensor.door_front";
            }
            {
              name = "Downstairs";
              entity = "binary_sensor.door_downstairs";
            }
          ];
        }
      ];
    }
    {
      title = "Plex";
      cards = [{
        title = "Plex";
        type = "entities";
        entities = [ "sensor.plex_goonr8r" ];
      }];
    }
    {
      title = "Family Room";
      cards = [{
        title = "Denon Family Room";
        entity = "media_player.denonavr_family_room";
        type = "media-control";
      }];
    }
    {
      title = "Patio";
      cards = [{
        title = "Denon Patio";
        entity = "media_player.denonavr_patio";
        type = "media-control";
      }];
    }
    {
      title = "Sewing Room";
      cards = [
        {
          title = "Roku";
          entity = "media_player.sewing_room";
          type = "media-control";
        }
        {
          title = "Sewing Room Roku";
          type = "entities";
          entities = [
            {
              name = "Roku (Sewing Room)";
              entity = "media_player.sewing_room";
            }
            {
              name = "Roku (Sewing Room)";
              entity = "remote.sewing_room";
            }
          ];
        }
      ];
    }
    {
      title = "Media Room";
      cards = [
        {
          title = "Roku";
          entity = "media_player.media_room_roku";
          type = "media-control";
        }
        {
          title = "Media Room Roku";
          type = "entities";
          entities = [
            {
              name = "Roku (Media Room)";
              entity = "media_player.media_room_roku";
            }
            {
              name = "Roku (Media Room)";
              entity = "remote.media_room_roku";
            }
          ];
        }
      ];
    }
  ];
}
