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

puts "Creating session..."

solace_host = ENV["SOLACE_HOST"]
solace_user = ENV["SOLACE_USER"]
solace_password = ENV["SOLACE_PASSWORD"]

session_props = [
  LibSolace::SESSION_PROP_HOST.to_unsafe,
  solace_host.to_unsafe,
  LibSolace::SESSION_PROP_USERNAME.to_unsafe,
  solace_user.to_unsafe,
  LibSolace::SESSION_PROP_PASSWORD.to_unsafe,
  solace_password.to_unsafe,
  LibSolace::SESSION_PROP_CONNECT_BLOCKING.to_unsafe,
  LibSolace::PROP_ENABLE_VAL.to_unsafe,
  LibSolace::END_OF_PROPS
]

session_handlers = LibSolace::SessionHandlers.new
session_handlers.event_handler.callback = ->(
  session : LibSolace::Session,
  event_info : LibSolace::SessionEventInfo*,
  data : Void*
) {
  event = event_info.value.event
  info = String.new(event_info.value.info)
  puts "Session event #{event}, info #{info}"
}
session_handlers.msg_handler.callback = ->(
  session : LibSolace::Session,
  msg : LibSolace::Msg,
  data : Void*
) {
  LibSolace.msg_get_destination(msg, out destination, sizeof(LibSolace::Destination))
  puts "Message from #{String.new(destination.name)}"

  LibSolace::MsgAction::Destroy
}

res = LibSolace.session_create(
  session_props.to_unsafe,
  context,
  out session,
  pointerof(session_handlers),
  sizeof(LibSolace::SessionHandlers)
)

raise "Error: #{res}" if res != LibSolace::ReturnCode::Ok

puts "Connecting..."

res = LibSolace.session_connect(session)

raise "Error: #{res}" if res != LibSolace::ReturnCode::Ok
