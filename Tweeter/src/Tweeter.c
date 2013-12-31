#include <pebble.h>

static Window *window;
static TextLayer *text_layer;
static TextLayer *media_layer;
static TextLayer *refresh_button_layer;

enum {
  KEY_REQUEST,
  KEY_STATUS,
  KEY_INT,
  KEY_STRING,
  KEY_TRACK_INFO,
  KEY_TWEET,
};

enum {
  REQUEST_STATUS,
  REQUEST_TRACK_INFO,
  REQUEST_TWEET,
};

void out_sent_handler(DictionaryIterator *sent, void *context) {
 // outgoing message was delivered
}


void out_failed_handler(DictionaryIterator *failed, AppMessageResult reason, void *context) {
 // outgoing message failed
}


void in_received_handler(DictionaryIterator *received, void *context) {
 // incoming message received
  text_layer_set_text(text_layer, "Received");

  // Check for fields you expect to receive
  Tuple *request_id_tuple = dict_find(received, KEY_REQUEST);
  
  // Act on the found fields received
  if (request_id_tuple) {
    uint32_t request_id = request_id_tuple->value->uint32;
    switch(request_id)
    {
      case REQUEST_STATUS:
        { 
          Tuple *status_tuple = dict_find(received, KEY_STATUS);
          uint32_t status = status_tuple->value->uint32;
          if (status == 0)
          { 
            Tuple *message_tuple = dict_find(received, KEY_STRING);
            text_layer_set_text(text_layer, message_tuple->value->cstring);          
          }
          else
          {
            Tuple *message_tuple = dict_find(received, KEY_TRACK_INFO);
            text_layer_set_text(media_layer, message_tuple->value->cstring);
            text_layer_set_text(text_layer, "Tweet?");           
          }
        }
      break;
      case REQUEST_TWEET:
        {
          Tuple *message_tuple = dict_find(received, KEY_TWEET);
          text_layer_set_text(text_layer, message_tuple->value->cstring);           
        }
        break;
    }


    //text_layer_set_text(text_layer, text_tuple->value->uint32);
  }
}

static void send_message(int key, int value)
{
  DictionaryIterator *iter;
  app_message_outbox_begin(&iter);
  Tuplet tuplet = TupletInteger(key, value);
  dict_write_tuplet(iter, &tuplet);
  app_message_outbox_send();
  //text_layer_set_text(text_layer, "Tweeted");  
}


void in_dropped_handler(AppMessageResult reason, void *context) {
 // incoming message dropped
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  text_layer_set_text(text_layer, "Select");
  // DictionaryIterator *iter;
  // app_message_outbox_begin(&iter);
  // Tuplet value = TupletInteger(1, REQUEST_TWEET);
  // dict_write_tuplet(iter, &value);
  // app_message_outbox_send();

  send_message (1, REQUEST_TWEET);
  text_layer_set_text(text_layer, "Tweeting");

}



static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  //text_layer_set_text(text_layer, "Up");
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  //text_layer_set_text(text_layer, "Down");
  text_layer_set_text(text_layer, "Refreshing");
  send_message(1, REQUEST_STATUS);

}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  text_layer = text_layer_create((GRect) { .origin = { 0, 72 }, .size = { bounds.size.w, 40 } });
  text_layer_set_text(text_layer, "Connecting...");
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(text_layer, GTextOverflowModeWordWrap);
  layer_add_child(window_layer, text_layer_get_layer(text_layer));
  

  media_layer = text_layer_create((GRect) { .origin = { 0, 10 }, .size = { bounds.size.w, 60 } });
  text_layer_set_text(media_layer, "");
  text_layer_set_text_alignment(media_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(media_layer, GTextOverflowModeWordWrap);
  text_layer_set_font(media_layer, fonts_get_system_font(FONT_KEY_ROBOTO_CONDENSED_21));
  layer_add_child(window_layer, text_layer_get_layer(media_layer));

  refresh_button_layer = text_layer_create((GRect) { .origin = { 0, 120 }, .size = { bounds.size.w, 20 } });
  text_layer_set_text(refresh_button_layer, "Refresh");
  text_layer_set_text_alignment(refresh_button_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(refresh_button_layer, GTextOverflowModeWordWrap);
  layer_add_child(window_layer, text_layer_get_layer(refresh_button_layer));


  send_message(1, REQUEST_STATUS);




}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);
  text_layer_destroy(media_layer);
  text_layer_destroy(refresh_button_layer);
}

static void init(void) {


  app_message_register_inbox_received(in_received_handler);
  app_message_register_inbox_dropped(in_dropped_handler);
  app_message_register_outbox_sent(out_sent_handler);
  app_message_register_outbox_failed(out_failed_handler);

  const uint32_t inbound_size = 64;
  const uint32_t outbound_size = 64;
  app_message_open(inbound_size, outbound_size);


  window = window_create();
  window_set_click_config_provider(window, click_config_provider);
  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}
