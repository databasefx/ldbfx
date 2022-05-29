vala_compiler = meson.get_compiler('vala')

dbfx_vala_sources = [
  resources,
  'main.vala',
  'tab-service.vala',
  'util/ui-util.vala',
  'util/os-util.vala',
  'util/json-util.vala',
  'config/nav-tree.vala',
  'config/app-config.vala',
  'widget/fx-alert.vala',
  'widget/sqlite-compact.vala',
  'widget/data-source-compact.vala',
  'widget/notebook-tab.vala',
  'widget/notebook-table.vala',
  'model/table-row-meta.vala',
  'event/nav-tree-event.vala',
  'dialog/dd-dialog.vala',
  'dialog/connect-dialog.vala',
  'controller/main-controller.vala'
]


dbfx_vala_deps = [
  gio,
  gtk,
  libgee,
  libxml,
  libjson,
  libdbfx_dep,
  libsourceview
]

dbfx_c_args = [
  '-include', 'config.h',
]


executable(
 'ldbfx',
  dbfx_vala_sources,
  install: true,
  c_args:dbfx_c_args,
  dependencies: dbfx_vala_deps,
  include_directories: conf_include_dir
)
