require "../solace"

puts "Initializing API..."

res = LibSolace.initialize(
  log_level: LibSolace::LogLevel::Info,
  props: Pointer(Pointer(LibC::Char)).null
)

raise "Error: #{res}" if res != LibSolace::ReturnCode::Ok

puts "Creating context..."

context_props = [
  LibSolace::CONTEXT_PROP_CREATE_THREAD.to_unsafe,
  LibSolace::PROP_ENABLE_VAL.to_unsafe,
  LibSolace::END_OF_PROPS
]

fd_registration_funcs = LibSolace::FDRegistrationFuncs.new

res = LibSolace.context_create(
  props: context_props,
  context: out context,
  funcs: pointerof(fd_registration_funcs),
  funcs_size: sizeof(LibSolace::FDRegistrationFuncs)
)

raise "Error: #{res}" if res != LibSolace::ReturnCode::Ok
