# =============================================================================
# Plugin: Messenger
#
# Description:
#     Sends a PM to a user.
#
# Requirements:
#     none
class Messenger
  include Cinch::Plugin

  set(:prefix, ->(m) { m.bot.config.plugins.prefix })

  match(/tell (.+?) (.+)/)

  # Function: execute
  #
  # Description:
  #     Tells someone something.
  def execute(m, receiver, message)
    m.reply 'Done.'
    User(receiver).send(message)
  end
end
# End of plugin: Messenger
# =============================================================================
