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

   module:log("info", "XXXX triggering webhook");
   local cb = function (response,code,request)
      module:log("info", "XXXX got HTTP response %d", code)
   end
   local opts = {
      body = http.formencode({to="foo@example.com",message="a pretend message"});
   }
   http.request(url, opts, cb)
end

if url then 
   module:log("debug", "%s will POST to %s", module:get_host(), url)
   module:hook("message/bare", on_message);
   module:hook("message/full", on_message);
end
