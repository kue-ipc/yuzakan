# Samba Account Control
# http://www.samba.gr.jp/project/translation/Samba3-HOWTO/passdb.html#accountflags

require_relative '../ad_adapter/account_control'
require_relative '../posix_ldap_adapter'

module Yuzakan
  module Adapters
    class SambaLdapAdapter < PosixLdapAdapter
      class SambaAccountControl < AdAdapter::AccountControl
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

        ATTRIBUTE_NAME = -'sambaAcctFlags'

        # override
        def initialize(argv = AccountControl::DEFAULT_USER_FLAGS)
          if argv.is_a?(String)
            @flags = 0
            argv.upcase.each_char do |c|
              @flags |= SAMAB_FLAG_MAP.fetch(c, 0)
            end
          else
            super
          end
        end

        # override
        def to_s
          str = map { |flag| SAMAB_FLAG_MAP_INVERT[flag] }.compact.sort.join
          '[%-11s]' % str
        end
        alias samba to_s
      end
    end
  end
end
