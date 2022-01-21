require 'securerandom'
require 'net/ldap'

require 'base64'
require 'digest'

# パスワード変更について
# userPassword は {CRYPT}$1$%.8s をデフォルトする。
# sambaLMPassword はデフォルト無効とし、設定済みは削除する。
# sambaNTPassword はデフォルト有効とし、設定する。

require_relative 'base_ldap_adapter'

module Yuzakan
  module Adapters
    class LdapAdapter < BaseLdapAdapter
      self.label = 'LDAP'

      self.params = BaseLdapAdapter.params
    end
  end
end
