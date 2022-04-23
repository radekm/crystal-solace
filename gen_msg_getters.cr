# It seems that macros can't generate `fun`s.

msg_string_getters = [
  { "solClient_msg_getSenderId", "msg_get_sender_id" },
  { "solClient_msg_getApplicationMsgType", "msg_get_application_msg_type" },
  { "solClient_msg_getApplicationMessageId", "msg_get_application_msg_id" },
  { "solClient_msg_getCorrelationId", "msg_get_correlation_id" },
  { "solClient_msg_getHttpContentType", "msg_get_http_content_type" },
  { "solClient_msg_getHttpContentEncoding", "msg_get_http_content_encoding" }
]

msg_string_getters.each do |cname, name|
  puts "  fun #{name} = #{cname}("
  puts "    msg : Msg,"
  puts "    value : LibC::Char**"
  puts "  ) : ReturnCode"
  puts
end

msg_int64_getters = [
  { "solClient_msg_getSequenceNumber", "msg_get_sequence_number" },
  { "solClient_msg_getSenderTimestamp", "msg_get_sender_timestamp" },
  { "solClient_msg_getTopicSequenceNumber", "msg_get_topic_sequence_number" },
]

msg_int64_getters.each do |cname, name|
  puts "  fun #{name} = #{cname}("
  puts "    msg : Msg,"
  puts "    value : Int64*"
  puts "  ) : ReturnCode"
  puts
end
