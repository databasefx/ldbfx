vala_compiler = meson.get_compiler('vala')

dbfx_vala_sources = [
  resources,
  'main.vala',
  'util/ui-util.vala',
  'util/json-util.vala',
  'config/nav-tree.vala',
  'config/app-config.vala',
  'widget/notebook-tab.vala',
  'event/nav-tree-event.vala',
  'dialog/connect-dialog.vala',
  'controller/main-controller.vala'
]


dbfx_vala_deps = [
  gio,
  gtk,
  libgee,
  libxml,
  libjson,
  libdbfx_dep
]

dbfx_c_args = [
  '-include', 'config.h',
]


executable(
 'dbfx-vala',
  dbfx_vala_sources,
  install: true,
  c_args:dbfx_c_args,
  dependencies: dbfx_vala_deps,
  include_directories: conf_include_dir
)
