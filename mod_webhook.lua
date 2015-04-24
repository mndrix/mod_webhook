-- POST a copy of each chat message to a URL

module:log("debug", "module loading")

local http = require("net.http")
local jid = require("util.jid")

local url = module:get_option_string("webhook_url")
local desired_from = jid.bare(module:get_option_string("webhook_messages_from"))

function on_message(event)
   module:log("info", "XXXX Received: %s", tostring(event.stanza));
   module:log("info", "XXXX from: %s", event.stanza.attr.from);

   -- only process 'chat' messages
   if "chat" ~= event.stanza.attr.type then
      return
   end

   -- only process messages from Michael
   local raw_from = event.stanza.attr.from
   local bare_from = jid.bare(raw_from)
   if bare_from ~= desired_from then
      return
   end

   -- execute the webhook
   module:log("debug", "running webhook");
   local raw_to = event.stanza.attr.to
   local raw_body = event.stanza:get_child("body"):get_text()
   local cb = function (response,code,request)
      module:log("debug", "webhook returned HTTP response %d", code)
   end
   local opts = {
       body = http.formencode({
           from = raw_from;
           to = raw_to;
           message = raw_body;
       });
   }
   http.request(url, opts, cb)
end

if url then 
   module:log("debug", "%s will POST to %s", module:get_host(), url)
   module:hook("message/bare", on_message);
   module:hook("message/full", on_message);
end
