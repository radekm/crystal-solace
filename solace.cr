@[Link(ldflags: "-L#{__DIR__}/solclient")]
@[Link(ldflags: "-lsolclient -lssl -lcrypto")]
{% if flag?(:darwin) %}
  @[Link(framework: "kerberos")]
{% end %}
lib LibSolace

  # ===========================================================
  # Common definitions
  # ===========================================================

  enum ReturnCode : Int32
    # The API call was successful.
    Ok = 0
    # The API call would block, but non-blocking was requested.
    WouldBlock = 1
    # An API call is in progress (non-blocking mode).
    InProgress = 2
    # The API could not complete as an object is not ready
    # (for example, the Session is not connected).
    NotReady = 3
    # A getNext on a structured container returned End-of-Stream.
    EOS = 4
    # A get for a named field in a MAP was not found in the MAP.
    NotFound = 5
    # `context_processEventsWait` returns this if wait is zero and there is no event to process.
    NoEvent = 6
    # The API call completed some, but not all, of the requested function.
    Incomplete = 7
    # `transactedSession_commit` returns this when the transaction has been rolled back.
    Rollback = 8
    # The API call failed.
    Fail = -1
  end

  alias Props = LibC::Char**
  alias Data = Void*

  type UnspecifiedFunc = Void*

  PROP_ENABLE_VAL = "1"
  PROP_DISABLE_VAL = "0"

  END_OF_PROPS = Pointer(LibC::Char).null

  # ===========================================================
  # API initialization
  # ===========================================================

  enum LogLevel
    # A serious error that can make the API unusable.
    Critical = 2
    # An unexpected condition within the API that can affect its operation.
    Error = 3
    # An unexpected condition within the API that is not expected to affect its operation.
    Warning = 4
    # Significant informational messages about the normal operation of the API.
    # These messages are never output in the normal process of sending
    # or receiving a message from the appliance.
    Notice = 5
    # Informational messages about the normal operation of the API.
    # These might include information related to sending
    # or receiving messages from the appliance.
    Info = 6
    # Debugging information generally useful to API developers (very verbose).
    Debug = 7
  end

  fun initialize = solClient_initialize(log_level : LogLevel, props : Props) : ReturnCode

  # ===========================================================
  # Context creation
  # ===========================================================

  type Context = Void*

  CONTEXT_PROP_CREATE_THREAD = "CONTEXT_CREATE_THREAD"

  struct FDRegistrationFuncs
    register_fd_func : UnspecifiedFunc
    unregister_fd_func : UnspecifiedFunc
    data : Data
  end

  fun context_create = solClient_context_create(
    props : Props,
    context : Context*,
    funcs : FDRegistrationFuncs*,
    funcs_size : LibC::SizeT
  ) : ReturnCode

  # ===========================================================
  # Session creation
  # ===========================================================

  type Session = Void*

  # Username required for authentication.
  SESSION_PROP_USERNAME = "SESSION_USERNAME"
  # Password required for authentication.
  # May be set via an environment variable.
  SESSION_PROP_PASSWORD = "SESSION_PASSWORD"
  # The IPv4 or IPv6 address or host name to connect to.
  # Value should provide protocol, host and optionally port.
  # Multiple entries separated by commas are allowed up to `SESSION_PROP_MAX_HOSTS`.
  SESSION_PROP_HOST = "SESSION_HOST"
  # Use `PROP_DISABLE_VAL` to disable blocking connect operation.
  # When disabled `session_connect` returns `ReturnCode::InProgress`.
  SESSION_PROP_CONNECT_BLOCKING = "SESSION_CONNECT_BLOCKING"
  # Use `PROP_DISABLE_VAL` to disable blocking send operation.
  # When disabled send returns `ReturnCode::WouldBlock` if the message can't be accepted
  # by the transport.
  # Note that accepting by the transport doesn't guarantee the message has been processed
  # by the appliance. For that you must used Guaranteed Message Delivery mode
  # and wait for the session event which acknowledges the message.
  SESSION_PROP_SEND_BLOCKING = "SESSION_SEND_BLOCKING"
  # Use `PROP_DISABLE_VAL` to disable blocking subscribe/unsubscribe operation.
  # When disabled subscribe/unsubscribe returns `ReturnCode::WouldBlock`.
  # To ensure that subscription has been processed by appliance you must
  # request confirmation session event.
  SESSION_PROP_SUBSCRIBE_BLOCKING = "SESSION_SUBSCRIBE_BLOCKING"
  # The name of the Message VPN to attempt to join when connecting to an appliance running SolOS-TR.
  SESSION_PROP_VPN_NAME = "SESSION_VPN_NAME"
  # The Session client name that is used during client login to create a unique Session.
  # An empty string causes a unique client name to be generated automatically.
  # If specified, it must be a valid topic name, and a maximum of 160 bytes in length.
  # For all appliances (SolOS-TR or SolOS-CR) `SESSION_PROP_CLIENT_NAME`
  # is also used to uniquely identify the sender in a message's senderId field
  # if `SESSION_PROP_GENERATE_SENDER_ID` is set.
  SESSION_PROP_CLIENT_NAME = "SESSION_CLIENT_NAME"
  # How many times to retry to reconnect to the host appliance (or list of appliances)
  # after a connected Session goes down. Zero means no automatic reconnection attempts.
  # -1 means try to reconnect forever.
  SESSION_PROP_RECONNECT_RETRIES = "SESSION_RECONNECT_RETRIES"

  struct SessionHandlersPadding
    callback : UnspecifiedFunc
    data : Data
  end

  enum SessionEvent
    # The Session is established.
    UpNotice = 0
    # The Session was established and then went down.
    DownError = 1
    # The Session attempted to connect but was unsuccessful.
    ConnectFailedError = 2
    # The appliance rejected a published message.
    RejectedMsgError = 3
    # The appliance rejected a subscription (add or remove).
    SubscriptionError = 4
    # The API discarded a received message that exceeded the Session buffer size.
    MsgTooBigError = 5
    # The oldest transmitted Persistent/Non-Persistent message that has been acknowledged.
    Acknowledgement = 6
    # Deprecated -- see notes in solClient_session_startAssuredPublishing.
    # The AD Handshake (that is, Guaranteed Delivery handshake) has completed for the publisher
    # and Guaranteed messages can be sent.
    AssuredPublishingUp = 7
    # Guaranteed Delivery publishing is not available. The guaranteed delivery capability
    # on the session has been disabled by some action on the appliance.
    AssuredDeliveryDown = 8
    # The Topic Endpoint unsubscribe command failed.
    TEUnsubscribeError = 9
    # The Topic Endpoint unsubscribe completed.
    TEUnsubscribeOk = 10
    # The send is no longer blocked.
    CanSend = 11
    # The Session has gone down, and an automatic reconnect attempt is in progress.
    ReconnectingNotice = 12
    # The automatic reconnect of the Session was successful, and the Session was established again.
    ReconnectedNotice = 13
    # The endpoint create/delete command failed.
    ProvisionError = 14
    # The endpoint create/delete command completed.
    ProvisionOk = 15
    # The subscribe or unsubscribe operation has succeeded.
    SubscriptionOk = 16
    # The appliance's Virtual Router Name changed during a reconnect operation.
    # This could render existing queues or temporary topics invalid.
    VirtualRouterNameChanged = 17
    # The session property modification completed.
    ModifyPropOk = 18
    # The session property modification failed.
    ModifyPropFail = 19
    # After successfully reconnecting a disconnected session, the SDK received an unknown publisher
    # flow name response when reconnecting the GD publisher flow.
    RepublishUnackedMessages = 20
  end

  struct SessionEventInfo
    event : SessionEvent
    response_code : UInt32  # TODO Create enum with response codes?
    info : LibC::Char*
    correlation : Void*
  end

  struct SessionEventHandler
    callback : (Session, SessionEventInfo*, Data ->)
    data : Data
  end

  type Msg = Void*

  enum MsgAction
    # The message will be destroyed after callback returns.
    Destroy = 0
    # The message won't be destroyed.
    Keep = 1
  end

  struct MsgHandler
    callback : (Session, Msg, Data -> MsgAction)
    data : Data
  end

  struct SessionHandlers
    padding : SessionHandlersPadding
    event_handler : SessionEventHandler
    msg_handler : MsgHandler
  end

  fun session_create = solClient_session_create(
    props : Props,
    context : Context,
    session : Session*,
    handlers : SessionHandlers*,
    handlers_size : LibC::SizeT
  ) : ReturnCode

  fun session_connect = solClient_session_connect(session : Session) : ReturnCode

  # ===========================================================
  # Subscriptions
  # ===========================================================

  enum SubscribeFlags : UInt32
    # Requests a confirmation for the subscribe/unsubscribe operation.
    # If ::SOLCLIENT_SUBSCRIBE_FLAGS_WAITFORCONFIRM is not set when this flag is set,
    # then a confirmation event will be issued through the Session event callback procedure.
    RequestConfirm = 0x10
  end

  fun session_subscribe = solClient_session_topicSubscribeExt(
    session : Session,
    flags : SubscribeFlags,
    subscription : LibC::Char*
  ) : ReturnCode

  # ===========================================================
  # Messages
  # ===========================================================

  enum DestinationType : Int32
    NullDestination = -1
    TopicDestination = 0
    QueueDestination = 1
    TopicTempDestination = 2
    QueueTempDestination = 3
  end

  struct Destination
    type : DestinationType
    name : LibC::Char*
  end

  fun msg_get_destination = solClient_msg_getDestination(
    msg : Msg,
    destination : Destination*,
    destination_size : LibC::SizeT
  ) : ReturnCode

  fun msg_get_reply_to = solClient_msg_getReplyTo(
    msg : Msg,
    destination : Destination*,
    destination_size : LibC::SizeT
  ) : ReturnCode

  # START: Generated getters

  fun msg_get_sender_id = solClient_msg_getSenderId(
    msg : Msg,
    value : LibC::Char**
  ) : ReturnCode

  fun msg_get_application_msg_type = solClient_msg_getApplicationMsgType(
    msg : Msg,
    value : LibC::Char**
  ) : ReturnCode

  fun msg_get_application_msg_id = solClient_msg_getApplicationMessageId(
    msg : Msg,
    value : LibC::Char**
  ) : ReturnCode

  fun msg_get_correlation_id = solClient_msg_getCorrelationId(
    msg : Msg,
    value : LibC::Char**
  ) : ReturnCode

  fun msg_get_http_content_type = solClient_msg_getHttpContentType(
    msg : Msg,
    value : LibC::Char**
  ) : ReturnCode

  fun msg_get_http_content_encoding = solClient_msg_getHttpContentEncoding(
    msg : Msg,
    value : LibC::Char**
  ) : ReturnCode

  fun msg_get_sequence_number = solClient_msg_getSequenceNumber(
    msg : Msg,
    value : Int64*
  ) : ReturnCode

  fun msg_get_sender_timestamp = solClient_msg_getSenderTimestamp(
    msg : Msg,
    value : Int64*
  ) : ReturnCode

  fun msg_get_topic_sequence_number = solClient_msg_getTopicSequenceNumber(
    msg : Msg,
    value : Int64*
  ) : ReturnCode

  # END: Generated getters

end
