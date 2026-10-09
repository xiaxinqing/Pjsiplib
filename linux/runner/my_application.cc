#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "audio_device_change_monitor.h"
#include "flutter/generated_plugin_registrant.h"

namespace {

constexpr char kAudioDeviceChannelName[] =
    "voip_desk/audio_device_changes";

struct AudioDeviceNotification {
  FlMethodChannel* channel;
};

gboolean invoke_audio_devices_changed(gpointer user_data) {
  auto* notification = static_cast<AudioDeviceNotification*>(user_data);
  fl_method_channel_invoke_method(notification->channel, "audioDevicesChanged",
                                  nullptr, nullptr, nullptr, nullptr);
  g_object_unref(notification->channel);
  delete notification;
  return G_SOURCE_REMOVE;
}

void notify_audio_devices_changed(FlMethodChannel* channel) {
  if (channel == nullptr) {
    return;
  }
  auto* notification = new AudioDeviceNotification{
      FL_METHOD_CHANNEL(g_object_ref(channel)),
  };
  g_main_context_invoke(nullptr, invoke_audio_devices_changed, notification);
}

FlValue* audio_endpoint_value(const LinuxAudioEndpointInfo& endpoint) {
  if (!endpoint.available) {
    return fl_value_new_null();
  }
  FlValue* value = fl_value_new_map();
  fl_value_set_string_take(value, "id",
                           fl_value_new_string(endpoint.id.c_str()));
  fl_value_set_string_take(value, "name",
                           fl_value_new_string(endpoint.name.c_str()));
  return value;
}

}  // namespace

static gchar* app_icon_path() {
  g_autofree gchar* executable_path = g_file_read_link("/proc/self/exe", nullptr);
  if (executable_path != nullptr) {
    g_autofree gchar* executable_dir = g_path_get_dirname(executable_path);
    g_autofree gchar* bundled_icon =
        g_build_filename(executable_dir, "data", "app_icon.png", nullptr);
    if (g_file_test(bundled_icon, G_FILE_TEST_EXISTS)) {
      return g_strdup(bundled_icon);
    }
  }

#ifdef APP_ICON_SOURCE_PATH
  if (g_file_test(APP_ICON_SOURCE_PATH, G_FILE_TEST_EXISTS)) {
    return g_strdup(APP_ICON_SOURCE_PATH);
  }
#endif

  return nullptr;
}

static void set_window_icon(GtkWindow* window) {
  g_autofree gchar* icon_path = app_icon_path();
  if (icon_path == nullptr) {
    return;
  }

  g_autoptr(GError) error = nullptr;
  if (!gtk_window_set_icon_from_file(window, icon_path, &error)) {
    g_warning("Failed to load app icon: %s", error->message);
  }
}

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  FlMethodChannel* attention_channel;
  FlMethodChannel* audio_device_channel;
  LinuxAudioDeviceChangeMonitor* audio_device_monitor;
  GtkWindow* main_window;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void window_attention_method_call_cb(FlMethodChannel* channel,
                                            FlMethodCall* method_call,
                                            gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  if (self->main_window == nullptr) {
    g_autoptr(FlMethodResponse) response = FL_METHOD_RESPONSE(
        fl_method_error_response_new("no_window", "Main window is not ready",
                                     nullptr));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  if (g_strcmp0(method, "requestAttention") == 0) {
    gtk_window_set_urgency_hint(self->main_window, TRUE);
    gtk_window_present(self->main_window);
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  if (g_strcmp0(method, "clearAttention") == 0) {
    gtk_window_set_urgency_hint(self->main_window, FALSE);
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  fl_method_call_respond(method_call, response, nullptr);
}

static void audio_device_method_call_cb(FlMethodChannel*,
                                        FlMethodCall* method_call,
                                        gpointer user_data) {
  MyApplication* self = MY_APPLICATION(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  if (self->audio_device_monitor == nullptr) {
    self->audio_device_monitor = new LinuxAudioDeviceChangeMonitor([self]() {
      notify_audio_devices_changed(self->audio_device_channel);
    });
  }

  if (g_strcmp0(method, "startMonitoring") == 0) {
    const bool started = self->audio_device_monitor->Start();
    g_autoptr(FlValue) result = fl_value_new_bool(started);
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  if (g_strcmp0(method, "stopMonitoring") == 0) {
    self->audio_device_monitor->Stop();
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  if (g_strcmp0(method, "getCurrentAudioRoute") == 0) {
    LinuxSystemAudioRouteInfo route;
    if (!self->audio_device_monitor->Start() ||
        !self->audio_device_monitor->GetCurrentAudioRoute(&route)) {
      g_autoptr(FlMethodResponse) response =
          FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
      fl_method_call_respond(method_call, response, nullptr);
      return;
    }

    g_autoptr(FlValue) result = fl_value_new_map();
    fl_value_set_string_take(result, "input",
                             audio_endpoint_value(route.input));
    fl_value_set_string_take(result, "output",
                             audio_endpoint_value(route.output));
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_success_response_new(result));
    fl_method_call_respond(method_call, response, nullptr);
    return;
  }

  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  fl_method_call_respond(method_call, response, nullptr);
}

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
  self->main_window = window;
  set_window_icon(window);

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "VPhone");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "VPhone");
  }

  gtk_window_set_default_size(window, 1280, 720);

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(
      project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  GdkRGBA background_color;
  // Background defaults to black, override it here if necessary, e.g. #00000000
  // for transparent.
  gdk_rgba_parse(&background_color, "#fafafa");
  fl_view_set_background_color(view, &background_color);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  // 渲染照常进行，由 Dart 完成窗口配置后统一显示。
  gtk_widget_realize(GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  FlPluginRegistrar* attention_registrar =
      fl_plugin_registry_get_registrar_for_plugin(
          FL_PLUGIN_REGISTRY(view), "VoipDeskWindowAttention");
  g_autoptr(FlStandardMethodCodec) attention_codec =
      fl_standard_method_codec_new();
  self->attention_channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(attention_registrar),
      "voip_desk/window_attention", FL_METHOD_CODEC(attention_codec));
  fl_method_channel_set_method_call_handler(
      self->attention_channel, window_attention_method_call_cb,
      g_object_ref(self), g_object_unref);

  FlPluginRegistrar* audio_device_registrar =
      fl_plugin_registry_get_registrar_for_plugin(
          FL_PLUGIN_REGISTRY(view), "VoipDeskAudioDeviceChanges");
  g_autoptr(FlStandardMethodCodec) audio_device_codec =
      fl_standard_method_codec_new();
  self->audio_device_channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(audio_device_registrar),
      kAudioDeviceChannelName, FL_METHOD_CODEC(audio_device_codec));
  fl_method_channel_set_method_call_handler(
      self->audio_device_channel, audio_device_method_call_cb,
      g_object_ref(self), g_object_unref);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application,
                                                  gchar*** arguments,
                                                  int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
    g_warning("Failed to register: %s", error->message);
    *exit_status = 1;
    return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  // MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  if (self->audio_device_monitor != nullptr) {
    self->audio_device_monitor->Stop();
    delete self->audio_device_monitor;
    self->audio_device_monitor = nullptr;
  }
  g_clear_object(&self->audio_device_channel);
  g_clear_object(&self->attention_channel);
  self->main_window = nullptr;
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line =
      my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID, "flags",
                                     G_APPLICATION_NON_UNIQUE, nullptr));
}
