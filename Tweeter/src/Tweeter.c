#include <pebble.h>

static Window *window;

static TextLayer *text_layer;

static TextLayer *track_title_layer;
static TextLayer *track_artist_layer;
static TextLayer *by_layer;

static BitmapLayer *tweet_icon_layer;
static GBitmap *tweet_icon_bitmap = NULL;

static BitmapLayer *refresh_icon_layer;
static GBitmap *refresh_icon_bitmap = NULL;


static int disabled;

enum {
  KEY_REQUEST,
  KEY_STATUS,
  KEY_INT,
  KEY_STRING,
  KEY_TRACK_INFO,
  KEY_TWEET,
  KEY_TRACK_TITLE,
  KEY_TRACK_ARTIST,
};

enum {
  REQUEST_STATUS,
  REQUEST_TRACK_INFO,
  REQUEST_TWEET,
  REQUEST_TRACK_TITLE,
  REQUEST_TRACK_ARTIST,
};

enum {
  RESOURCE_ID_ICON_TWEET,
  RESOURCE_ID_ICON_REFRESH,
};

static uint32_t ICONS[] = {
  RESOURCE_ID_IMAGE_TWEET,
  RESOURCE_ID_IMAGE_REFRESH
};

void out_sent_handler(DictionaryIterator *sent, void *context) {
 // outgoing message was delivered
}


void out_failed_handler(DictionaryIterator *failed, AppMessageResult reason, void *context) {
 // outgoing message failed
}

static void send_message(int key, int value)
{
  APP_LOG(APP_LOG_LEVEL_DEBUG, "Sending: (%d, %d)", key, value);
  DictionaryIterator *iter;
  app_message_outbox_begin(&iter);
  Tuplet tuplet = TupletInteger(key, value);
  dict_write_tuplet(iter, &tuplet);
  app_message_outbox_send();
  //text_layer_set_text(text_layer, "Tweeted");  
}

static void hide_buttons ()
{
  layer_set_hidden(bitmap_layer_get_layer(tweet_icon_layer), true);
  layer_set_hidden(bitmap_layer_get_layer(refresh_icon_layer), true); 
}

static void show_buttons ()
{
  layer_set_hidden(bitmap_layer_get_layer(tweet_icon_layer), false);
  layer_set_hidden(bitmap_layer_get_layer(refresh_icon_layer), false); 
}

static void show_track_info ()
{
  layer_set_hidden(text_layer_get_layer(track_artist_layer), false);
  layer_set_hidden(text_layer_get_layer(track_title_layer), false); 
  layer_set_hidden(text_layer_get_layer(by_layer), false); 
}

static void hide_track_info ()
{
  layer_set_hidden(text_layer_get_layer(track_artist_layer), true);
  layer_set_hidden(text_layer_get_layer(track_title_layer), true); 
  layer_set_hidden(text_layer_get_layer(by_layer), true); 
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
        APP_LOG(APP_LOG_LEVEL_DEBUG, "REQUEST_STATUS");
        Tuple *status_tuple = dict_find(received, KEY_STATUS);
        uint32_t status = status_tuple->value->uint32;
        if (status == 0)
        { 
          Tuple *message_tuple = dict_find(received, KEY_STRING);
          text_layer_set_text(text_layer, message_tuple->value->cstring);
          layer_set_hidden(text_layer_get_layer(by_layer), true);
          disabled = 1; 
          hide_buttons();
          hide_track_info();         
        }
        else
        {
          text_layer_set_text(text_layer, "");
          APP_LOG(APP_LOG_LEVEL_DEBUG, "SETTING MUSIC INFO");
          Tuple *title_tuple = dict_find(received, KEY_TRACK_TITLE);
          text_layer_set_text(track_title_layer, title_tuple->value->cstring);

          Tuple *artist_tuple = dict_find(received, KEY_TRACK_ARTIST);
          text_layer_set_text(track_artist_layer, artist_tuple->value->cstring);

          show_buttons();
          show_track_info();
          disabled = 0;
          // APP_LOG(APP_LOG_LEVEL_DEBUG, "Requesting title");
//          to_send = REQUEST_TRACK_TITLE;
        }
      }
      break;
      
      case REQUEST_TWEET:
      {
        // Tuple *message_tuple = dict_find(received, KEY_TWEET);
        APP_LOG(APP_LOG_LEVEL_DEBUG, "REQUEST TWEET");
        text_layer_set_text(text_layer, "Tweeted!");        
        show_buttons();
      }
      break;
    }
    //text_layer_set_text(text_layer, text_tuple->value->uint32);
  }
}




void in_dropped_handler(AppMessageResult reason, void *context) {
 // incoming message dropped
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  if (disabled == 0)
  {
    disabled = 1;
    text_layer_set_text(text_layer, "Select");
    send_message (1, REQUEST_TWEET);
    text_layer_set_text(text_layer, "Tweeting...");

    hide_buttons();

    // layer_set_hidden(bitmap_layer_get_layer(tweet_icon_layer), true);
    // layer_set_hidden(bitmap_layer_get_layer(refresh_icon_layer), true);
    // layer_remove_from_parent(refresh_icon_layer);
    // layer_remove_from_parent(tweet_icon_layer);
    disabled = 0;
  }
}



static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  //text_layer_set_text(text_layer, "Up");
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  //text_layer_set_text(text_layer, "Down");
  // text_layer_set_text(refresh_button_layer, "");
  send_message(1, REQUEST_STATUS);
  disabled = 1;
  text_layer_set_text(text_layer, "Refreshing");

  hide_track_info();
  hide_buttons();  

  layer_set_hidden(text_layer_get_layer(by_layer), true);
  // layer_remove_from_parent(refresh_icon_layer);
  // layer_remove_from_parent(tweet_icon_layer);
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  
  tweet_icon_layer = bitmap_layer_create(GRect(bounds.size.w-20, 70, 20, 20));
  tweet_icon_bitmap = gbitmap_create_with_resource(ICONS[RESOURCE_ID_ICON_TWEET]);
  bitmap_layer_set_bitmap(tweet_icon_layer, tweet_icon_bitmap);
  layer_add_child(window_layer, bitmap_layer_get_layer(tweet_icon_layer));
  // layer_set_hidden((Layer *)&tweet_icon_layer, true);

  refresh_icon_layer = bitmap_layer_create(GRect(bounds.size.w-20, 120, 20, 20));
  refresh_icon_bitmap = gbitmap_create_with_resource(ICONS[RESOURCE_ID_ICON_REFRESH]);
  bitmap_layer_set_bitmap(refresh_icon_layer, refresh_icon_bitmap);
  layer_add_child(window_layer, bitmap_layer_get_layer(refresh_icon_layer));
  layer_set_hidden(bitmap_layer_get_layer(tweet_icon_layer), true);

  track_title_layer = text_layer_create((GRect) { .origin = { 0, 10 }, .size = { bounds.size.w, 50 } });
  text_layer_set_text(track_title_layer, "");
  text_layer_set_text_alignment(track_title_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(track_title_layer, GTextOverflowModeWordWrap);
  text_layer_set_font(track_title_layer, fonts_get_system_font(FONT_KEY_ROBOTO_CONDENSED_21));
  layer_add_child(window_layer, text_layer_get_layer(track_title_layer));

  by_layer = text_layer_create((GRect) { .origin = { 20, 70 }, .size = { bounds.size.w-40, 20 } });
  text_layer_set_text(by_layer, "by");
  text_layer_set_text_alignment(by_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(by_layer, GTextOverflowModeTrailingEllipsis);
  layer_add_child(window_layer, text_layer_get_layer(by_layer));

  track_artist_layer = text_layer_create((GRect) { .origin = { 0, 90 }, .size = { bounds.size.w, 20 } });
  text_layer_set_text(track_artist_layer, "");
  text_layer_set_text_alignment(track_artist_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(track_artist_layer, GTextOverflowModeTrailingEllipsis);
  layer_add_child(window_layer, text_layer_get_layer(track_artist_layer));

  text_layer = text_layer_create((GRect) { .origin = { 20, 120 }, .size = { bounds.size.w-40, 40 } });
  text_layer_set_text(text_layer, "Connecting...");
  text_layer_set_text_alignment(text_layer, GTextAlignmentCenter);
  text_layer_set_overflow_mode(text_layer, GTextOverflowModeWordWrap);
  layer_add_child(window_layer, text_layer_get_layer(text_layer));

  hide_track_info();
  hide_buttons();
  
  // refresh_button_layer = text_layer_create((GRect) { .origin = { 0, 120 }, .size = { bounds.size.w - 10, 20 } });
  // text_layer_set_text(refresh_button_layer, "Refresh");
  // text_layer_set_text_alignment(refresh_button_layer, GTextAlignmentRight);
  // text_layer_set_overflow_mode(refresh_button_layer, GTextOverflowModeWordWrap);
  // layer_add_child(window_layer, text_layer_get_layer(refresh_button_layer));


  


  send_message(1, REQUEST_STATUS);




}

static void window_unload(Window *window) {
  text_layer_destroy(text_layer);
  text_layer_destroy(track_title_layer);
  text_layer_destroy(track_artist_layer);
  gbitmap_destroy(refresh_icon_bitmap);
  gbitmap_destroy(tweet_icon_bitmap);
  bitmap_layer_destroy(tweet_icon_layer);
  bitmap_layer_destroy(refresh_icon_layer);
  // text_layer_destroy(refresh_button_layer);
}

static void init(void) {


  disabled = 1;

  app_message_register_inbox_received(in_received_handler);
  app_message_register_inbox_dropped(in_dropped_handler);
  app_message_register_outbox_sent(out_sent_handler);
  app_message_register_outbox_failed(out_failed_handler);

  const uint32_t inbound_size = 128;
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
