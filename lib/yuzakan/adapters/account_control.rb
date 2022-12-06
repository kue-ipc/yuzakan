# AD and Samba Account Control
# https://learn.microsoft.com/ja-jp/troubleshoot/windows-server/identity/useraccountcontrol-manipulate-account-properties
# http://www.samba.gr.jp/project/translation/Samba3-HOWTO/passdb.html#accountflags

class AccountContorl
  AD_ATTRIBUTE_NAME = 'userAccountControl'
  SAMAB_ATTRIBUTE_NAME = 'sambaAcctFlags'
  FLAGS = [
    Flag.new('ACCOUNTDISABLE', 0x0002, :D),
    Flag.new('HOMEDIR_REQUIRED', 0x0008, :H),
    Flag.new('LOCKOUT', 0x0010, :L),
    Flag.new('PASSWD_NOTREQD', 0x0020, :N),
    Flag.new('TEMP_DUPLICATE_ACCOUNT', 0x0100, :T),
    Flag.new('NORMAL_ACCOUNT', 0x0200, :U),
    Flag.new('INTERDOMAIN_TRUST_ACCOUNT', 0x0800, :I),
    Flag.new('WORKSTATION_TRUST_ACCOUNT', 0x1000, :W),
    Flag.new('SERVER_TRUST_ACCOUNT',  0x2000, :S),
    Flag.new('DONT_EXPIRE_PASSWORD',  0x10000, :X),
    Flag.new('MNS_LOGON_ACCOUNT', 0x20000, :M),
  ]
  FLAG_NAME_MAP = FLAGS.to_h { |f| [f.name, f] }
  FLAG_NAME_
  DEFAULT_USER = AccountControl.new(Flag::NORMAL_ACCOUNT, Flag::DONT_EXPIRE_PASSWORD)

  def initialize()

  class Flag
    attr_reader :name, :value, :flag

    def initialize(name, value, flag = nil)
      @name = name
      @value = value
      @flag = flag
    end
  end

  

end
