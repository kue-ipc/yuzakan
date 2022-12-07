# AD and Samba Account Control
# https://learn.microsoft.com/ja-jp/troubleshoot/windows-server/identity/useraccountcontrol-manipulate-account-properties
# http://www.samba.gr.jp/project/translation/Samba3-HOWTO/passdb.html#accountflags

class AccountContorl
  module Flag
    SCRIPT = 0x0001 # 1
    ACCOUNTDISABLE = 0x0002 # 2
    HOMEDIR_REQUIRED = 0x0008 # 8
    LOCKOUT = 0x0010 # 16
    PASSWD_NOTREQD = 0x0020 # 32
    PASSWD_CANT_CHANGE = 0x0040 # 64
    ENCRYPTED_TEXT_PWD_ALLOWED = 0x0080 # 128
    TEMP_DUPLICATE_ACCOUNT = 0x0100 # 256
    NORMAL_ACCOUNT = 0x0200 # 512
    INTERDOMAIN_TRUST_ACCOUNT = 0x0800 # 2048
    WORKSTATION_TRUST_ACCOUNT = 0x1000 # 4096
    SERVER_TRUST_ACCOUNT = 0x2000 # 8192
    DONT_EXPIRE_PASSWORD = 0x10000 # 65536
    MNS_LOGON_ACCOUNT = 0x20000 # 131072
    SMARTCARD_REQUIRED = 0x40000 # 262144
    TRUSTED_FOR_DELEGATION = 0x80000 # 524288
    NOT_DELEGATED = 0x100000 # 1048576
    USE_DES_KEY_ONLY = 0x200000 # 2097152
    DONT_REQ_PREAUTH = 0x400000 # 4194304
    PASSWORD_EXPIRED = 0x800000 # 8388608
    TRUSTED_TO_AUTH_FOR_DELEGATION = 0x1000000 # 16777216
    PARTIAL_SECRETS_ACCOUNT = 0x04000000 # 67108864
  end
  DEFAULT_USER_FLAGS = Flag::NORMAL_ACCOUNT & Flag::DONT_EXPIRE_PASSWORD

  SAMAB_FLAG_MAP = {
    'D' => Flag::ACCOUNTDISABLE,
    'H' => Flag::HOMEDIR_REQUIRED,
    'L' => Flag::LOCKOUT,
    'N' => Flag::PASSWD_NOTREQD,
    'T' => Flag::TEMP_DUPLICATE_ACCOUNT,
    'U' => Flag::NORMAL_ACCOUNT,
    'I' => Flag::INTERDOMAIN_TRUST_ACCOUNT,
    'W' => Flag::WORKSTATION_TRUST_ACCOUNT,
    'S' => Flag::SERVER_TRUST_ACCOUNT,
    'X' => Flag::DONT_EXPIRE_PASSWORD,
    'M' => Flag::MNS_LOGON_ACCOUNT,
  }
  SAMAB_FLAG_MAP_INVERT = SAMAB_FLAG_MAP.invert

  ATTRIBUTE_NAMES = {
    ad: 'userAccountControl',
    samba: 'sambaAcctFlags',
  }

  include Enumerable

  attr_reader :flags

  def initialize(flgas)
    case flags
    when Integer
      @flags = flags
    when Array
      @flags = 0
      flgas.each { |flag| @flags |= flag }
    when String
      @flags = 0
      flags.upcase.each_char do |c|
        @flags |= SAMAB_FLAG_MAP.fetch(c, 0)
      end
    else
      raise ArgumentError, "Invalid flags: #{flags}"
    end
  end

  def intersection(other)
    new(@flags & other.flags)
  end
  alias & intersection

  def union(other)
    new(@flags | other.flags)
  end
  alias + union
  alias | union

  def difference(other)
    new(@flags & ~other.flags)
  end
  alias - difference

  def add(flag)
    @flags |= flag
  end
  alias << add

  def delete(flag)
    @flag &= ~flag
  end

  def ==(other)
    @flags == other.flags
  end

  def include?(flag)
    @flags.anybits?(flag)
  end
  alias member? include?
  alias === include?

  def ^(other)
    new(@flags ^ other.flags)
  end

  def clear
    @flags = 0
  end

  def clone
    new(@flags)
  end
  alias dup clone

  def merge(other)
    @flags |= other.flags
  end

  def replace(other)
    @flags = other.flags
  end

  def subtract(other)
    @flags &= ~other.flags
  end

  def disjoint?(other)
  end

  def intersect?(other)
  end

  def subset?(other)
    other.superset?(self)
  end

  def superset?(other)
    @flags.allbits?(other.flags)
  end

  def proper_subset?(other)
    return false if self == other

    subset?(other)
  end

  def proper_superset?(other)
    return false if self == other

    superset?(other)
  end

  def each
    return to_enum unless block_given?

    n = 1
    while n <= @flags
      yield n if @flags.anybits?(n)
      n <<= 1
    end
  end

  def empty?
    @flags.empty?
  end

  def samba
    str = map { |flag| SAMAB_FLAG_MAP_INVERT[flag] }.compact.join
    '[%-11s]' % str
  end

  def inspect
    "#{samba} 0x#{flags.to_(16)} "
  end

  alias to_i flags
  alias to_s inspect
end
